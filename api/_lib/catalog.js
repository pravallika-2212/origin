/**
 * ORIGIN Authoritative Product Catalog & Server-Side Pricing Engine
 * 
 * SECURITY MANDATE:
 * Never trust prices, totals, discounts, or shipping values from client requests.
 * All amounts must be authoritatively calculated on the server.
 */

const AUTHORITATIVE_PRODUCTS = {
  'prod-1': {
    id: 'prod-1',
    name: 'Mughal Kundan & Emerald Ceremonial Necklace',
    priceUsd: 18500,
    type: 'certifiedAntique',
    category: 'Imperial Jewels'
  },
  'prod-2': {
    id: 'prod-2',
    name: 'Joseon Dynasty Embroidered Court Robe (Wonsam)',
    priceUsd: 14200,
    type: 'certifiedAntique',
    category: 'Royal Wardrobe'
  },
  'prod-3': {
    id: 'prod-3',
    name: 'Imperial Ming Cobalt Blue & White Porcelain Vase',
    priceUsd: 22800,
    type: 'certifiedAntique',
    category: 'Dining & Tableware'
  },
  'prod-4': {
    id: 'prod-4',
    name: 'Habsburg Ceremonial Archducal Diadem',
    priceUsd: 19500,
    type: 'certifiedAntique',
    category: 'Imperial Jewels'
  },
  'prod-5': {
    id: 'prod-5',
    name: 'Isfahan Khatamkari Royal Inlaid Casket',
    priceUsd: 6800,
    type: 'certifiedAntique',
    category: 'Treasures of the World'
  },
  'prod-6': {
    id: 'prod-6',
    name: 'Kyoto Heian Imperial Court Fan & Maki-e Lacquer',
    priceUsd: 3850,
    type: 'royalInspired',
    category: 'Bags & Accessories'
  },
  'prod-7': {
    id: 'prod-7',
    name: 'Royal Sapphire & Gold Filigree Ear Pendants',
    priceUsd: 1299,
    type: 'royalInspired',
    category: 'Imperial Jewels'
  },
  'prod-8': {
    id: 'prod-8',
    name: 'Versailles Giltwood Console Table',
    priceUsd: 3299,
    type: 'royalInspired',
    category: 'Palace Living'
  },
  'prod-9': {
    id: 'prod-9',
    name: 'Empress Zhaosheng Pure Mulberry Silk Saree',
    priceUsd: 2499,
    type: 'royalInspired',
    category: 'Royal Wardrobe'
  },
  'prod-10': {
    id: 'prod-10',
    name: 'Pre-Columbian Chimú Gold Funerary Plaque & Regalia',
    priceUsd: 26000,
    type: 'certifiedAntique',
    category: 'Treasures of the World'
  },
  'prod-11': {
    id: 'prod-11',
    name: 'Imperial Qing Nine-Dragon Brocade Court Robe',
    priceUsd: 31000,
    type: 'certifiedAntique',
    category: 'Royal Wardrobe'
  },
  'prod-12': {
    id: 'prod-12',
    name: 'Mughal Imperial Nephrite Jade & Emerald Dagger',
    priceUsd: 16500,
    type: 'certifiedAntique',
    category: 'Treasures of the World'
  },
  'prod-13': {
    id: 'prod-13',
    name: 'Edo Imperial Court Silk Kimono with Blossoming Plum',
    priceUsd: 11500,
    type: 'certifiedAntique',
    category: 'Royal Wardrobe'
  },
  'prod-14': {
    id: 'prod-14',
    name: 'French Sèvres Royal Porcelain Vase with Ormolu Mounts',
    priceUsd: 15800,
    type: 'certifiedAntique',
    category: 'Dining & Tableware'
  },
  'prod-15': {
    id: 'prod-15',
    name: 'Ottoman Imperial Silk Velvet with Pinecone Pattern',
    priceUsd: 13900,
    type: 'certifiedAntique',
    category: 'Treasures of the World'
  },
  'prod-16': {
    id: 'prod-16',
    name: 'Kingdom of Benin Court Regalia Plaque in Cast Brass',
    priceUsd: 34000,
    type: 'certifiedAntique',
    category: 'Treasures of the World'
  },
  'prod-17': {
    id: 'prod-17',
    name: 'Asante Empire Pure Gold Royal Lion Ornament',
    priceUsd: 12400,
    type: 'certifiedAntique',
    category: 'Treasures of the World'
  },
  'prod-18': {
    id: 'prod-18',
    name: 'Royal Palembang Silk & Pure Gold Songket Textile',
    priceUsd: 4600,
    type: 'royalInspired',
    category: 'Royal Wardrobe'
  },
  'prod-19': {
    id: 'prod-19',
    name: 'French Haute Couture Royal Court Presentation Ensemble',
    priceUsd: 19800,
    type: 'certifiedAntique',
    category: 'Royal Wardrobe'
  },
  'prod-20': {
    id: 'prod-20',
    name: 'Samarkand Royal Silk Suzani Embroidered Canopy',
    priceUsd: 8400,
    type: 'certifiedAntique',
    category: 'Treasures of the World'
  }
};

