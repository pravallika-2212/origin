import 'package:flutter/material.dart';
import '../../app/theme.dart';
import 'origin_heritage_image.dart';

class HeroImageSlide {
  const HeroImageSlide({
    required this.title,
    required this.subtitle,
    required this.caption,
    this.localAssetPath,
    this.networkUrl,
    required this.culture,
  });

  final String title;
  final String subtitle;
  final String caption;
  final String? localAssetPath;
  final String? networkUrl;
  final String culture;
}

class HeroImageBanner extends StatelessWidget {
  const HeroImageBanner({
    super.key,
    required this.slide,
    this.height = 480,
    this.child,
  });

  final HeroImageSlide slide;
  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: OriginColors.royalBronze,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background photograph
          OriginHeritageImage(
            localAssetPath: slide.localAssetPath,
            networkUrl: slide.networkUrl,
            fit: BoxFit.cover,
            semanticLabel: '${slide.title} - ${slide.caption}',
          ),

          // Luxury editorial gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.65),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Content overlay
          ?child,
        ],
      ),
    );
  }
}
