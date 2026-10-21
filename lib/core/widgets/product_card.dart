import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/product.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/currency_provider.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/enquiry/enquiry_dialog.dart';
import 'origin_heritage_image.dart';
import 'origin_toast.dart';

class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.bgColor,
  });

  final Product product;
  final Color? bgColor;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isFlashingGold = false;

  late final AnimationController _heartController;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Heart pop TweenSequence from PRD Section 11.6
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.35).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_heartController);
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }



  Color _getCardColor() {
    if (widget.bgColor != null) return widget.bgColor!;
    return const Color(0xFFF8F5EE);
  }

  Future<void> _toggleWishlist() async {
    final ok = await requireAuth(context, ref, 'save items to your wishlist');
    if (!ok || !mounted) return;

    _heartController.forward(from: 0.0);
    final isAdded = ref.read(wishlistProvider.notifier).toggle(widget.product);
    showOriginToast(
      context,
      isAdded
          ? '${widget.product.name} saved to your wishlist'
          : 'Removed from wishlist',
    );
  }

  Future<void> _addToCart() async {
    final ok = await requireAuth(context, ref, 'add items to your bag');
    if (!ok || !mounted) return;

    final added = ref.read(cartProvider.notifier).add(widget.product);
    if (!added) {
      showOriginToast(
        context,
        'This certified antique is a unique one-of-a-kind piece and is already in your bag.',
      );
      return;
    }

    setState(() => _isFlashingGold = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _isFlashingGold = false);
    });

    showOriginToast(context, '${widget.product.name} added to your bag');
  }

  Future<void> _requestEnquiry() async {
    final ok = await requireAuth(
      context,
      ref,
      'send an enquiry or request a private viewing',
    );
    if (!ok || !mounted) return;

    showEnquiryDialog(context, product: widget.product);
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final isWishlisted = ref.watch(wishlistProvider).any((p) => p.id == widget.product.id);
    final isAntique = widget.product.type == ProductType.certifiedAntique;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: _isHovered ? OriginColors.goldDark : const Color(0x38D4AF7C),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0x24785A28)
                  : const Color(0x0A000000),
              blurRadius: _isHovered ? 24 : 8,
              offset: Offset(0, _isHovered ? 10 : 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Art Stage with Hero tag
            Stack(
              children: [
                GestureDetector(
                  onTap: () => context.go('/product/${widget.product.id}'),
                  child: Container(
                    height: 205,
                    decoration: BoxDecoration(
                      color: _getCardColor(),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                      border: const Border(
                        bottom: BorderSide(color: Color(0x1AD4AF7C), width: 1),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Hero(
                      tag: 'product-${widget.product.id}',
                      child: AnimatedScale(
                        scale: _isHovered ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: OriginHeritageImage(
                            localAssetPath: widget.product.localAssetPath ??
                                (widget.product.images.isNotEmpty &&
                                        widget.product.images.first.startsWith('assets/')
                                    ? widget.product.images.first
                                    : null),
                            networkUrl: widget.product.primaryImage != null &&
                                    widget.product.primaryImage!.startsWith('http')
                                ? widget.product.primaryImage
                                : null,
                            artefactCode: widget.product.artefactCode,
                            fit: BoxFit.contain,
                            height: 175,
                            semanticLabel: widget.product.name,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Tag badge: Antique · Certified or Royal-Inspired
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAntique
                          ? const Color(0xFF2E2214)
                          : const Color(0xFF4A443C),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: isAntique
                            ? const Color(0x80D4AF7C)
                            : const Color(0x40E8DCC7),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAntique) ...[
                          const Icon(Icons.verified, size: 10.5, color: OriginColors.goldLight),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          isAntique ? 'CERTIFIED ANTIQUE' : 'ROYAL REPERTORY',
                          style: GoogleFonts.montserrat(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: isAntique ? OriginColors.goldLight : const Color(0xFFEFE9DA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Wishlist heart button
                Positioned(
                  top: 10,
                  right: 10,
                  child: ScaleTransition(
                    scale: _heartScale,
                    child: InkWell(
                      onTap: _toggleWishlist,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0x38D4AF7C)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 16.5,
                          color: isWishlisted ? OriginColors.goldDark : const Color(0xFF8A7E70),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body Details
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country & Era
                  Text(
                    '${widget.product.country} · ${widget.product.era}'.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      color: OriginColors.goldDark,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Name
                  InkWell(
                    onTap: () => context.go('/product/${widget.product.id}'),
                    child: Text(
                      widget.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: OriginColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    OriginFormatters.formatPrice(widget.product.priceUsd, currency),
                    style: GoogleFonts.montserrat(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: OriginColors.royalBronze,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Action Buttons Row
                  Row(
                    children: [
                      // Acquire / Add to Bag
                      Expanded(
                        child: InkWell(
                          onTap: _addToCart,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 9.5),
                            decoration: BoxDecoration(
                              color: _isFlashingGold
                                  ? OriginColors.goldDark
                                  : (_isHovered
                                      ? OriginColors.gold.withValues(alpha: 0.12)
                                      : Colors.transparent),
                              border: Border.all(
                                color: OriginColors.goldDark,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _isFlashingGold ? 'ADDED TO BAG' : 'ACQUIRE PIECE',
                              style: GoogleFonts.montserrat(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: _isFlashingGold
                                    ? Colors.white
                                    : OriginColors.goldDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Enquire / Viewing button
                      IconButton(
                        onPressed: _requestEnquiry,
                        tooltip: 'Enquire · Private Viewing',
                        icon: const Icon(
                          Icons.visibility_outlined,
                          size: 18,
                          color: OriginColors.royalBronze,
                        ),
                        style: IconButton.styleFrom(
                          side: const BorderSide(color: OriginColors.cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
