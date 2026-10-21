/**
 * POST /api/create-order
 * 
 * Secure Order Creation Endpoint:
 * 1. Validates customer and delivery information.
 * 2. Recalculates authoritative prices and totals from server catalog.
 * 3. Enforces single-quantity constraints on certified antiques.
 * 4. Creates an internal pending ORIGIN order.
 * 5. Creates a corresponding Razorpay order via SDK/API.
 * 6. Returns ONLY public checkout parameters to the client.
 */

const { calculateOrderPricing } = require('./_lib/catalog');
const { createPendingOrder, linkRazorpayOrder } = require('./_lib/order-store');
const { createRazorpayOrder, getCredentials } = require('./_lib/razorpay');

function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(email).trim());
}

module.exports = async function handler(req, res) {
  // CORS & Options handling
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

    const { items, customer, currency = 'USD', shippingMethod, userId } = body;

    // Validate Customer & Delivery Details
    if (!customer || typeof customer !== 'object') {
      return res.status(400).json({ success: false, error: 'Customer and delivery details are required.' });
    }

    const name = String(customer.name || '').trim();
    if (!name || name.length < 2) {
      return res.status(400).json({ success: false, error: 'Please enter a valid legal name for provenance records.' });
    }

    const email = String(customer.email || '').trim();
    if (!validateEmail(email)) {
      return res.status(400).json({ success: false, error: 'Please enter a valid email address for certificate dispatch.' });
    }

    const address = String(customer.address || '').trim();
    if (!address || address.length < 4) {
      return res.status(400).json({ success: false, error: 'Please provide a valid delivery / estate address.' });
    }

    const city = String(customer.city || '').trim();
    if (!city) {
      return res.status(400).json({ success: false, error: 'City is required for diplomatic courier routing.' });
    }

    const country = String(customer.country || '').trim();
    if (!country) {
      return res.status(400).json({ success: false, error: 'Destination country is required for customs clearance.' });
    }

    const postalCode = String(customer.postalCode || '').trim();
    if (!postalCode) {
      return res.status(400).json({ success: false, error: 'Postal or ZIP code is required.' });
    }

    const phone = String(customer.phone || '').trim();

    // Authoritative Server-Side Pricing Calculation
    let pricing;
    try {
      pricing = calculateOrderPricing(items, currency);
    } catch (pricingErr) {
      return res.status(400).json({
        success: false,
        error: pricingErr.message || 'Error calculating order pricing.'
      });
    }

    // Create Internal Pending ORIGIN Order
    const internalOrder = createPendingOrder({
      customer: { name, email, phone, address, city, country, postalCode },
      pricing,
      items: pricing.items,
      shippingMethod: shippingMethod || 'White-Glove Art Courier & Armored Escort',
      userId: userId || 'guest'
    });

    // Create Razorpay Order
    let razorpayOrder;
    try {
      razorpayOrder = await createRazorpayOrder({
        amount: pricing.amountInSubunits,
        currency: pricing.currency,
        receipt: internalOrder.id,
        notes: {
          originOrderId: internalOrder.id,
          customerName: name,
          customerEmail: email
        }
      });
    } catch (rzpErr) {
      console.error('Razorpay order creation failed:', rzpErr.message);
      return res.status(502).json({
        success: false,
        error: 'Unable to initiate payment with Razorpay. Please retry in a moment.'
      });
    }

    // Link Razorpay Order to Internal Order
    linkRazorpayOrder(internalOrder.id, razorpayOrder.id);

    const { keyId } = getCredentials();

    // Return strictly public checkout parameters
    return res.status(200).json({
      success: true,
      orderId: internalOrder.id,
      razorpayOrderId: razorpayOrder.id,
      amount: pricing.amountInSubunits,
      currency: pricing.currency,
      keyId: keyId || 'rzp_test_placeholder_key',
      summary: {
        itemCount: pricing.items.length,
        subtotal: pricing.subtotal,
        shipping: pricing.shippingCost,
        tax: pricing.tax,
        total: pricing.total,
        currency: pricing.currency
      },
      customer: {
        name,
        email,
        phone
      }
    });
  } catch (err) {
    console.error('Order creation error:', err);
    return res.status(500).json({
      success: false,
      error: 'An unexpected internal error occurred while preparing your secure checkout.'
    });
  }
};
