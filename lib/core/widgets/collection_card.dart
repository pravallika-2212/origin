import 'package:flutter/material.dart';
import '../fonts.dart';
import '../../app/theme.dart';
import '../../data/models/category.dart';
import 'origin_heritage_image.dart';

class CollectionCard extends StatefulWidget {
  const CollectionCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  final CategoryItem category;
  final VoidCallback onTap;

  @override
  State<CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<CollectionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: _isHovered ? OriginColors.gold : OriginColors.cardBorder,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0x289A7440)
                    : const Color(0x08000000),
                blurRadius: _isHovered ? 24 : 8,
                offset: Offset(0, _isHovered ? 10 : 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image container with subtle hover scale
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Backdrop color
                      Container(color: widget.category.bgColor),

                      // Image with smooth scale
                      AnimatedScale(
                        scale: _isHovered ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        child: OriginHeritageImage(
                          localAssetPath: widget.category.localAssetPath,
                          networkUrl: widget.category.imageUrl,
                          artefactCode: widget.category.artefactCode,
                          fit: BoxFit.cover,
                          semanticLabel: widget.category.name,
                        ),
                      ),

                      // Subtle gradient for contrast
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.28),
                            ],
                            stops: const [0.65, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title and Arrow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w600,
                              color: OriginColors.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.category.tagline,
                            style: GoogleFonts.montserrat(
                              fontSize: 11.5,
                              color: OriginColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _isHovered
                            ? OriginColors.gold
                            : OriginColors.cardBorder.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 11,
                        color: _isHovered ? Colors.white : OriginColors.goldDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
