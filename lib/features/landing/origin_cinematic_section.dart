import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/fonts.dart';
import '../../core/utils/breakpoints.dart';

/// ORIGIN Cinematic Scroll Section
/// Recreates the interactive sequence from "ORIGIN_ cinematic sequence preview.html":
/// - Sticky full-viewport cinematic stage inside a tall scroll track
/// - Overlapping storytelling scenes driven by user scroll progress
/// - Dynamic ember lighting, firelight sweep, and celestial golden ring animations
/// - Authentic editorial museum photographs with elegant clip-path / scale transitions
/// - Seamless fade into ORIGIN's refined light luxury collection section
class OriginCinematicSection extends StatefulWidget {
  const OriginCinematicSection({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  State<OriginCinematicSection> createState() => _OriginCinematicSectionState();
}

class _OriginCinematicSectionState extends State<OriginCinematicSection> {
  final GlobalKey _trackKey = GlobalKey();
  double _progress = 0.0;
  double _stickyOffset = 0.0;
  bool _isNearViewport = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final renderBox = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final viewportHeight = MediaQuery.of(context).size.height;
    final trackHeight = renderBox.size.height;
    final pos = renderBox.localToGlobal(Offset.zero);
    final top = pos.dy;

    // Check if track is within visible window
    final isNear = (top < viewportHeight + 100) && (top + trackHeight > -100);
    if (isNear != _isNearViewport) {
      setState(() => _isNearViewport = isNear);
    }
    if (!isNear) return;

    final maxScroll = trackHeight - viewportHeight;
    if (maxScroll > 0) {
      final p = ((-top) / maxScroll).clamp(0.0, 1.0);
      final offset = (-top).clamp(0.0, maxScroll);
      if ((p - _progress).abs() > 0.0005 || (_stickyOffset - offset).abs() > 0.5) {
        setState(() {
          _progress = p;
          _stickyOffset = offset;
        });
      }
    }
  }

  // Smoothstep easing math identical to the prototype
  static double _clamp(double x, [double a = 0.0, double b = 1.0]) {
    return x < a ? a : (x > b ? b : x);
  }

  static double _ease(double t) {
    return t * t * (3.0 - 2.0 * t);
  }

  static double _ramp(double p, double a, double b) {
    if (b <= a) return 0.0;
    return _ease(_clamp((p - a) / (b - a)));
  }

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.of(context).size.height;
    final isReducedMotion = Breakpoints.isReducedMotion(context);
    final isMobile = Breakpoints.isMobile(context);

    // Height of scroll track (3.8x viewport on desktop, 3.2x on mobile)
    final trackHeight = isReducedMotion ? viewportHeight : viewportHeight * (isMobile ? 3.2 : 3.8);

    return Column(
      children: [
        // 1. TALL SCROLL TRACK WITH STICKY CINEMATIC STAGE
        SizedBox(
          key: _trackKey,
          height: trackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: isReducedMotion ? 0 : _stickyOffset,
                left: 0,
                right: 0,
                height: viewportHeight,
                child: _buildCinematicStage(
                  progress: isReducedMotion ? 0.75 : _progress,
                  viewportHeight: viewportHeight,
                  isMobile: isMobile,
                  isReducedMotion: isReducedMotion,
                ),
              ),
            ],
          ),
        ),

