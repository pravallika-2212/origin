/**
 * GET /api/order-status?orderId=...
 * 
 * Authoritative Order Status Endpoint:
 * Allows safe verification of order and payment status without risking duplicate charges.
 */

const { getOrderById, getOrderByRazorpayOrderId } = require('./_lib/order-store');

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type,Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'GET') {
    return res.status(405).json({ success: false, error: 'Method Not Allowed. Use GET.' });
  }

  try {
    const { orderId, razorpayOrderId } = req.query || {};

    let order = null;
    if (orderId) {
      order = getOrderById(orderId);
    } else if (razorpayOrderId) {
      order = getOrderByRazorpayOrderId(razorpayOrderId);
    }

    if (!order) {
      return res.status(404).json({
        success: false,
        error: 'Order record not found in ORIGIN repository.'
      });
    }

    return res.status(200).json({
      success: true,
      order: {
        id: order.id,
        trackingNumber: order.trackingNumber,
        paymentStatus: order.paymentStatus,
        fulfillmentStatus: order.fulfillmentStatus,
        razorpayOrderId: order.razorpayOrderId,
        razorpayPaymentId: order.razorpayPaymentId,
        pricing: order.pricing,
        items: order.items,
        shippingMethod: order.shippingMethod,
        customer: {
          name: order.customer.name,
          email: order.customer.email,
          city: order.customer.city,
          country: order.customer.country
        },
        createdAt: order.createdAt,
        updatedAt: order.updatedAt
      }
    });
  } catch (err) {
    console.error('Order status retrieval error:', err);
    return res.status(500).json({
      success: false,
      error: 'An internal error occurred while checking order status.'
    });
  }
};