const USD_TO_INR_RATE = 85.0;

/**
 * Validates cart items and calculates authoritative order pricing.
 * @param {Array<{productId?: string, id?: string, quantity: number}>} items
 * @param {string} requestedCurrency 'USD' or 'INR'
 * @returns {object} Authoritative pricing breakdown
 */
function calculateOrderPricing(items, requestedCurrency = 'USD') {
  if (!Array.isArray(items) || items.length === 0) {
    throw new Error('Bag is empty. At least one item is required.');
  }

  const currency = requestedCurrency.toUpperCase() === 'INR' ? 'INR' : 'USD';
  let subtotalUsd = 0;
  const validatedItems = [];

  for (const item of items) {
    const productId = item.productId || item.id;
    if (!productId || typeof productId !== 'string') {
      throw new Error('Invalid product specification in cart item.');
    }

    const catalogProduct = AUTHORITATIVE_PRODUCTS[productId];
    if (!catalogProduct) {
      throw new Error(`Product '${productId}' not found in official ORIGIN repository.`);
    }

    const quantity = parseInt(item.quantity, 10);
    if (!Number.isInteger(quantity) || quantity <= 0) {
      throw new Error(`Invalid quantity (${item.quantity}) for product '${catalogProduct.name}'.`);
    }

    // Single-quantity constraint enforcement for unique certified antiques
    if (catalogProduct.type === 'certifiedAntique' && quantity > 1) {
      throw new Error(
        `Certified Antique '${catalogProduct.name}' is a unique museum-grade accession; maximum quantity is strictly 1.`
      );
    }

    const itemTotalUsd = catalogProduct.priceUsd * quantity;
    subtotalUsd += itemTotalUsd;

    validatedItems.push({
      productId: catalogProduct.id,
      name: catalogProduct.name,
      type: catalogProduct.type,
      category: catalogProduct.category,
      unitPriceUsd: catalogProduct.priceUsd,
      quantity,
      itemTotalUsd
    });
  }

  // Shipping rule: Complimentary for acquisitions over $10,000 USD; otherwise $150 USD white-glove transport
  const shippingCostUsd = subtotalUsd > 10000 ? 0.0 : 150.0;
  const taxUsd = 0.0;
  const totalUsd = subtotalUsd + shippingCostUsd + taxUsd;

  let subtotal = subtotalUsd;
  let shippingCost = shippingCostUsd;
  let tax = taxUsd;
  let total = totalUsd;
  let amountInSubunits = 0;

  if (currency === 'INR') {
    subtotal = Math.round(subtotalUsd * USD_TO_INR_RATE);
    shippingCost = Math.round(shippingCostUsd * USD_TO_INR_RATE);
    tax = 0.0;
    total = subtotal + shippingCost;
    // Razorpay INR amounts are in paise (1 INR = 100 paise)
    amountInSubunits = Math.round(total * 100);
  } else {
    // Razorpay USD amounts are in cents (1 USD = 100 cents)
    amountInSubunits = Math.round(total * 100);
  }

  return {
    items: validatedItems,
    currency,
    subtotal,
    shippingCost,
    tax,
    total,
    subtotalUsd,
    shippingCostUsd,
    totalUsd,
    amountInSubunits,
    exchangeRate: currency === 'INR' ? USD_TO_INR_RATE : 1.0
  };
}

module.exports = {
  AUTHORITATIVE_PRODUCTS,
  USD_TO_INR_RATE,
  calculateOrderPricing
};