        // 2. CLOSING COLLECTION SECTION
        _buildClosingCollectionSection(context, isMobile),
      ],
    );
  }

  Widget _buildCinematicStage({
    required double progress,
    required double viewportHeight,
    required bool isMobile,
    required bool isReducedMotion,
  }) {
    final p = progress;

    // Atmospheric lighting calculations
    final emberOpacity = (_ramp(p, 0.0, 0.10) * (1.0 - _ramp(p, 0.50, 0.70))).clamp(0.0, 1.0);
    final emberScale = 1.0 + _ramp(p, 0.20, 0.55) * 0.40;

    final sweepProgress = _ramp(p, 0.18, 0.50);
    final sweepOpacity = (math.sin(math.pi * sweepProgress) * 0.55).clamp(0.0, 1.0);
    final sweepScale = 0.05 + sweepProgress * 0.95;

    final ringsAlpha = _ramp(p, 0.66, 0.82);
    final ringsFade = 1.0 - _ramp(p, 0.88, 0.95);
    final ringsOpacity = (ringsAlpha * ringsFade).clamp(0.0, 1.0);
    final ringsScale = 0.90 + ringsAlpha * 0.10 + (1.0 - ringsFade) * -0.15;

    // Fade to Royal Ivory at the end of the cinematic sequence
    final ivoryFade = _ramp(p, 0.90, 1.0);

    return Container(
      color: const Color(0xFF17120F), // Soft Charcoal base
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Background Burgundy Radial Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.2),
                  radius: 1.1,
                  colors: [
                    Color(0xFF3A0F1A), // Muted Burgundy
                    Color(0xFF17120F), // Charcoal
                  ],
                  stops: [0.35, 0.85],
                ),
              ),
            ),
          ),

          // Warm Amber Ember Light (Active in Scenes 1 & 2)
          if (!isReducedMotion && emberOpacity > 0.005)
            Center(
              child: Transform.scale(
                scale: emberScale,
                child: Opacity(
                  opacity: emberOpacity,
                  child: Container(
                    width: math.min(viewportHeight * 0.85, 600),
                    height: math.min(viewportHeight * 0.85, 600),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0x60D4622A),
                          Color(0x20C8A45C),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.45, 0.72],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Firelight Sweep (Active in Scene 2)
          if (!isReducedMotion && sweepOpacity > 0.005)
            Center(
              child: Transform.scale(
                scale: sweepScale,
                child: Opacity(
                  opacity: sweepOpacity,
                  child: Container(
                    width: viewportHeight * 1.4,
                    height: viewportHeight * 1.4,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0x80D4622A),
                          Color(0x2ED4622A),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.30, 0.58],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Celestial Ornamental Concentric Rings (Active in Scene 4)
          if (!isReducedMotion && ringsOpacity > 0.005)
            Positioned.fill(
              child: Opacity(
                opacity: ringsOpacity,
                child: Transform.scale(
                  scale: ringsScale,
                  child: CustomPaint(
                    painter: _OrnamentalRingsPainter(
                      progress: p,
                      ringsAlpha: ringsAlpha,
                    ),
                  ),
                ),
              ),
            ),

          // SCENE 1: Where Royalty Begins (Crown)
          _buildScene(
            id: 'crown',
            headlineLines: ['Where Royalty', 'Begins'],
            supportingCopy:
                "Discover the artistry, symbolism and traditions behind the world's royal treasures.",
            imageAsset: 'assets/images/prod_austria_crown.jpg',
            imageSemanticLabel: 'Imperial Crown of Austria set with royal gemstones and pearl arches',
            imageCaption: 'Europe · Imperial Crown of Austria · Hofburg Vienna',
            reveal: 'iris',
            win: const [0.0, 0.08, 0.20, 0.30],
            progress: p,
            isMobile: isMobile,
            isReducedMotion: isReducedMotion,
          ),

          // SCENE 2: The Art of Adornment (Necklace)
          _buildScene(
            id: 'necklace',
            headlineLines: ['The Art of', 'Adornment'],
            supportingCopy:
                'Centuries of royal goldsmithing, uncut emeralds, and ceremonial kundan jewellery.',
            imageAsset: 'assets/images/prod_kundan_necklace.jpg',
            imageSemanticLabel: 'Mughal Kundan and Colombian emerald ceremonial royal necklace',
            imageCaption: 'India · Mughal Kundan & Emerald Necklace · The Met',
            reveal: 'rise',
            win: const [0.20, 0.32, 0.46, 0.56],
            progress: p,
            isMobile: isMobile,
            isReducedMotion: isReducedMotion,
          ),

          // SCENE 3: Woven in Heritage (Court Clothing)
          _buildScene(
            id: 'clothing',
            headlineLines: ['Woven in', 'Heritage'],
            supportingCopy:
                'Sacred ceremonial court silks, supplementary gold thread songket, and coronation robes.',
            imageAsset: 'assets/images/prod_korean_wonsam.jpg',
            imageSemanticLabel: 'Joseon Dynasty royal court embroidered ceremonial wonsam robe',
            imageCaption: 'Korea · Joseon Royal Court Robe (Wonsam)',
            reveal: 'wipe',
            win: const [0.46, 0.58, 0.70, 0.78],
            progress: p,
            isMobile: isMobile,
            isReducedMotion: isReducedMotion,
          ),

          // SCENE 4: Heritage, Gathered in One Place (Closing Statement & Composition)
          _buildScene(
            id: 'emblem',
            headlineLines: ['Heritage,', 'Gathered in One Place'],
            supportingCopy:
                'Curated from sovereign treasuries, royal dynasties, and celebrated ateliers across the globe.',
            imageAsset: 'assets/images/prod_chimu_gold.jpg',
            imageSemanticLabel: 'Pre-Columbian sovereign solid gold regalia sun plaque',
            imageCaption: 'The Americas · Sovereign Sun Plaque Regalia',
            reveal: 'iris',
            win: const [0.68, 0.78, 0.88, 0.95],
            progress: p,
            isMobile: isMobile,
            isReducedMotion: isReducedMotion,
            isCentered: true,
          ),

          // Subtle top brand ribbon within stage
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC8A45C).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFC8A45C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ORIGIN CHRONICLES · SCROLL TO DISCOVER',
                      style: GoogleFonts.montserrat(
                        fontSize: 9.5,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD9C7A3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Final Ivory Fade Overlay (Hands off seamlessly to the light collection section)
          if (ivoryFade > 0.001)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: const Color(0xFFF8F6EF).withValues(alpha: ivoryFade),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScene({
    required String id,
    required List<String> headlineLines,
    required String supportingCopy,
    required String? imageAsset,
    required String imageSemanticLabel,
    required String imageCaption,
    required String reveal,
    required List<double> win,
    required double progress,
    required bool isMobile,
    required bool isReducedMotion,
    bool isCentered = false,
  }) {
    final a0 = win[0];
    final a1 = win[1];
    final o0 = win[2];
    final o1 = win[3];

    final fadeIn = _ramp(progress, a0, a1);
    final fadeOut = _ramp(progress, o0, o1);
    final visibility = fadeIn - fadeOut;

    if (visibility <= 0.001 && !isReducedMotion) {
      return const SizedBox.shrink();
    }

    final sceneOpacity = isReducedMotion ? 1.0 : _clamp(fadeIn * 1.6) * (1.0 - fadeOut);
    final par = isMobile ? 0.0 : 1.0;
    final parallaxY = isReducedMotion ? 0.0 : (progress - 0.5) * -32.0 * par;
    final imageScale = isReducedMotion ? 1.0 : (0.88 + 0.12 * fadeIn - 0.16 * fadeOut);

    return Positioned.fill(
      child: Opacity(
        opacity: sceneOpacity.clamp(0.0, 1.0),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 72,
            vertical: isMobile ? 32 : 48,
          ),
          child: isCentered
              ? _buildCenteredSceneLayout(
                  headlineLines: headlineLines,
                  supportingCopy: supportingCopy,
                  imageAsset: imageAsset,
                  imageSemanticLabel: imageSemanticLabel,
                  imageCaption: imageCaption,
                  fadeIn: fadeIn,
                  fadeOut: fadeOut,
                  parallaxY: parallaxY,
                  imageScale: imageScale,
                  reveal: reveal,
                  isMobile: isMobile,
                  isReducedMotion: isReducedMotion,
                )
              : _buildSplitSceneLayout(
                  headlineLines: headlineLines,
                  supportingCopy: supportingCopy,
                  imageAsset: imageAsset,
                  imageSemanticLabel: imageSemanticLabel,
                  imageCaption: imageCaption,
                  fadeIn: fadeIn,
                  fadeOut: fadeOut,
                  parallaxY: parallaxY,
                  imageScale: imageScale,
                  reveal: reveal,
                  isMobile: isMobile,
                  isReducedMotion: isReducedMotion,
                ),
        ),
      ),
    );
  }

  Widget _buildSplitSceneLayout({
    required List<String> headlineLines,
    required String supportingCopy,
    required String? imageAsset,
    required String imageSemanticLabel,
    required String imageCaption,
    required double fadeIn,
    required double fadeOut,
    required double parallaxY,
    required double imageScale,
    required String reveal,
    required bool isMobile,
    required bool isReducedMotion,
  }) {
    final textColumn = _buildSceneText(
      headlineLines: headlineLines,
      supportingCopy: supportingCopy,
      fadeIn: fadeIn,
      fadeOut: fadeOut,
      isMobile: isMobile,
      isReducedMotion: isReducedMotion,
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      textAlign: isMobile ? TextAlign.center : TextAlign.left,
    );

    final figure = _buildSceneFigure(
      imageAsset: imageAsset,
      imageSemanticLabel: imageSemanticLabel,
      imageCaption: imageCaption,
      fadeIn: fadeIn,
      parallaxY: parallaxY,
      imageScale: imageScale,
      reveal: reveal,
      isMobile: isMobile,
      isReducedMotion: isReducedMotion,
    );

    if (isMobile) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: Center(child: figure)),
          const SizedBox(height: 16),
          Expanded(flex: 4, child: Center(child: textColumn)),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Center(child: textColumn)),
        const SizedBox(width: 48),
        Expanded(child: Center(child: figure)),
      ],
    );
  }

  Widget _buildCenteredSceneLayout({
    required List<String> headlineLines,
    required String supportingCopy,
    required String? imageAsset,
    required String imageSemanticLabel,
    required String imageCaption,
    required double fadeIn,
    required double fadeOut,
    required double parallaxY,
    required double imageScale,
    required String reveal,
    required bool isMobile,
    required bool isReducedMotion,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (imageAsset != null) ...[
          SizedBox(
            height: isMobile ? 180 : 250,
            child: _buildSceneFigure(
              imageAsset: imageAsset,
              imageSemanticLabel: imageSemanticLabel,
              imageCaption: imageCaption,
              fadeIn: fadeIn,
              parallaxY: parallaxY,
              imageScale: imageScale,
              reveal: reveal,
              isMobile: isMobile,
              isReducedMotion: isReducedMotion,
              compact: true,
            ),
          ),
          const SizedBox(height: 20),
        ],
        _buildSceneText(
          headlineLines: headlineLines,
          supportingCopy: supportingCopy,
          fadeIn: fadeIn,
          fadeOut: fadeOut,
          isMobile: isMobile,
          isReducedMotion: isReducedMotion,
          crossAxisAlignment: CrossAxisAlignment.center,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSceneText({
    required List<String> headlineLines,
    required String supportingCopy,
    required double fadeIn,
    required double fadeOut,
    required bool isMobile,
    required bool isReducedMotion,
    required CrossAxisAlignment crossAxisAlignment,
    required TextAlign textAlign,
  }) {
    final subOpacity = isReducedMotion
        ? 1.0
        : (_clamp(fadeIn * 1.4 - 0.4) * (1.0 - fadeOut)).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        // Headline lines with elegant masked reveal
        for (int i = 0; i < headlineLines.length; i++) ...[
          ClipRect(
            child: Builder(builder: (context) {
              final t = _clamp(fadeIn * 1.25 - i * 0.20);
              final lineTranslateY = isReducedMotion ? 0.0 : ((1.0 - _ease(t)) * 48.0 - fadeOut * 48.0);
              return Transform.translate(
                offset: Offset(0, lineTranslateY),
                child: Text(
                  headlineLines[i],
                  textAlign: textAlign,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: isMobile ? 32 : 52,
                    fontWeight: FontWeight.w400,
                    height: 1.10,
                    color: const Color(0xFFF3EAD9), // Warm Royal Ivory
                    letterSpacing: 0.8,
                  ),
                ),
              );
            }),
          ),
        ],
        if (supportingCopy.isNotEmpty) ...[
          const SizedBox(height: 16),
          Opacity(
            opacity: subOpacity,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Text(
                supportingCopy,
                textAlign: textAlign,
                style: GoogleFonts.montserrat(
                  fontSize: isMobile ? 13 : 15.5,
                  height: 1.65,
                  color: const Color(0xFFD9C7A3), // Sand
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSceneFigure({
    required String? imageAsset,
    required String imageSemanticLabel,
    required String imageCaption,
    required double fadeIn,
    required double parallaxY,
    required double imageScale,
    required String reveal,
    required bool isMobile,
    required bool isReducedMotion,
    bool compact = false,
  }) {
    if (imageAsset == null) return const SizedBox.shrink();

    Widget clippedImage = Image.asset(
      imageAsset,
      fit: BoxFit.contain,
      semanticLabel: imageSemanticLabel,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFF29262D),
          child: const Center(
            child: Icon(Icons.castle_outlined, size: 48, color: Color(0xFFB99A55)),
          ),
        );
      },
    );

    if (!isReducedMotion) {
      if (reveal == 'iris') {
        clippedImage = ClipPath(
          clipper: _IrisClipper(progress: fadeIn),
          child: clippedImage,
        );
      } else if (reveal == 'rise') {
        clippedImage = ClipRect(
          clipper: _RiseClipper(progress: fadeIn),
          child: clippedImage,
        );
      } else if (reveal == 'wipe') {
        clippedImage = ClipRect(
          clipper: _WipeClipper(progress: fadeIn),
          child: clippedImage,
        );
      }
    }

    final figureWidth = compact
        ? (isMobile ? 180.0 : 240.0)
        : (isMobile ? 240.0 : 380.0);

    return Transform.translate(
      offset: Offset(0, parallaxY),
      child: Transform.scale(
        scale: imageScale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: figureWidth,
              constraints: BoxConstraints(
                maxHeight: isMobile ? 220 : 380,
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4622A).withValues(alpha: 0.18 * fadeIn),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: clippedImage,
            ),
            const SizedBox(height: 12),
            Text(
              imageCaption,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                letterSpacing: 1.4,
                color: const Color(0xFFD9C7A3).withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. THE CLOSING COLLECTION SECTION
  Widget _buildClosingCollectionSection(BuildContext context, bool isMobile) {
    final collectionCards = [
      _CollectionCardData(
        title: 'Crowns & Tiaras',
        subtitle: 'Handcrafted diadems, imperial crowns and ceremonial headpieces preserved in state archives.',
        imageAsset: 'assets/images/prod_austria_crown.jpg',
        route: '/shop?category=Imperial%20Jewels',
        badge: 'CERTIFIED REGALIA',
      ),
      _CollectionCardData(
        title: 'Royal Jewellery',
        subtitle: 'Kundan chokers, Colombian emeralds and imperial gems set by master court goldsmiths.',
        imageAsset: 'assets/images/prod_kundan_necklace.jpg',
        route: '/shop?category=Imperial%20Jewels',
        badge: 'HEIRLOOM JEWELS',
      ),
      _CollectionCardData(
        title: 'Royal Fashion',
        subtitle: 'Haute couture court robes, gold zari silks and traditional coronation ensembles.',
        imageAsset: 'assets/images/prod_korean_wonsam.jpg',
        route: '/shop?category=Royal%20Wardrobe',
        badge: 'COURT COUTURE',
      ),
      _CollectionCardData(
        title: 'Palace Décor',
        subtitle: 'Water-gilded consoles, master khatam marquetry and sovereign throne room appointments.',
        imageAsset: 'assets/images/prod_versailles_console.jpg',
        route: '/shop?category=Palace%20Living',
        badge: 'PALATIAL LIVING',
      ),
      _CollectionCardData(
        title: 'Antiques & Collectibles',
        subtitle: 'Museum-grade Jingdezhen cobalt porcelain, imperial seals and certified historical relics.',
        imageAsset: 'assets/images/prod_ming_vase.jpg',
        route: '/shop?category=Dining%20%26%20Tableware',
        badge: 'MUSEUM ANTIQUITY',
      ),
      _CollectionCardData(
        title: 'Cultural Treasures',
        subtitle: 'Pre-Columbian gold regalia, Asante royal emblems and sacred global antiquities.',
        imageAsset: 'assets/images/prod_chimu_gold.jpg',
        route: '/shop?category=Treasures%20of%20the%20World',
        badge: 'GLOBAL SOVEREIGNTY',
      ),
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8F6EF), // Royal Ivory
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 64,
        vertical: isMobile ? 64 : 100,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ornamental Crest Emblem
              Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFB99A55), width: 1.2),
                    color: const Color(0xFFE8DCC7).withValues(alpha: 0.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFB99A55),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Super-title
              Text(
                'THE IMPERIAL REPERTORY',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.5,
                  color: const Color(0xFFB99A55), // Antique Gold
                ),
              ),
              const SizedBox(height: 12),

              // Main Heading
              Text(
                "Explore the World's Royal Heritage",
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 32 : 44,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF0B1F3B), // Deep Royal Navy
                  letterSpacing: 0.5,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),

              // Supporting Copy
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  'From exquisite jewellery and ceremonial fashion to palace décor and historic treasures, discover pieces inspired by royal traditions across the world.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: isMobile ? 13.5 : 15,
                    height: 1.65,
                    color: const Color(0xFF5B4D42), // Soft Charcoal/Ink
                  ),
                ),
              ),
              const SizedBox(height: 52),

              // Responsive Collection Cards Grid (2 cols mobile, 3 cols desktop)
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 640
                      ? 1
                      : constraints.maxWidth < 960
                          ? 2
                          : 3;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: collectionCards.map((data) {
                      final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 24) / crossAxisCount;
                      return _buildCollectionCard(
                        context: context,
                        data: data,
                        width: cardWidth.clamp(280.0, 380.0),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Action button to shop all
              OutlinedButton.icon(
                onPressed: () => context.go('/shop'),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF0B1F3B)),
                label: Text(
                  'EXPLORE ALL ROYAL COLLECTIONS',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.4,
                    color: const Color(0xFF0B1F3B),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFB99A55), width: 1.4),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionCard({
    required BuildContext context,
    required _CollectionCardData data,
    required double width,
  }) {
    return _HoverableCollectionCard(
      width: width,
      data: data,
      onTap: () => context.go(data.route),
    );
  }
}

