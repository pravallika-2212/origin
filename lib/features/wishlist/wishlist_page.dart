import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/widgets/origin_button.dart';
import '../../core/widgets/origin_footer.dart';
import '../../core/widgets/origin_header.dart';
import '../../core/widgets/product_card.dart';
import '../../data/repositories/wishlist_repository.dart';

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final isMobile = Breakpoints.isMobile(context);

    return Scaffold(
      appBar: const OriginHeader(isScrolled: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner
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
                        'SAVED PIECES',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.8,
                          color: OriginColors.goldDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your Personal Royal Wishlist',
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

            // Wishlist Grid or Empty State
            Container(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: wishlist.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: OriginColors.cardBorder),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.favorite_border, size: 52, color: OriginColors.goldDark),
                          const SizedBox(height: 16),
                          Text(
                            'Your Wishlist is Empty',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: OriginColors.royalBronze,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the heart icon on any piece to save it to your private collection.',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: OriginColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 24),
                          OriginButton(
                            text: 'EXPLORE REPOSITORY',
                            onPressed: () => context.go('/shop'),
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (ctx, constraints) {
                        int cols = 4;
                        if (constraints.maxWidth < 600) {
                          cols = 1;
                        } else if (constraints.maxWidth < 900) {
                          cols = 2;
                        } else if (constraints.maxWidth < 1100) {
                          cols = 3;
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: wishlist.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.68,
                          ),
                          itemBuilder: (ctx, idx) => ProductCard(product: wishlist[idx]),
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
}
