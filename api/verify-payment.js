/**
 * POST /api/verify-payment
 * 
 * Secure Payment Verification Endpoint:
 * 1. Receives orderId, razorpay_order_id, razorpay_payment_id, razorpay_signature.
 * 2. Validates order association between internal ORIGIN order and Razorpay order.
 * 3. Cryptographically verifies HMAC-SHA256 signature using RAZORPAY_KEY_SECRET.
 * 4. Updates order payment status to 'paid' idempotently.
 * 5. Returns confirmed order details.
 */

const { getOrderById, markOrderAsPaid, markOrderAsFailed } = require('./_lib/order-store');
const { verifyPaymentSignature, fetchPayment } = require('./_lib/razorpay');

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type,Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({
      success: false,
      error: 'Method Not Allowed. Use POST.'
    });
  }

  try {
    let body = req.body;
    if (typeof body === 'string') {
      try {
        body = JSON.parse(body);
      } catch {
        return res.status(400).json({ success: false, error: 'Malformed JSON payload.' });
      }
    }
    body = body || {};

    const {
      orderId,
      razorpayOrderId,
      razorpay_order_id,
      razorpayPaymentId,
      razorpay_payment_id,
      razorpaySignature,
      razorpay_signature
    } = body;

    const finalOrderId = orderId;
    const finalRazorpayOrderId = razorpayOrderId || razorpay_order_id;
    const finalRazorpayPaymentId = razorpayPaymentId || razorpay_payment_id;
    const finalRazorpaySignature = razorpaySignature || razorpay_signature;

    if (!finalOrderId || !finalRazorpayOrderId || !finalRazorpayPaymentId || !finalRazorpaySignature) {
      return res.status(400).json({
        success: false,
        error: 'Missing required settlement verification parameters.'
      });
    }

    // Verify order exists in repository
    const order = getOrderById(finalOrderId);
    if (!order) {
      return res.status(404).json({
        success: false,
        error: `Order '${finalOrderId}' does not exist in the vault repository.`
      });
    }

    // Validate order association
    if (order.razorpayOrderId && order.razorpayOrderId !== finalRazorpayOrderId) {
      return res.status(400).json({
        success: false,
        error: 'Razorpay order ID mismatch with internal registry.'
      });
    }

    // Cryptographic Signature Verification
    const isValidSignature = verifyPaymentSignature({
      razorpayOrderId: finalRazorpayOrderId,
      razorpayPaymentId: finalRazorpayPaymentId,
      razorpaySignature: finalRazorpaySignature
    });

    if (!isValidSignature) {
      markOrderAsFailed(finalOrderId, {
        reason: 'Cryptographic signature mismatch.',
        code: 'SIGNATURE_INVALID'
      });

      return res.status(400).json({
        success: false,
        verified: false,
        error: 'Payment verification failed: cryptographic signature could not be validated.'
      });
    }

    // Optional API fetch for live transaction detail confirmation
    let rawPaymentDetails = null;
    try {
      rawPaymentDetails = await fetchPayment(finalRazorpayPaymentId);
    } catch {
      // Payment fetch is advisory; cryptographic signature is authoritative
    }

    // Mark order as paid idempotently
    const { order: updatedOrder, alreadyPaid } = markOrderAsPaid(finalOrderId, {
      razorpayPaymentId: finalRazorpayPaymentId,
      razorpaySignature: finalRazorpaySignature,
      rawPaymentDetails
    });

    return res.status(200).json({
      success: true,
      verified: true,
      alreadyPaid,
      order: {
        id: updatedOrder.id,
        trackingNumber: updatedOrder.trackingNumber,
        paymentStatus: updatedOrder.paymentStatus,
        fulfillmentStatus: updatedOrder.fulfillmentStatus,
        razorpayOrderId: updatedOrder.razorpayOrderId,
        razorpayPaymentId: updatedOrder.razorpayPaymentId,
        pricing: updatedOrder.pricing,
        items: updatedOrder.items,
        customer: updatedOrder.customer,
        shippingMethod: updatedOrder.shippingMethod,
        createdAt: updatedOrder.createdAt,
        updatedAt: updatedOrder.updatedAt
      }
    });
  } catch (err) {
    console.error('Payment verification error:', err);
    return res.status(500).json({
      success: false,
      error: 'An internal error occurred during payment verification. Please check order status.'
    });
  }
};
