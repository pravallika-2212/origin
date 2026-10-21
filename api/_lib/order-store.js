/**
 * ORIGIN Order Store & State Management
 * 
 * Provides robust order management with distinct payment & fulfillment lifecycles,
 * audit trails, and idempotent event processing.
 */

// In-memory store for serverless execution / local development
const ordersMap = new Map();
const razorpayOrderIndex = new Map();
const processedEvents = new Set();

/**
 * Generates an internal ORIGIN order ID.
 * Example: ORD-849201
 */
function generateOrderId() {
  const randomSuffix = Math.floor(100000 + Math.random() * 900000);
  return `ORD-${randomSuffix}`;
}

/**
 * Creates a new pending order in the store.
 */
function createPendingOrder({
  customer,
  pricing,
  items,
  shippingMethod,
  razorpayOrderId,
  userId = 'guest'
}) {
  const orderId = generateOrderId();
  const now = new Date().toISOString();

  const trackingNumber = `ORIGIN-SECURE-${Math.floor(10000 + Math.random() * 90000)}`;

  const order = {
    id: orderId,
    userId,
    customer: {
      name: customer.name || '',
      email: customer.email || '',
      phone: customer.phone || '',
      address: customer.address || '',
      city: customer.city || '',
      country: customer.country || '',
      postalCode: customer.postalCode || ''
    },
    items,
    pricing,
    shippingMethod: shippingMethod || 'White-Glove Art Courier & Armored Escort',
    trackingNumber,
    razorpayOrderId: razorpayOrderId || null,
    razorpayPaymentId: null,
    razorpaySignature: null,
    paymentStatus: 'pending', // 'pending' | 'payment_processing' | 'paid' | 'failed' | 'cancelled'
    fulfillmentStatus: 'vault_reserved', // 'vault_reserved' | 'archival_verification' | 'in_transit' | 'delivered'
    createdAt: now,
    updatedAt: now,
    auditTrail: [
      {
        timestamp: now,
        action: 'ORDER_CREATED',
        details: { razorpayOrderId, total: pricing.total, currency: pricing.currency }
      }
    ]
  };

  ordersMap.set(orderId, order);
  if (razorpayOrderId) {
    razorpayOrderIndex.set(razorpayOrderId, orderId);
  }

  return order;
}

/**
 * Retrieves an order by internal order ID.
 */
function getOrderById(orderId) {
  if (!orderId) return null;
  return ordersMap.get(orderId) || null;
}

/**
 * Retrieves an order by Razorpay order ID.
 */
function getOrderByRazorpayOrderId(razorpayOrderId) {
  if (!razorpayOrderId) return null;
  const orderId = razorpayOrderIndex.get(razorpayOrderId);
  if (!orderId) return null;
  return ordersMap.get(orderId) || null;
}

/**
 * Updates order with Razorpay order ID link.
 */
function linkRazorpayOrder(orderId, razorpayOrderId) {
  const order = ordersMap.get(orderId);
  if (!order) return null;

  order.razorpayOrderId = razorpayOrderId;
  order.updatedAt = new Date().toISOString();
  razorpayOrderIndex.set(razorpayOrderId, orderId);
  return order;
}

/**
 * Idempotently marks an order as paid after successful cryptographic verification.
 */
function markOrderAsPaid(orderId, { razorpayPaymentId, razorpaySignature, rawPaymentDetails = null }) {
  const order = ordersMap.get(orderId);
  if (!order) {
    throw new Error(`Order ${orderId} not found.`);
  }

  // Idempotency: If already paid, do not re-process or downgrade
  if (order.paymentStatus === 'paid') {
    return { order, alreadyPaid: true };
  }

  const now = new Date().toISOString();
  order.paymentStatus = 'paid';
  order.fulfillmentStatus = 'archival_verification';
  order.razorpayPaymentId = razorpayPaymentId;
  order.razorpaySignature = razorpaySignature;
  order.updatedAt = now;
  order.auditTrail.push({
    timestamp: now,
    action: 'PAYMENT_VERIFIED',
    details: {
      razorpayPaymentId,
      rawStatus: rawPaymentDetails ? rawPaymentDetails.status : 'verified'
    }
  });

  return { order, alreadyPaid: false };
}

/**
 * Records a payment failure.
 * Note: Never downgrades an already paid order.
 */
function markOrderAsFailed(orderId, { reason, code }) {
  const order = ordersMap.get(orderId);
  if (!order) return null;

  // Protect against downgrading an already paid order
  if (order.paymentStatus === 'paid') {
    return order;
  }

  const now = new Date().toISOString();
  order.paymentStatus = 'failed';
  order.updatedAt = now;
  order.auditTrail.push({
    timestamp: now,
    action: 'PAYMENT_FAILED',
    details: { reason, code }
  });

  return order;
}

/**
 * Records customer checkout cancellation.
 */
function markOrderAsCancelled(orderId, { reason = 'Customer closed checkout' }) {
  const order = ordersMap.get(orderId);
  if (!order) return null;

  if (order.paymentStatus === 'paid') {
    return order;
  }

  const now = new Date().toISOString();
  order.paymentStatus = 'cancelled';
  order.updatedAt = now;
  order.auditTrail.push({
    timestamp: now,
    action: 'CHECKOUT_CANCELLED',
    details: { reason }
  });

  return order;
}

/**
 * Idempotency check for webhook events.
 */
function hasProcessedEvent(eventId) {
  if (!eventId) return false;
  return processedEvents.has(eventId);
}

function recordProcessedEvent(eventId) {
  if (!eventId) return;
  processedEvents.add(eventId);
}

module.exports = {
  createPendingOrder,
  getOrderById,
  getOrderByRazorpayOrderId,
  linkRazorpayOrder,
  markOrderAsPaid,
  markOrderAsFailed,
  markOrderAsCancelled,
  hasProcessedEvent,
  recordProcessedEvent
};