class _CollectionCardData {
  const _CollectionCardData({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.route,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final String imageAsset;
  final String route;
  final String badge;
}

class _HoverableCollectionCard extends StatefulWidget {
  const _HoverableCollectionCard({
    required this.width,
    required this.data,
    required this.onTap,
  });

  final double width;
  final _CollectionCardData data;
  final VoidCallback onTap;

  @override
  State<_HoverableCollectionCard> createState() => _HoverableCollectionCardState();
}

class _HoverableCollectionCardState extends State<_HoverableCollectionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          width: widget.width,
          transform: Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _isHovered ? const Color(0xFFB99A55) : const Color(0xFFE8DCC7),
              width: _isHovered ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0x240B1F3B)
                    : const Color(0x0C0B1F3B),
                blurRadius: _isHovered ? 24 : 10,
                offset: Offset(0, _isHovered ? 12 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container with subtle zoom
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  color: const Color(0xFFF8F1E3),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          scale: _isHovered ? 1.05 : 1.0,
                          child: Image.asset(
                            d.imageAsset,
                            fit: BoxFit.contain,
                            semanticLabel: '${d.title} preview photograph',
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image, color: Color(0xFFB99A55)),
                              );
                            },
                          ),
                        ),
                      ),
                      // Badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B1F3B).withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: const Color(0xFFB99A55), width: 0.8),
                          ),
                          child: Text(
                            d.badge,
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: const Color(0xFFE8DCC7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Card Info
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0B1F3B), // Royal Navy
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      d.subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 12.5,
                        height: 1.55,
                        color: const Color(0xFF5B4D42),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          'DISCOVER COLLECTION',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            color: _isHovered
                                ? const Color(0xFF800020) // Muted Burgundy
                                : const Color(0xFFB99A55), // Antique Gold
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedSlide(
                          duration: const Duration(milliseconds: 250),
                          offset: Offset(_isHovered ? 0.3 : 0.0, 0),
                          child: Icon(
                            Icons.arrow_forward_sharp,
                            size: 14,
                            color: _isHovered
                                ? const Color(0xFF800020)
                                : const Color(0xFFB99A55),
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
      ),
    );
  }
}

