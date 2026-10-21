const test = require('node:test');
const assert = require('node:assert/strict');
const { calculateOrderPricing, AUTHORITATIVE_PRODUCTS } = require('../_lib/catalog');

test('Catalog & Pricing: calculates authoritative price for single antique', () => {
  const items = [{ productId: 'prod-1', quantity: 1 }];
  const result = calculateOrderPricing(items, 'USD');

  assert.equal(result.items.length, 1);
  assert.equal(result.items[0].unitPriceUsd, 18500);
  assert.equal(result.subtotalUsd, 18500);
  // Over $10,000 USD -> complimentary shipping
  assert.equal(result.shippingCostUsd, 0);
  assert.equal(result.totalUsd, 18500);
  assert.equal(result.amountInSubunits, 1850000); // 18,500 * 100 cents
});

test('Catalog & Pricing: applies $150 shipping when subtotal <= $10,000 USD', () => {
  const items = [{ productId: 'prod-7', quantity: 1 }]; // $1,299
  const result = calculateOrderPricing(items, 'USD');

  assert.equal(result.subtotalUsd, 1299);
  assert.equal(result.shippingCostUsd, 150);
  assert.equal(result.totalUsd, 1449);
  assert.equal(result.amountInSubunits, 144900);
});

test('Catalog & Pricing: strictly rejects quantity > 1 for certified antiques', () => {
  const items = [{ productId: 'prod-1', quantity: 2 }]; // prod-1 is certified antique
  assert.throws(
    () => calculateOrderPricing(items, 'USD'),
    /unique museum-grade accession; maximum quantity is strictly 1/
  );
});

test('Catalog & Pricing: allows multiple quantity for royal-inspired items', () => {
  const items = [{ productId: 'prod-6', quantity: 3 }]; // prod-6 is royalInspired ($3,850)
  const result = calculateOrderPricing(items, 'USD');

  assert.equal(result.items[0].quantity, 3);
  assert.equal(result.subtotalUsd, 3850 * 3);
  assert.equal(result.shippingCostUsd, 0); // 11,550 > 10,000
  assert.equal(result.totalUsd, 11550);
});

test('Catalog & Pricing: ignores any client-supplied prices or discounts', () => {
  const items = [
    {
      productId: 'prod-7',
      quantity: 1,
      priceUsd: 1, // Fraudulent client attempt
      discount: 1000,
      total: 1
    }
  ];
  const result = calculateOrderPricing(items, 'USD');
  // Authoritative price is $1,299, plus $150 shipping
  assert.equal(result.items[0].unitPriceUsd, 1299);
  assert.equal(result.totalUsd, 1449);
});

test('Catalog & Pricing: converts accurately to INR currency and paise subunits', () => {
  const items = [{ productId: 'prod-7', quantity: 1 }]; // $1,299 USD
  const result = calculateOrderPricing(items, 'INR');

  const expectedSubtotalInr = 1299 * 85;
  const expectedShippingInr = 150 * 85;
  const expectedTotalInr = expectedSubtotalInr + expectedShippingInr;

  assert.equal(result.currency, 'INR');
  assert.equal(result.subtotal, expectedSubtotalInr);
  assert.equal(result.shippingCost, expectedShippingInr);
  assert.equal(result.total, expectedTotalInr);
  assert.equal(result.amountInSubunits, expectedTotalInr * 100); // in paise
});

test('Catalog & Pricing: rejects unknown products and negative quantities', () => {
  assert.throws(() => calculateOrderPricing([], 'USD'), /Bag is empty/);
  assert.throws(() => calculateOrderPricing([{ productId: 'unknown-id', quantity: 1 }], 'USD'), /not found/);
  assert.throws(() => calculateOrderPricing([{ productId: 'prod-7', quantity: 0 }], 'USD'), /Invalid quantity/);
  assert.throws(() => calculateOrderPricing([{ productId: 'prod-7', quantity: -2 }], 'USD'), /Invalid quantity/);
});
