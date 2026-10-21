process.env.NODE_ENV = 'test';
const test = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('crypto');

const createOrderHandler = require('../create-order');
const verifyPaymentHandler = require('../verify-payment');
const orderStatusHandler = require('../order-status');
const webhookHandler = require('../webhook');
const { getOrderById } = require('../_lib/order-store');

function createMockRes() {
  const res = {
    statusCode: 200,
    headers: {},
    body: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    setHeader(key, val) {
      this.headers[key] = val;
      return this;
    },
    json(data) {
      this.body = data;
      return this;
    },
    end() {
      return this;
    }
  };
  return res;
}

test('Endpoints Flow: Full Order Creation, Status, Verification and Webhook Idempotency', async () => {
  const testSecret = 'origin_test_key_secret_12345';
  process.env.RAZORPAY_KEY_SECRET = testSecret;
  process.env.RAZORPAY_KEY_ID = 'rzp_test_testkey1234';
  process.env.RAZORPAY_WEBHOOK_SECRET = 'whsec_origin_secret_54321';

  // 1. Create Order
  const createReq = {
    method: 'POST',
    body: {
      items: [{ productId: 'prod-7', quantity: 2 }], // 2 x $1,299 = $2,598 + $150 shipping = $2,748 USD
      customer: {
        name: 'Princess Gayatri Devi',
        email: 'gayatri.devi@heritage.in',
        phone: '+91 98765 43210',
        address: 'City Palace, Jaleb Chowk',
        city: 'Jaipur',
        country: 'India',
        postalCode: '302002'
      },
      currency: 'INR'
    }
  };
  const createRes = createMockRes();
  await createOrderHandler(createReq, createRes);

  assert.equal(createRes.statusCode, 200);
  assert.equal(createRes.body.success, true);
  const { orderId, razorpayOrderId, amount } = createRes.body;
  assert.ok(orderId.startsWith('ORD-'));
  assert.ok(razorpayOrderId);
  assert.equal(createRes.body.currency, 'INR');

  // Verify internal pending order created
  const storedOrder = getOrderById(orderId);
  assert.equal(storedOrder.paymentStatus, 'pending');
  assert.equal(storedOrder.customer.name, 'Princess Gayatri Devi');

  // 2. Check Order Status via GET /api/order-status
  const statusReq = {
    method: 'GET',
    query: { orderId }
  };
  const statusRes = createMockRes();
  await orderStatusHandler(statusReq, statusRes);
  assert.equal(statusRes.statusCode, 200);
  assert.equal(statusRes.body.order.paymentStatus, 'pending');

  // 3. Payment Verification with Valid Signature
  const razorpayPaymentId = 'pay_Jaipur998811';
  const validSignature = crypto
    .createHmac('sha256', testSecret)
    .update(`${razorpayOrderId}|${razorpayPaymentId}`)
    .digest('hex');

  const verifyReq = {
    method: 'POST',
    body: {
      orderId,
      razorpayOrderId,
      razorpayPaymentId,
      razorpaySignature: validSignature
    }
  };
  const verifyRes = createMockRes();
  await verifyPaymentHandler(verifyReq, verifyRes);

  assert.equal(verifyRes.statusCode, 200);
  assert.equal(verifyRes.body.success, true);
  assert.equal(verifyRes.body.verified, true);
  assert.equal(verifyRes.body.order.paymentStatus, 'paid');
  assert.equal(verifyRes.body.order.fulfillmentStatus, 'archival_verification');

  // 4. Verification Idempotency: Repeating verification must return alreadyPaid: true without error
  const duplicateVerifyRes = createMockRes();
  await verifyPaymentHandler(verifyReq, duplicateVerifyRes);
  assert.equal(duplicateVerifyRes.statusCode, 200);
  assert.equal(duplicateVerifyRes.body.alreadyPaid, true);

  // 5. Webhook safety: Late delivery of 'payment.failed' must NOT downgrade an already paid order
  const lateWebhookPayload = {
    event_id: 'evt_late_failure_99',
    event: 'payment.failed',
    payload: {
      payment: {
        entity: {
          id: 'pay_failed_attempt_00',
          order_id: razorpayOrderId,
          error_description: 'Card declined on earlier attempt'
        }
      }
    }
  };
  const rawLateWebhook = JSON.stringify(lateWebhookPayload);
  const webhookSig = crypto
    .createHmac('sha256', process.env.RAZORPAY_WEBHOOK_SECRET)
    .update(rawLateWebhook)
    .digest('hex');

  const webhookReq = {
    method: 'POST',
    headers: { 'x-razorpay-signature': webhookSig },
    body: rawLateWebhook
  };
  const webhookRes = createMockRes();
  await webhookHandler(webhookReq, webhookRes);
  assert.equal(webhookRes.statusCode, 200);

  // Assert order status remains 'paid'
  const postWebhookOrder = getOrderById(orderId);
  assert.equal(postWebhookOrder.paymentStatus, 'paid');
});
