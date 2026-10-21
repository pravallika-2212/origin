import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/origin_heritage_image.dart';
import '../../core/widgets/origin_button.dart';
import '../../core/widgets/origin_footer.dart';
import '../../core/widgets/origin_header.dart';
import '../../core/animation/lotus_painter.dart';
import '../../data/models/order.dart';
import '../../data/models/product.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/currency_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final currency = ref.watch(currencyProvider);
    final isMobile = Breakpoints.isMobile(context);

    return Scaffold(
      appBar: const OriginHeader(isScrolled: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF7F0),
                border: Border(bottom: BorderSide(color: OriginColors.cardBorder)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                  child: Column(
                    children: [
                      Text(
                        'SHOPPING BAG',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.8,
                          color: OriginColors.goldDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your Curated Royal Selection',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isMobile ? 28 : 36,
                          fontWeight: FontWeight.w500,
                          color: OriginColors.royalBronze,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Cart Items & Summary
            Container(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: cart.items.isEmpty
                  ? _buildEmptyCart(context)
                  : LayoutBuilder(
                      builder: (ctx, constraints) {
                        final isWide = constraints.maxWidth > 800;
                        final itemsList = _buildCartList(context, ref, cart.items, currency);
                        final summaryPanel = _buildSummaryPanel(context, cart, currency);

                        return isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 6, child: itemsList),
                                  const SizedBox(width: 40),
                                  Expanded(flex: 4, child: summaryPanel),
                                ],
                              )
                            : Column(
                                children: [
                                  itemsList,
                                  const SizedBox(height: 36),
                                  summaryPanel,
                                ],
                              );
                      },
                    ),
            ),

            const OriginFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F3),
        border: Border.all(color: const Color(0x38D4AF7C)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0x40D4AF7C)),
            ),
            child: CustomPaint(
              painter: LotusPainter(
                progress: 1.0,
                strokeWidth: 1.8,
                color: OriginColors.goldDark,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Royal Bag is Unadorned',
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: OriginColors.royalBronze,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Text(
              'No pieces are presently reserved in your session. Explore certified sovereign regalia, heirloom jewels, and court treasures in the curated repository.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13.5,
                height: 1.6,
                color: OriginColors.inkLight,
              ),
            ),
          ),
          const SizedBox(height: 32),
          OriginButton(
            text: 'EXPLORE THE ROYAL REPERTORY',
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            onPressed: () => context.go('/shop'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(
    BuildContext context,
    WidgetRef ref,
    List<OrderItem> items,
    Currency currency,
  ) {
    return Column(
      children: [
        for (final item in items)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: OriginColors.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product Thumbnail
                GestureDetector(
                  onTap: () => context.go('/product/${item.product.id}'),
                  child: Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: OriginColors.ivoryDark,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: OriginColors.cardBorder),
                    ),
                    alignment: Alignment.center,
                    child: OriginHeritageImage(
                      localAssetPath: item.product.localAssetPath,
                      networkUrl: item.product.primaryImage,
                      artefactCode: item.product.artefactCode,
                      fit: BoxFit.contain,
                      semanticLabel: item.product.name,
                    ),
                  ),
                ),
                const SizedBox(width: 18),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: item.product.type == ProductType.certifiedAntique
                                  ? OriginColors.royalBronze
                                  : OriginColors.sage,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              item.product.typeLabel.toUpperCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.product.country,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: OriginColors.goldDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => context.go('/product/${item.product.id}'),
                        child: Text(
                          item.product.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: OriginColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        OriginFormatters.formatPrice(item.priceUsd, currency),
                        style: GoogleFonts.montserrat(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: OriginColors.royalBronze,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quantity controls
                if (item.product.type == ProductType.certifiedAntique)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: OriginColors.ivoryDark,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'Qty: 1 (Unique)',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: OriginColors.royalBronze,
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: () {
                          ref.read(cartProvider.notifier).updateQuantity(item.product.id, -1);
                        },
                      ),
                      Text(
                        '${item.quantity}',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () {
                          ref.read(cartProvider.notifier).updateQuantity(item.product.id, 1);
                        },
                      ),
                    ],
                  ),

                // Remove button
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: OriginColors.inkMuted),
                  onPressed: () {
                    ref.read(cartProvider.notifier).remove(item.product.id);
                  },
                  tooltip: 'Remove',
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryPanel(
    BuildContext context,
    CartState cart,
    Currency currency,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: OriginColors.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ORDER SUMMARY',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: OriginColors.goldDark,
            ),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal (${cart.totalItemCount} pieces)', style: GoogleFonts.montserrat(fontSize: 13)),
              Text(
                OriginFormatters.formatPrice(cart.subtotalUsd, currency),
                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('White-Glove Art Courier', style: GoogleFonts.montserrat(fontSize: 13)),
              Text(
                cart.shippingCostUsd == 0 ? 'Complimentary' : OriginFormatters.formatPrice(cart.shippingCostUsd, currency),
                style: GoogleFonts.montserrat(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: cart.shippingCostUsd == 0 ? OriginColors.sage : OriginColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Estimated',
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                OriginFormatters.formatPrice(cart.totalUsd, currency),
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: OriginColors.royalBronze,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          OriginButton(
            text: 'PROCEED TO CHECKOUT',
            isFullWidth: true,
            onPressed: () => context.go('/checkout'),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 14, color: OriginColors.goldDark),
              const SizedBox(width: 6),
              Text(
                'Armored transport & export permit guaranteed',
                style: GoogleFonts.montserrat(fontSize: 11, color: OriginColors.inkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
