const test = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('crypto');
const { verifyPaymentSignature, verifyWebhookSignature } = require('../_lib/razorpay');

test('Signature Verification: successfully verifies valid HMAC-SHA256 signature', () => {
  const secret = 'test_secret_key_884920';
  process.env.RAZORPAY_KEY_SECRET = secret;
  process.env.RAZORPAY_KEY_ID = 'rzp_test_1234567890';

  const razorpayOrderId = 'order_DEF456';
  const razorpayPaymentId = 'pay_GHI789';

  const validSignature = crypto
    .createHmac('sha256', secret)
    .update(`${razorpayOrderId}|${razorpayPaymentId}`)
    .digest('hex');

  const isValid = verifyPaymentSignature({
    razorpayOrderId,
    razorpayPaymentId,
    razorpaySignature: validSignature
  });

  assert.equal(isValid, true);
});

test('Signature Verification: rejects tampered payment ID or signature', () => {
  const secret = 'test_secret_key_884920';
  process.env.RAZORPAY_KEY_SECRET = secret;
  process.env.RAZORPAY_KEY_ID = 'rzp_test_1234567890';

  const razorpayOrderId = 'order_DEF456';
  const razorpayPaymentId = 'pay_GHI789';

  const validSignature = crypto
    .createHmac('sha256', secret)
    .update(`${razorpayOrderId}|${razorpayPaymentId}`)
    .digest('hex');

  // Tampered payment ID
  assert.equal(
    verifyPaymentSignature({
      razorpayOrderId,
      razorpayPaymentId: 'pay_TAMPERED',
      razorpaySignature: validSignature
    }),
    false
  );

  // Tampered signature
  assert.equal(
    verifyPaymentSignature({
      razorpayOrderId,
      razorpayPaymentId,
      razorpaySignature: 'tampered_signature_string_hex_00000000000000000000000000000000'
    }),
    false
  );
});

test('Signature Verification: validates webhook signatures with raw body', () => {
  const webhookSecret = 'test_whsec_secret_449210';
  const rawBody = JSON.stringify({
    event: 'order.paid',
    payload: { order: { entity: { id: 'order_123' } } }
  });

  const validSignature = crypto
    .createHmac('sha256', webhookSecret)
    .update(rawBody)
    .digest('hex');

  const isValid = verifyWebhookSignature({
    rawBody,
    signature: validSignature,
    secret: webhookSecret
  });

  assert.equal(isValid, true);

  // Rejects if body altered by a single character
  const alteredBody = rawBody + ' ';
  assert.equal(
    verifyWebhookSignature({
      rawBody: alteredBody,
      signature: validSignature,
      secret: webhookSecret
    }),
    false
  );
});