/// Concentric Celestial Rings Painter
/// Draws the exact ornamental gold geometry from Scene 4 of the prototype
class _OrnamentalRingsPainter extends CustomPainter {
  const _OrnamentalRingsPainter({
    required this.progress,
    required this.ringsAlpha,
  });

  final double progress;
  final double ringsAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final minDim = math.min(size.width, size.height);
    final baseRadius = minDim * 0.45;

    final ringRatios = [0.14, 0.26, 0.40, 0.56, 0.74];

    for (int i = 0; i < ringRatios.length; i++) {
      final r = baseRadius * ringRatios[i];
      final circleAlpha = (1.0 - (ringRatios[i] * 100) / 110.0).clamp(0.2, 0.95);
      final strokeProgress = (ringsAlpha * 1.4 - i * 0.12).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = const Color(0xFFC8A45C).withValues(alpha: circleAlpha * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      if (strokeProgress >= 0.999) {
        canvas.drawCircle(center, r, paint);
      } else if (strokeProgress > 0.001) {
        final sweepAngle = strokeProgress * 2 * math.pi;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: r),
          -math.pi / 2,
          sweepAngle,
          false,
          paint,
        );
      }
    }

    // Highlight accent ring with firelight amber stroke
    final hlRadius = baseRadius * 0.56;
    final hlRotation = -(progress * 1.2 * 2 * math.pi);
    final hlPaint = Paint()
      ..color = const Color(0xFFD4622A).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: hlRadius),
      hlRotation,
      math.pi * 0.25,
      false,
      hlPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OrnamentalRingsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.ringsAlpha != ringsAlpha;
  }
}

/// Iris reveal clipper (circle expanding from center)
class _IrisClipper extends CustomClipper<Path> {
  const _IrisClipper({required this.progress});
  final double progress;

  @override
  Path getClip(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final maxDim = math.max(size.width, size.height);
    final radius = maxDim * 0.75 * progress;
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(covariant _IrisClipper oldClipper) => oldClipper.progress != progress;
}

/// Rise reveal clipper (inset from bottom upward)
class _RiseClipper extends CustomClipper<Rect> {
  const _RiseClipper({required this.progress});
  final double progress;

  @override
  Rect getClip(Size size) {
    final top = size.height * (1.0 - progress);
    return Rect.fromLTRB(0, top, size.width, size.height);
  }

  @override
  bool shouldReclip(covariant _RiseClipper oldClipper) => oldClipper.progress != progress;
}

/// Wipe reveal clipper (inset horizontally from left to right)
class _WipeClipper extends CustomClipper<Rect> {
  const _WipeClipper({required this.progress});
  final double progress;

  @override
  Rect getClip(Size size) {
    final right = size.width * progress;
    return Rect.fromLTRB(0, 0, right, size.height);
  }

  @override
  bool shouldReclip(covariant _WipeClipper oldClipper) => oldClipper.progress != progress;
}
