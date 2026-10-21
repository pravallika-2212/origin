/**
 * POST /api/webhook
 * 
 * Razorpay Webhook Handler:
 * 1. Captures raw request buffer for accurate HMAC-SHA256 signature verification.
 * 2. Verifies x-razorpay-signature header with RAZORPAY_WEBHOOK_SECRET.
 * 3. Enforces idempotency via event ID tracking.
 * 4. Processes order.paid, payment.captured, payment.failed events.
 * 5. Strictly protects against downgrading an already paid order.
 */

const { verifyWebhookSignature } = require('./_lib/razorpay');
const {
  getOrderByRazorpayOrderId,
  markOrderAsPaid,
  markOrderAsFailed,
  hasProcessedEvent,
  recordProcessedEvent
} = require('./_lib/order-store');

// Disable automatic body parsing on Vercel so we can read the raw stream for signature verification
const config = {
  api: {
    bodyParser: false
  }
};

async function getRawBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', (chunk) => chunks.push(chunk));
    req.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
    req.on('error', (err) => reject(err));
  });
}

async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ success: false, error: 'Method Not Allowed. Use POST.' });
  }

  try {
    let rawBody = '';
    if (typeof req.body === 'string') {
      rawBody = req.body;
    } else if (Buffer.isBuffer(req.rawBody)) {
      rawBody = req.rawBody.toString('utf8');
    } else if (typeof req.on === 'function') {
      try {
        rawBody = await getRawBody(req);
      } catch {
        rawBody = JSON.stringify(req.body || {});
      }
    } else {
      rawBody = JSON.stringify(req.body || {});
    }

    const signature = req.headers['x-razorpay-signature'] || '';
    const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;

    // Cryptographic Webhook Signature Verification
    if (webhookSecret) {
      const isValid = verifyWebhookSignature({
        rawBody,
        signature,
        secret: webhookSecret
      });

      if (!isValid) {
        console.warn('Razorpay webhook signature verification failed.');
        return res.status(400).json({ success: false, error: 'Invalid webhook signature.' });
      }
    } else {
      console.warn('RAZORPAY_WEBHOOK_SECRET is not configured; running in test validation mode.');
    }

    let payload;
    try {
      payload = JSON.parse(rawBody);
    } catch {
      return res.status(400).json({ success: false, error: 'Invalid JSON payload.' });
    }

    const eventId = payload.event_id || payload.id;
    const event = payload.event;

    // Idempotency: Prevent duplicate processing of the same webhook delivery
    if (eventId && hasProcessedEvent(eventId)) {
      return res.status(200).json({ status: 'ok', message: 'Event already processed.' });
    }

    const paymentEntity = payload.payload?.payment?.entity;
    const orderEntity = payload.payload?.order?.entity;
    const razorpayOrderId = paymentEntity?.order_id || orderEntity?.id;

    if (razorpayOrderId) {
      const order = getOrderByRazorpayOrderId(razorpayOrderId);
      if (order) {
        switch (event) {
          case 'order.paid':
          case 'payment.captured':
          case 'payment.authorized': {
            const paymentId = paymentEntity?.id || 'webhook_captured';
            markOrderAsPaid(order.id, {
              razorpayPaymentId: paymentId,
              razorpaySignature: signature || 'verified_via_webhook',
              rawPaymentDetails: paymentEntity
            });
            break;
          }

          case 'payment.failed': {
            // Only update if not already paid
            const errorDesc = paymentEntity?.error_description || 'Payment failed';
            const errorCode = paymentEntity?.error_code || 'PAYMENT_FAILED';
            markOrderAsFailed(order.id, {
              reason: errorDesc,
              code: errorCode
            });
            break;
          }

          default:
            // Unhandled event; acknowledged safely
            break;
        }
      }
    }

    if (eventId) {
      recordProcessedEvent(eventId);
    }

    return res.status(200).json({ status: 'ok', received: true });
  } catch (err) {
    console.error('Webhook processing error:', err);
    return res.status(500).json({ success: false, error: 'Webhook processing encountered an error.' });
  }
}

handler.config = config;
module.exports = handler;
