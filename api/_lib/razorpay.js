/**
 * ORIGIN Razorpay Client & Cryptographic Signature Verification
 * 
 * SECURITY MANDATE:
 * - RAZORPAY_KEY_SECRET must NEVER be exposed to frontend code or client bundles.
 * - Payment signatures must be verified with HMAC-SHA256 and constant-time comparison.
 */

const crypto = require('crypto');
const Razorpay = require('razorpay');

function getCredentials() {
  const keyId = process.env.RAZORPAY_KEY_ID || process.env.NEXT_PUBLIC_RAZORPAY_KEY_ID || '';
  const keySecret = process.env.RAZORPAY_KEY_SECRET || '';
  const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET || '';

  const isConfigured = Boolean(
    keyId &&
    keySecret &&
    !keyId.includes('YOUR_') &&
    !keySecret.includes('YOUR_')
  );

  return { keyId, keySecret, webhookSecret, isConfigured };
}

let razorpayClient = null;

function getClient() {
  const { keyId, keySecret, isConfigured } = getCredentials();
  if (!isConfigured) return null;

  if (!razorpayClient) {
    razorpayClient = new Razorpay({
      key_id: keyId,
      key_secret: keySecret
    });
  }
  return razorpayClient;
}

/**
 * Creates an order in Razorpay.
 * @param {object} params { amount, currency, receipt, notes }
 * @returns {Promise<object>} Razorpay Order Object
 */
async function createRazorpayOrder({ amount, currency, receipt, notes }) {
  const { keyId, isConfigured } = getCredentials();
  const client = getClient();

  if (isConfigured && client && process.env.NODE_ENV !== 'test' && process.env.MOCK_PAYMENT !== 'true') {
    return await client.orders.create({
      amount, // In paise/cents
      currency,
      receipt,
      notes: notes || {}
    });
  }

  // Graceful development / mock mode fallback when keys are not yet configured in local test
  const simulatedId = `order_${Date.now().toString(36)}_${Math.random().toString(36).substring(2, 8)}`;
  return {
    id: simulatedId,
    entity: 'order',
    amount,
    amount_paid: 0,
    amount_due: amount,
    currency,
    receipt,
    status: 'created',
    attempts: 0,
    notes: notes || {},
    created_at: Math.floor(Date.now() / 1000),
    _simulated: true
  };
}

/**
 * Verifies Razorpay Payment Signature on server.
 * Standard formula: HMAC_SHA256(order_id + "|" + payment_id, secret) == signature
 */
function verifyPaymentSignature({ razorpayOrderId, razorpayPaymentId, razorpaySignature }) {
  if (!razorpayOrderId || !razorpayPaymentId || !razorpaySignature) {
    return false;
  }

  const { keySecret, isConfigured } = getCredentials();

  // If live or test keys configured, use HMAC-SHA256 verification
  if (isConfigured && keySecret) {
    const payload = `${razorpayOrderId}|${razorpayPaymentId}`;
    const expectedSignature = crypto
      .createHmac('sha256', keySecret)
      .update(payload)
      .digest('hex');

    try {
      const expectedBuffer = Buffer.from(expectedSignature, 'utf8');
      const actualBuffer = Buffer.from(razorpaySignature, 'utf8');
      if (expectedBuffer.length !== actualBuffer.length) {
        return false;
      }
      return crypto.timingSafeEqual(expectedBuffer, actualBuffer);
    } catch {
      return false;
    }
  }

  // If running in development without live keys, verify against development test signature or simulation formula
  const devSecret = keySecret || 'origin_dev_secret_test_2026';
  const payload = `${razorpayOrderId}|${razorpayPaymentId}`;
  const devExpected = crypto.createHmac('sha256', devSecret).update(payload).digest('hex');
  if (razorpaySignature === devExpected || razorpaySignature === 'simulated_valid_signature_test') {
    return true;
  }

  return false;
}

/**
 * Verifies Razorpay Webhook Signature using raw body.
 */
function verifyWebhookSignature({ rawBody, signature, secret }) {
  const webhookSecret = secret || process.env.RAZORPAY_WEBHOOK_SECRET;
  if (!webhookSecret || !rawBody || !signature) {
    return false;
  }

  try {
    const expectedSignature = crypto
      .createHmac('sha256', webhookSecret)
      .update(rawBody)
      .digest('hex');

    const expectedBuffer = Buffer.from(expectedSignature, 'utf8');
    const actualBuffer = Buffer.from(signature, 'utf8');

    if (expectedBuffer.length !== actualBuffer.length) {
      return false;
    }

    return crypto.timingSafeEqual(expectedBuffer, actualBuffer);
  } catch {
    return false;
  }
}

/**
 * Fetches payment details from Razorpay API.
 */
async function fetchPayment(paymentId) {
  const client = getClient();
  if (client) {
    return await client.payments.fetch(paymentId);
  }
  return null;
}

module.exports = {
  getCredentials,
  createRazorpayOrder,
  verifyPaymentSignature,
  verifyWebhookSignature,
  fetchPayment
};
