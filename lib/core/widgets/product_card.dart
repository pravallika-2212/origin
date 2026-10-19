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
import 'artefact_art.dart';
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

  ArtefactType _getArtefactType(String code) {
    switch (code) {
      case 'neck':
        return ArtefactType.neck;
      case 'crown':
        return ArtefactType.crown;
      case 'vase':
        return ArtefactType.vase;
      case 'robe':
        return ArtefactType.robe;
      case 'fan':
        return ArtefactType.fan;
      case 'box':
        return ArtefactType.box;
      case 'chair':
        return ArtefactType.chair;
      case 'ear':
        return ArtefactType.ear;
      default:
        return ArtefactType.lotus;
    }
  }

  Color _getCardColor() {
    if (widget.bgColor != null) return widget.bgColor!;
    switch (widget.product.artefactCode) {
      case 'neck':
        return const Color(0xFFF3E3C4);
      case 'crown':
        return const Color(0xFFF6DCD5);
      case 'vase':
        return const Color(0xFFE6EDF4);
      case 'robe':
        return const Color(0xFFE9E0F3);
      case 'fan':
        return const Color(0xFFF6DCD5);
      case 'box':
        return const Color(0xFFEFE0CC);
      case 'chair':
        return const Color(0xFFE3EBDE);
      case 'ear':
        return const Color(0xFFF3E8D2);
      default:
        return const Color(0xFFF8F1E4);
    }
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _isHovered ? OriginColors.gold : OriginColors.cardBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0x2E785A28)
                  : const Color(0x0A000000),
              blurRadius: _isHovered ? 26 : 10,
              offset: Offset(0, _isHovered ? 12 : 4),
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
                    height: 195,
                    decoration: BoxDecoration(
                      color: _getCardColor(),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    alignment: Alignment.center,
                    child: Hero(
                      tag: 'product-${widget.product.id}',
                      child: ArtefactArt(
                        type: _getArtefactType(widget.product.artefactCode),
                        size: 120,
                      ),
                    ),
                  ),
                ),

                // Tag badge: Antique · Certified or Royal-Inspired
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAntique
                          ? OriginColors.royalBronze
                          : OriginColors.sage,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAntique) ...[
                          const Icon(Icons.verified, size: 11, color: OriginColors.goldLight),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          widget.product.typeLabel.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.white,
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
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isWishlisted ? OriginColors.goldDark : OriginColors.goldDark,
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
                      // Add to Cart
                      Expanded(
                        child: InkWell(
                          onTap: _addToCart,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isFlashingGold
                                  ? OriginColors.gold
                                  : Colors.transparent,
                              border: Border.all(
                                color: OriginColors.goldDark,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _isFlashingGold ? 'ADDED!' : 'ADD TO CART',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.6,
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
