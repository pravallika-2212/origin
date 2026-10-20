import 'package:flutter/material.dart';
import '../../app/theme.dart';
import 'artefact_art.dart';

/// Luxury heritage image loader supporting local assets, remote URLs,
/// smooth loading shimmer, and graceful fallback to procedural royal art.
class OriginHeritageImage extends StatefulWidget {
  const OriginHeritageImage({
    super.key,
    this.localAssetPath,
    this.networkUrl,
    this.artefactCode,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.semanticLabel,
    this.showArchivalBadge = false,
    this.onTap,
  });

  final String? localAssetPath;
  final String? networkUrl;
  final String? artefactCode;
  final double? aspectRatio;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final String? semanticLabel;
  final bool showArchivalBadge;
  final VoidCallback? onTap;

  @override
  State<OriginHeritageImage> createState() => _OriginHeritageImageState();
}

class _OriginHeritageImageState extends State<OriginHeritageImage>
    with SingleTickerProviderStateMixin {
  bool _hasError = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void didUpdateWidget(OriginHeritageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localAssetPath != widget.localAssetPath ||
        oldWidget.networkUrl != widget.networkUrl) {
      _hasError = false;
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  ArtefactType _getArtefactType(String? code) {
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

  Widget _buildFallbackArt() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E8),
        borderRadius: widget.borderRadius,
        border: Border.all(
          color: OriginColors.gold.withValues(alpha: 0.3),
        ),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFFFFFBF0), Color(0xFFF2E6CE)],
                radius: 0.85,
              ),
            ),
          ),
          ArtefactArt(
            type: _getArtefactType(widget.artefactCode),
            size: (widget.height != null && widget.height! > 0)
                ? (widget.height! * 0.55).clamp(40.0, 180.0)
                : 90.0,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              OriginColors.gold.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (_hasError) {
      imageWidget = _buildFallbackArt();
    } else if (widget.localAssetPath != null &&
        widget.localAssetPath!.isNotEmpty) {
      imageWidget = Image.asset(
        widget.localAssetPath!,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        semanticLabel: widget.semanticLabel,
        errorBuilder: (context, error, stackTrace) {
          // Fall back to remote URL or procedural art
          if (widget.networkUrl != null && widget.networkUrl!.isNotEmpty) {
            return Image.network(
              widget.networkUrl!,
              fit: widget.fit,
              width: widget.width,
              height: widget.height,
              errorBuilder: (_, _, _) => _buildFallbackArt(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildShimmerLoading();
              },
            );
          }
          return _buildFallbackArt();
        },
      );
    } else if (widget.networkUrl != null && widget.networkUrl!.isNotEmpty) {
      imageWidget = Image.network(
        widget.networkUrl!,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        semanticLabel: widget.semanticLabel,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildShimmerLoading();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackArt();
        },
      );
    } else {
      imageWidget = _buildFallbackArt();
    }

    Widget content = FadeTransition(
      opacity: _fadeAnimation,
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: imageWidget,
      ),
    );

    if (widget.aspectRatio != null) {
      content = AspectRatio(
        aspectRatio: widget.aspectRatio!,
        child: content,
      );
    }

    if (widget.onTap != null) {
      content = GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: content,
        ),
      );
    }

    return content;
  }
}
