import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/artefact_art.dart';
import '../../core/widgets/origin_button.dart';
import '../../core/widgets/origin_footer.dart';
import '../../core/widgets/origin_header.dart';
import '../../core/widgets/origin_toast.dart';
import '../../core/widgets/product_card.dart';
import '../../data/models/enquiry.dart';
import '../../data/models/product.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/currency_provider.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../auth/auth_controller.dart';
import '../enquiry/enquiry_dialog.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  double _rotateAngle = 0.0;
  bool _isFlashingGold = false;

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

  void _showCertificateModal(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 580),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFAF2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: OriginColors.goldDark, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x662E2414),
                blurRadius: 36,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Certificate Header with Lotus Seal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  Column(
                    children: [
                      const Icon(Icons.verified, color: OriginColors.goldDark, size: 36),
                      const SizedBox(height: 6),
                      Text(
                        'ORIGIN IMPERIAL VAULT',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.8,
                          color: OriginColors.royalBronze,
                        ),
                      ),
                      Text(
                        'Official Certificate of Provenance & Authenticity',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: OriginColors.royalBronze,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: OriginColors.gold),
              const SizedBox(height: 16),

              Text(
                'CERTIFICATE IDENTIFIER: #${product.id.toUpperCase()}-VERIFIED',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: OriginColors.goldDark,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                product.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: OriginColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Court & Period: ${product.era} · ${product.country}',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: OriginColors.inkMuted,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: OriginColors.cardBorder),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VERIFIED PROVENANCE AUDIT',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: OriginColors.goldDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final item in product.provenance)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: OriginColors.goldDark)),
                            Expanded(
                              child: Text(
                                item,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: OriginColors.inkLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Alistair Sterling, F.R.S.A.',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Chief Antiquities Examiner',
                        style: GoogleFonts.montserrat(fontSize: 10, color: OriginColors.inkMuted),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'UNESCO 1970 Compliant',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: OriginColors.royalBronze,
                        ),
                      ),
                      Text(
                        'Sealed in Vault 14, Zurich',
                        style: GoogleFonts.montserrat(fontSize: 10, color: OriginColors.inkMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              OriginButton(
                text: 'DOWNLOAD OFFICIAL PDF CERTIFICATE',
                isFullWidth: true,
                onPressed: () {
                  Navigator.pop(ctx);
                  showOriginToast(context, 'Downloading Certificate of Provenance PDF...');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart(Product product) async {
    final ok = await requireAuth(context, ref, 'add items to your bag');
    if (!ok || !mounted) return;

    final added = ref.read(cartProvider.notifier).add(product);
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

    showOriginToast(context, '${product.name} added to your bag');
  }

  Future<void> _toggleWishlist(Product product) async {
    final ok = await requireAuth(context, ref, 'save items to your wishlist');
    if (!ok || !mounted) return;

    final isAdded = ref.read(wishlistProvider.notifier).toggle(product);
    showOriginToast(
      context,
      isAdded ? '${product.name} saved to your wishlist' : 'Removed from wishlist',
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productRepositoryProvider.notifier).getById(widget.productId);
    final currency = ref.watch(currencyProvider);
    final wishlist = ref.watch(wishlistProvider);

    if (product == null) {
      return Scaffold(
        appBar: const OriginHeader(isScrolled: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 48, color: OriginColors.goldDark),
              const SizedBox(height: 16),
              Text(
                'Royal Piece Not Found',
                style: GoogleFonts.playfairDisplay(fontSize: 24),
              ),
              const SizedBox(height: 16),
              OriginButton(
                text: 'BACK TO SHOP',
                onPressed: () => context.go('/shop'),
              ),
            ],
          ),
        ),
      );
    }

    final isWishlisted = wishlist.any((p) => p.id == product.id);
    final isAntique = product.type == ProductType.certifiedAntique;
    final allProducts = ref.watch(productRepositoryProvider);
    final related = allProducts
        .where((p) => p.id != product.id && (p.civilization == product.civilization || p.category == product.category))
        .take(3)
        .toList();

    return Scaffold(
      appBar: const OriginHeader(isScrolled: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Breadcrumbs Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF7F0),
                border: Border(bottom: BorderSide(color: OriginColors.cardBorder)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => context.go('/'),
                        child: Text(
                          'Home',
                          style: GoogleFonts.montserrat(fontSize: 12, color: OriginColors.inkMuted),
                        ),
                      ),
                      const Text('  /  ', style: TextStyle(color: OriginColors.inkMuted)),
                      InkWell(
                        onTap: () => context.go('/shop'),
                        child: Text(
                          'Shop',
                          style: GoogleFonts.montserrat(fontSize: 12, color: OriginColors.inkMuted),
                        ),
                      ),
                      const Text('  /  ', style: TextStyle(color: OriginColors.inkMuted)),
                      InkWell(
                        onTap: () => context.go('/shop?category=${Uri.encodeComponent(product.category)}'),
                        child: Text(
                          product.category,
                          style: GoogleFonts.montserrat(fontSize: 12, color: OriginColors.inkMuted),
                        ),
                      ),
                      const Text('  /  ', style: TextStyle(color: OriginColors.inkMuted)),
                      Expanded(
                        child: Text(
                          product.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: OriginColors.royalBronze,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Product Main Display Area
            Container(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final isWide = constraints.maxWidth > 850;

                  final galleryStage = _buildGalleryStage(product);
                  final detailsPanel = _buildDetailsPanel(product, currency, isAntique, isWishlisted);

                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: galleryStage),
                            const SizedBox(width: 48),
                            Expanded(flex: 5, child: detailsPanel),
                          ],
                        )
                      : Column(
                          children: [
                            galleryStage,
                            const SizedBox(height: 36),
                            detailsPanel,
                          ],
                        );
                },
              ),
            ),

            const Divider(color: OriginColors.cardBorder),

            // Story of the Piece & Provenance Section
            Container(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HISTORICAL PROVENANCE & LORE',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.6,
                      color: OriginColors.goldDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Story of the Piece',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: OriginColors.royalBronze,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    product.story,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      height: 1.8,
                      color: OriginColors.ink,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Chronological Provenance Chain
                  if (product.provenance.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: OriginColors.cardBorder),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.history_edu, color: OriginColors.goldDark, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                'Documented Chain of Ownership',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: OriginColors.royalBronze,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          for (int i = 0; i < product.provenance.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: OriginColors.ivoryDark,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${i + 1}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: OriginColors.goldDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      product.provenance[i],
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13.5,
                                        height: 1.5,
                                        color: OriginColors.inkLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],

                  // Shipping & Export Legality Notice
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: OriginColors.sageLight.withValues(alpha: 0.6),
                      border: Border.all(color: OriginColors.sage),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined, color: OriginColors.royalBronze, size: 24),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'INTERNATIONAL EXPORT & CULTURAL HERITAGE NOTICE',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: OriginColors.royalBronze,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Genuine antiques exceeding 100 years of age require export permits pursuant to origin state legislation (such as India Antiquities and Art Treasures Act 1972 and UNESCO 1970 Convention). Our white-glove logistics council verifies all origin export licenses prior to final billing and shipment.',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12.5,
                                  height: 1.5,
                                  color: OriginColors.inkLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Related Pieces from same civilization
            if (related.isNotEmpty) ...[
              const Divider(color: OriginColors.cardBorder),
              Container(
                constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DISCOVER RELATED TREASURES',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.4,
                        color: OriginColors.goldDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'More from ${product.civilization}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: OriginColors.royalBronze,
                      ),
                    ),
                    const SizedBox(height: 28),
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        int cols = 3;
                        if (constraints.maxWidth < 650) {
                          cols = 1;
                        } else if (constraints.maxWidth < 950) {
                          cols = 2;
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: related.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.68,
                          ),
                          itemBuilder: (ctx, idx) => ProductCard(product: related[idx]),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],

            // Footer
            const OriginFooter(),
          ],
        ),
      ),
    );
  }

  // Gallery Stage with Hero & 360-degree rotation view
  Widget _buildGalleryStage(Product product) {
    return Column(
      children: [
        Container(
          height: 440,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: OriginColors.cardBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Radial backdrop
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0xFFFFFBF0), Colors.white],
                    radius: 0.8,
                  ),
                ),
              ),

              // Hero Interactive 360 Artefact
              Hero(
                tag: 'product-${product.id}',
                child: ArtefactArt(
                  type: _getArtefactType(product.artefactCode),
                  size: 260,
                  rotationAngle: _rotateAngle,
                ),
              ),

              // 360 Badge in top-left
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: OriginColors.ivoryDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: OriginColors.gold.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sync, size: 14, color: OriginColors.goldDark),
                      const SizedBox(width: 6),
                      Text(
                        '360° INTERACTIVE VIEW',
                        style: GoogleFonts.montserrat(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: OriginColors.royalBronze,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Interactive 360 Rotation Slider
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: OriginColors.cardBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.rotate_left, size: 18, color: OriginColors.goldDark),
              Expanded(
                child: Slider(
                  value: _rotateAngle,
                  min: -pi,
                  max: pi,
                  activeColor: OriginColors.goldDark,
                  inactiveColor: OriginColors.ivoryDark,
                  onChanged: (val) {
                    setState(() => _rotateAngle = val);
                  },
                ),
              ),
              const Icon(Icons.rotate_right, size: 18, color: OriginColors.goldDark),
              const SizedBox(width: 8),
              Text(
                'DRAG TO ROTATE',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: OriginColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Product Details Panel
  Widget _buildDetailsPanel(
    Product product,
    Currency currency,
    bool isAntique,
    bool isWishlisted,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag badge row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isAntique ? OriginColors.royalBronze : OriginColors.sage,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                product.typeLabel.toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${product.country} · ${product.era}'.toUpperCase(),
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
                color: OriginColors.goldDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Product Name
        Text(
          product.name,
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: OriginColors.ink,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 16),

        // Price & Currency Toggle
        Row(
          children: [
            Text(
              OriginFormatters.formatPrice(product.priceUsd, currency),
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: OriginColors.royalBronze,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Duty & Armored Insurance Included',
              style: GoogleFonts.montserrat(
                fontSize: 11.5,
                color: OriginColors.inkMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Specification Specifications Box
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: OriginColors.cardBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              _buildSpecRow('Materials', product.material),
              const Divider(height: 20),
              _buildSpecRow('Dimensions', product.dimensions),
              const Divider(height: 20),
              _buildSpecRow('Condition', product.condition),
              const Divider(height: 20),
              _buildSpecRow(
                'Status',
                product.status == ProductStatus.available ? 'Vault Available (In stock)' : 'Reserved / Sold',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Certificate preview button if Antique
        if (isAntique) ...[
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: OriginColors.goldDark),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            ),
            icon: const Icon(Icons.verified, size: 18, color: OriginColors.goldDark),
            label: Text(
              'VIEW OFFICIAL CERTIFICATE OF PROVENANCE',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: OriginColors.goldDark,
              ),
            ),
            onPressed: () => _showCertificateModal(product),
          ),
          const SizedBox(height: 24),
        ],

        // Action Buttons Row (Add to Cart & Wishlist)
        Row(
          children: [
            Expanded(
              child: OriginButton(
                text: _isFlashingGold ? 'ADDED TO BAG' : 'ADD TO BAG',
                padding: const EdgeInsets.symmetric(vertical: 16),
                fontSize: 13,
                onPressed: () => _addToCart(product),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: OriginColors.goldDark,
                size: 24,
              ),
              style: IconButton.styleFrom(
                side: const BorderSide(color: OriginColors.goldDark),
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () => _toggleWishlist(product),
              tooltip: 'Save to Wishlist',
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Secondary Action: Enquire & Private Viewing / Make an Offer
        Row(
          children: [
            Expanded(
              child: OriginButton(
                text: 'ENQUIRE · PRIVATE VIEWING',
                variant: OriginButtonVariant.outlined,
                padding: const EdgeInsets.symmetric(vertical: 14),
                fontSize: 11.5,
                onPressed: () async {
                  final ok = await requireAuth(
                    context,
                    ref,
                    'send an enquiry or request a private viewing',
                  );
                  if (!ok || !mounted) return;
                  showEnquiryDialog(context, product: product);
                },
              ),
            ),
            if (isAntique) ...[
              const SizedBox(width: 10),
              Expanded(
                child: OriginButton(
                  text: 'MAKE AN OFFER',
                  variant: OriginButtonVariant.outlined,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  fontSize: 11.5,
                  onPressed: () async {
                    final ok = await requireAuth(
                      context,
                      ref,
                      'make a purchase offer on this rare antique',
                    );
                    if (!ok || !mounted) return;
                    showEnquiryDialog(
                      context,
                      product: product,
                      initialKind: EnquiryKind.makeOffer,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: OriginColors.inkMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: OriginColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
