import 'package:flutter/material.dart';
import '../fonts.dart';
import '../../app/theme.dart';
import '../../data/models/product.dart';
import '../../data/repositories/image_registry.dart';
import 'origin_heritage_image.dart';
import 'image_credit_dialog.dart';

class ProductGallery extends StatefulWidget {
  const ProductGallery({
    super.key,
    required this.product,
    this.height = 420,
  });

  final Product product;
  final double height;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  int _selectedAngle = 0;

  List<String> _getGalleryImages() {
    final list = <String>[];
    if (widget.product.localAssetPath != null &&
        widget.product.localAssetPath!.isNotEmpty) {
      list.add(widget.product.localAssetPath!);
    }
    for (final img in widget.product.images) {
      if ((img.startsWith('assets/') ||
              img.startsWith('http://') ||
              img.startsWith('https://')) &&
          !list.contains(img)) {
        list.add(img);
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final images = _getGalleryImages();
    final currentImage =
        images.isNotEmpty ? images[_selectedAngle.clamp(0, images.length - 1)] : null;
    final creditItem = OriginImageRegistry.findByProductId(widget.product.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Stage
        Container(
          height: widget.height,
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
                    colors: [Color(0xFFFFFDF8), Color(0xFFF5EEDB)],
                    radius: 0.9,
                  ),
                ),
              ),

              // Main Photograph with Hero tag
              Hero(
                tag: 'product-${widget.product.id}',
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: currentImage != null
                        ? OriginHeritageImage(
                            localAssetPath: currentImage.startsWith('assets/')
                                ? currentImage
                                : null,
                            networkUrl: currentImage.startsWith('http')
                                ? currentImage
                                : null,
                            artefactCode: widget.product.artefactCode,
                            fit: BoxFit.contain,
                            height: widget.height - 40,
                            semanticLabel: widget.product.name,
                          )
                        : OriginHeritageImage(
                            localAssetPath: widget.product.localAssetPath,
                            artefactCode: widget.product.artefactCode,
                            fit: BoxFit.contain,
                            height: widget.height - 40,
                          ),
                  ),
                ),
              ),

              // Museum Provenance & Rights Badge
              if (creditItem != null)
                Positioned(
                  top: 16,
                  right: 16,
                  child: InkWell(
                    onTap: () => showImageCreditDialog(context, item: creditItem),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: OriginColors.gold, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.museum_outlined,
                              size: 13, color: OriginColors.goldDark),
                          const SizedBox(width: 5),
                          Text(
                            'ARCHIVAL PROVENANCE',
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: OriginColors.goldDark,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(Icons.info_outline,
                              size: 11, color: OriginColors.goldDark),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Angle Thumbnails (if multiple angles available)
        if (images.length > 1) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, idx) {
                final isSelected = idx == _selectedAngle;
                final imgUrl = images[idx];
                return GestureDetector(
                  onTap: () => setState(() => _selectedAngle = idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected
                            ? OriginColors.goldDark
                            : OriginColors.cardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0x289A7440),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: OriginHeritageImage(
                        localAssetPath: imgUrl.startsWith('assets/') ? imgUrl : null,
                        networkUrl: imgUrl.startsWith('http') ? imgUrl : null,
                        artefactCode: widget.product.artefactCode,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
