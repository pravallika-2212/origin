import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/fonts.dart';
import '../../core/utils/breakpoints.dart';

/// Scene specification for the ORIGIN Rolling Cinematic Showcase.
class _CinematicSceneData {
  const _CinematicSceneData({
    required this.id,
    required this.name,
    required this.headlineLines,
    required this.supportingCopy,
    required this.imageAsset,
    required this.imageSemanticLabel,
    required this.imageCaption,
    required this.theme,
    this.isCentered = false,
    this.hasSweep = false,
    this.hasRings = false,
    this.chips = const [],
  });

  final String id;
  final String name;
  final List<String> headlineLines;
  final String supportingCopy;
  final String imageAsset;
  final String imageSemanticLabel;
  final String imageCaption;
  final String theme; // 'dark' | 'light'
  final bool isCentered;
  final bool hasSweep;
  final bool hasRings;
  final List<String> chips;
}

/// ORIGIN 3D Rolling Scene Cinematic Showcase
///
/// Replaces the old scroll-driven cinematic progression with a controlled,
/// premium 3D rolling transition experience inspired by the motion guide.
/// Features:
/// - 5 authentic royal heritage scenes in the exact intended sequence
/// - 3D rolling transitions with perspective depth, transform origin and easing
/// - Autoplay with smooth progress fill bars, pause/play toggle
/// - Accessible Prev/Next navigation, clickable scene indicators, keyboard shortcuts & gestures
/// - Authentic museum photography and gold ember lighting
/// - Seamless connection directly into the Imperial Repertory collection cards
class OriginCinematicSection extends StatefulWidget {
  const OriginCinematicSection({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  @override
  State<OriginCinematicSection> createState() => _OriginCinematicSectionState();
}

class _OriginCinematicSectionState extends State<OriginCinematicSection>
    with TickerProviderStateMixin {
  // Scene definitions
  static const List<_CinematicSceneData> _scenes = [
    _CinematicSceneData(
      id: 'crown',
      name: 'Where Royalty Begins',
      headlineLines: ['Where Royalty', 'Begins'],
      supportingCopy:
          "Discover the artistry, symbolism and traditions behind the world's royal treasures.",
      imageAsset: 'assets/images/prod_austria_crown.jpg',
      imageSemanticLabel: 'Imperial Crown of Austria set with royal gemstones and pearl arches',
      imageCaption: 'Europe · Imperial Crown of Austria · Hofburg Vienna',
      theme: 'dark',
    ),
    _CinematicSceneData(
      id: 'necklace',
      name: 'The Art of Adornment',
      headlineLines: ['The Art of', 'Adornment'],
      supportingCopy:
          'Centuries of royal goldsmithing, uncut emeralds, and ceremonial kundan jewellery.',
      imageAsset: 'assets/images/prod_kundan_necklace.jpg',
      imageSemanticLabel: 'Mughal Kundan and Colombian emerald ceremonial royal necklace',
      imageCaption: 'India · Mughal Kundan & Emerald Necklace · The Met',
      theme: 'dark',
      hasSweep: true,
    ),
    _CinematicSceneData(
      id: 'clothing',
      name: 'Woven in Heritage',
      headlineLines: ['Woven in', 'Heritage'],
      supportingCopy:
          'Sacred ceremonial court silks, supplementary gold thread songket, and coronation robes.',
      imageAsset: 'assets/images/prod_korean_wonsam.jpg',
      imageSemanticLabel: 'Joseon Dynasty royal court embroidered ceremonial wonsam robe',
      imageCaption: 'Korea · Joseon Royal Court Robe (Wonsam)',
      theme: 'dark',
    ),
    _CinematicSceneData(
      id: 'emblem',
      name: 'Heritage, gathered in one place',
      headlineLines: ['Heritage,', 'gathered in one place'],
      supportingCopy:
          'Curated from sovereign treasuries, royal dynasties, and celebrated ateliers across the globe.',
      imageAsset: 'assets/images/prod_chimu_gold.jpg',
      imageSemanticLabel: 'Pre-Columbian sovereign solid gold regalia sun plaque',
      imageCaption: 'The Americas · Sovereign Sun Plaque Regalia',
      theme: 'dark',
      isCentered: true,
      hasRings: true,
    ),
    _CinematicSceneData(
      id: 'collection',
      name: "Explore the World's Royal Heritage",
      headlineLines: ['Explore the World’s', 'Royal Heritage'],
      supportingCopy:
          'From crowns and tiaras to palace tableware, browse pieces from across the world.',
      imageAsset: 'assets/images/prod_versailles_console.jpg',
      imageSemanticLabel: 'Versailles giltwood royal console with hand-carved acanthus leaves',
      imageCaption: 'France · Versailles Giltwood Royal Console',
      theme: 'light',
      chips: [
        'Crowns & Tiaras',
        'Necklaces & Jewellery',
        'Royal Clothing',
        'Palace Furniture',
        'Tableware',
        'Cultural Artefacts',
      ],
    ),
  ];

  // State
  int _currentIndex = 0;
  int _targetIndex = 0;
  bool _isForward = true;
  bool _isPlaying = true;
  bool _imagesPrecached = false;

  // 3D Tilt coordinates from mouse position
  double _tiltRx = 0.0;
  double _tiltRy = 0.0;

  // Animation Controllers
  late final AnimationController _rollController;
  late final Animation<double> _rollAnimation;

  late final AnimationController _autoplayController;
  late final AnimationController _orbitController;
  late final AnimationController _sweepController;

  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // 3D Roll Controller: 900ms with smooth cubic bezier curve
    _rollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _rollAnimation = CurvedAnimation(
      parent: _rollController,
      curve: const Cubic(0.6, 0.05, 0.2, 1.0),
    );

    _rollController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = _targetIndex;
          _rollController.reset();
        });
        if (_isPlaying) {
          _autoplayController.forward(from: 0.0);
        }
      }
    });

    // Autoplay Controller: 3.5s per scene
    _autoplayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _autoplayController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isPlaying) {
        _goTo((_currentIndex + 1) % _scenes.length, forward: true);
      }
    });

    // Ambient loop controllers
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Start autoplay
    _autoplayController.forward(from: 0.0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      for (final s in _scenes) {
        precacheImage(AssetImage(s.imageAsset), context);
      }
      precacheImage(const AssetImage('assets/images/prod_ming_vase.jpg'), context);
    }
  }

  @override
  void dispose() {
    _autoplayController.dispose();
    _rollController.dispose();
    _orbitController.dispose();
    _sweepController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _goTo(int newIndex, {bool? forward}) {
    if (_rollController.isAnimating) return;
    final target = (newIndex % _scenes.length + _scenes.length) % _scenes.length;
    if (target == _currentIndex) return;

    final isFwd = forward ?? (target > _currentIndex);

    setState(() {
      _targetIndex = target;
      _isForward = isFwd;
    });

    _autoplayController.stop();

    if (_scenes[_targetIndex].hasSweep) {
      _sweepController.forward(from: 0.0);
    }

    _rollController.forward(from: 0.0);
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        if (!_rollController.isAnimating) {
          _autoplayController.forward(from: _autoplayController.value);
        }
      } else {
        _autoplayController.stop();
      }
    });
  }

  void _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _goTo(_currentIndex + 1, forward: true);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _goTo(_currentIndex - 1, forward: false);
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      _togglePlayPause();
    }
  }

  void _scrollToCollection() {
    if (widget.scrollController != null && widget.scrollController!.hasClients) {
      widget.scrollController!.animateTo(
        widget.scrollController!.offset + 500,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final isReducedMotion = Breakpoints.isReducedMotion(context);

    // If reduced motion is requested, stop autoplay
    if (isReducedMotion && _isPlaying) {
      _isPlaying = false;
      _autoplayController.stop();
    }

    final stageHeight = isMobile ? 680.0 : 760.0;

    return Column(
      children: [
        // 1. THE 3D ROLLING SHOWCASE STAGE
        Focus(
          focusNode: _keyboardFocusNode,
          autofocus: false,
          onKeyEvent: (node, event) {
            _onKey(event);
            return KeyEventResult.handled;
          },
          child: MouseRegion(
            onHover: (event) {
              if (isReducedMotion || isMobile) return;
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final size = box.size;
              final px = (event.localPosition.dx / size.width).clamp(0.0, 1.0);
              final py = (event.localPosition.dy / stageHeight).clamp(0.0, 1.0);
              setState(() {
                _tiltRy = ((px - 0.5) * 10.0) * math.pi / 180.0;
                _tiltRx = ((0.5 - py) * 6.0) * math.pi / 180.0;
              });
            },
            onExit: (_) {
              if (mounted) {
                setState(() {
                  _tiltRx = 0.0;
                  _tiltRy = 0.0;
                });
              }
            },
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -120) {
                  _goTo(_currentIndex + 1, forward: true);
                } else if (velocity > 120) {
                  _goTo(_currentIndex - 1, forward: false);
                }
              },
              child: SizedBox(
                height: stageHeight,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Stage Background
                    _buildStageBackground(),

                    // Ambient Ember Lighting
                    if (!isReducedMotion) _buildAmbientEmber(),

                    // Firelight Sweep (Scene 2)
                    if (!isReducedMotion) _buildFirelightSweep(),

                    // Concentric Orbital Celestial Rings (Scene 4)
                    if (!isReducedMotion) _buildCelestialRings(),

                    // 3D Scene Viewport
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _rollAnimation,
                        builder: (context, _) {
                          return _buildSceneViewport(
                            isMobile: isMobile,
                            isReducedMotion: isReducedMotion,
                          );
                        },
                      ),
                    ),

                    // Top Decorative Heritage Ribbon
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
                            border: Border.all(
                              color: const Color(0xFFC8A45C).withValues(alpha: 0.3),
                            ),
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
                                'ORIGIN CHRONICLES · ROLLING SHOWCASE',
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

                    // Bottom Navigation & Autoplay Controls
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildControlBar(isMobile: isMobile),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 2. THE CLOSING COLLECTION SECTION
        RepaintBoundary(
          child: _buildClosingCollectionSection(context, isMobile),
        ),
      ],
    );
  }

  // Stage Background: transitions smoothly from Charcoal/Burgundy to Ivory for Scene 5
  Widget _buildStageBackground() {
    final currentTheme = _scenes[_currentIndex].theme;
    final targetTheme = _scenes[_targetIndex].theme;
    final isAnimating = _rollController.isAnimating;

    double lightProgress = 0.0;
    if (!isAnimating) {
      lightProgress = currentTheme == 'light' ? 1.0 : 0.0;
    } else {
      final fromLight = currentTheme == 'light' ? 1.0 : 0.0;
      final toLight = targetTheme == 'light' ? 1.0 : 0.0;
      lightProgress = fromLight + (toLight - fromLight) * _rollAnimation.value;
    }

    return Positioned.fill(
      child: Stack(
        children: [
          // Base Charcoal / Dark Canvas
          Container(color: const Color(0xFF17120F)),

          // Radial Burgundy Glow
          Positioned.fill(
            child: Opacity(
              opacity: (1.0 - lightProgress).clamp(0.0, 1.0),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.2),
                    radius: 1.15,
                    colors: [
                      Color(0xFF3A0F1A), // Burgundy
                      Color(0xFF17120F), // Charcoal
                    ],
                    stops: [0.35, 0.85],
                  ),
                ),
              ),
            ),
          ),

          // Ivory Light Theme Canvas
          if (lightProgress > 0.001)
            Positioned.fill(
              child: Opacity(
                opacity: lightProgress.clamp(0.0, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.0, -0.2),
                      radius: 1.2,
                      colors: [
                        Color(0xFFFBF8F0),
                        Color(0xFFF3EAD9),
                      ],
                      stops: [0.3, 0.9],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Dynamic Warm Ember
  Widget _buildAmbientEmber() {
    final activeScene = _rollController.isAnimating ? _targetIndex : _currentIndex;
    final isLight = _scenes[activeScene].theme == 'light';
    if (isLight) return const SizedBox.shrink();

    // Ember shifts position slightly per scene, matching reference HTML
    Offset emberOffset = Offset.zero;
    double emberScale = 1.0;
    if (activeScene == 1) {
      emberOffset = const Offset(-30, 25);
      emberScale = 1.25;
    } else if (activeScene == 2) {
      emberOffset = const Offset(-50, -15);
      emberScale = 1.05;
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeInOutCubic,
      left: MediaQuery.sizeOf(context).width * 0.60 + emberOffset.dx,
      top: 360 + emberOffset.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 1400),
          curve: Curves.easeInOutCubic,
          scale: emberScale,
          child: Container(
            width: 460,
            height: 460,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0x56D4622A),
                  Color(0x18C8A45C),
                  Colors.transparent,
                ],
                stops: [0.0, 0.45, 0.70],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Firelight Sweep (Active in Scene 1)
  Widget _buildFirelightSweep() {
    final isScene1 = _currentIndex == 1 || (_rollController.isAnimating && _targetIndex == 1);
    if (!isScene1) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _sweepController,
          builder: (context, _) {
            final t = _sweepController.value;
            final sweepOpacity = (math.sin(math.pi * t) * 0.55).clamp(0.0, 1.0);
            final sweepScale = 0.05 + t * 0.95;

            return Center(
              child: Transform.scale(
                scale: sweepScale,
                child: Opacity(
                  opacity: sweepOpacity,
                  child: Container(
                    width: 700,
                    height: 700,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0x75D4622A),
                          Color(0x28D4622A),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.30, 0.60],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Celestial Rings (Active in Scene 3 - Emblem)
  Widget _buildCelestialRings() {
    final isScene3 = _currentIndex == 3 || (_rollController.isAnimating && _targetIndex == 3);
    if (!isScene3) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _orbitController,
          builder: (context, _) {
            return CustomPaint(
              painter: _CelestialOrbitalRingsPainter(
                orbitProgress: _orbitController.value,
              ),
            );
          },
        ),
      ),
    );
  }

  // 3D Scene Viewport with Rolling Transforms
  Widget _buildSceneViewport({
    required bool isMobile,
    required bool isReducedMotion,
  }) {
    final isAnimating = _rollController.isAnimating;

    if (!isAnimating) {
      // Static active scene
      return _buildSingleScene(
        sceneIndex: _currentIndex,
        rotateY: _tiltRy,
        rotateX: _tiltRx,
        translateZ: 0.0,
        opacity: 1.0,
        isMobile: isMobile,
        isReducedMotion: isReducedMotion,
      );
    }

    // Rolling Transition between Outgoing & Incoming
    final t = _rollAnimation.value;
    final rollAngle = 62.0 * math.pi / 180.0; // 62 degrees
    const rollDepth = -420.0;

    // Outgoing
    final outAngle = (_isForward ? -rollAngle : rollAngle) * t;
    final outZ = rollDepth * t;
    final outOpacity = (1.0 - t).clamp(0.0, 1.0);

    // Incoming
    final inAngle = (_isForward ? rollAngle : -rollAngle) * (1.0 - t);
    final inZ = rollDepth * (1.0 - t);
    final inOpacity = t.clamp(0.0, 1.0);

    return Stack(
      children: [
        // Outgoing Scene
        _buildSingleScene(
          sceneIndex: _currentIndex,
          rotateY: isReducedMotion ? 0.0 : outAngle + _tiltRy,
          rotateX: isReducedMotion ? 0.0 : _tiltRx,
          translateZ: isReducedMotion ? 0.0 : outZ,
          opacity: outOpacity,
          isMobile: isMobile,
          isReducedMotion: isReducedMotion,
        ),

        // Incoming Scene
        _buildSingleScene(
          sceneIndex: _targetIndex,
          rotateY: isReducedMotion ? 0.0 : inAngle + _tiltRy,
          rotateX: isReducedMotion ? 0.0 : _tiltRx,
          translateZ: isReducedMotion ? 0.0 : inZ,
          opacity: inOpacity,
          isMobile: isMobile,
          isReducedMotion: isReducedMotion,
        ),
      ],
    );
  }

  Widget _buildSingleScene({
    required int sceneIndex,
    required double rotateY,
    required double rotateX,
    required double translateZ,
    required double opacity,
    required bool isMobile,
    required bool isReducedMotion,
  }) {
    if (opacity <= 0.001) return const SizedBox.shrink();

    final data = _scenes[sceneIndex];
    final isLight = data.theme == 'light';

    // 3D Perspective Matrix (Perspective 1500px -> 1 / 1500 = 0.00067)
    final transformMatrix = Matrix4.identity()
      ..setEntry(3, 2, 0.00067)
      ..setTranslationRaw(0.0, 0.0, translateZ);
    if (!isReducedMotion) {
      transformMatrix.rotateY(rotateY);
      if (rotateX != 0.0) transformMatrix.rotateX(rotateX);
    }

    return SizedBox.expand(
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform(
          alignment: Alignment.center,
          transform: transformMatrix,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 64,
              vertical: isMobile ? 32 : 44,
            ),
            child: data.isCentered
                ? _buildCenteredSceneLayout(data, isMobile, isLight)
                : _buildSplitSceneLayout(data, isMobile, isLight),
          ),
        ),
      ),
    );
  }

  Widget _buildSplitSceneLayout(
    _CinematicSceneData data,
    bool isMobile,
    bool isLight,
  ) {
    final textWidget = _buildSceneText(data, isMobile, isLight);
    final figureWidget = _buildSceneFigure(data, isMobile, isLight);

    if (isMobile) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: Center(child: figureWidget)),
          const SizedBox(height: 12),
          Expanded(flex: 5, child: Center(child: textWidget)),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Center(child: textWidget)),
        const SizedBox(width: 48),
        Expanded(child: Center(child: figureWidget)),
      ],
    );
  }

  Widget _buildCenteredSceneLayout(
    _CinematicSceneData data,
    bool isMobile,
    bool isLight,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: isMobile ? 180 : 250,
          child: _buildSceneFigure(data, isMobile, isLight, compact: true),
        ),
        const SizedBox(height: 20),
        _buildSceneText(data, isMobile, isLight, isCentered: true),
      ],
    );
  }

  Widget _buildSceneText(
    _CinematicSceneData data,
    bool isMobile,
    bool isLight, {
    bool isCentered = false,
  }) {
    final primaryColor = isLight ? const Color(0xFF0B1F3B) : const Color(0xFFF3EAD9);
    final secondaryColor = isLight ? const Color(0xFF5B4D42) : const Color(0xFFD9C7A3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Headline Lines
        for (int i = 0; i < data.headlineLines.length; i++) ...[
          Text(
            data.headlineLines[i],
            textAlign: isCentered ? TextAlign.center : TextAlign.left,
            style: GoogleFonts.playfairDisplay(
              fontSize: isMobile ? 30 : 48,
              fontWeight: FontWeight.w400,
              height: 1.10,
              color: primaryColor,
              letterSpacing: 0.8,
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Subtitle Copy
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isCentered ? 520 : 440),
          child: Text(
            data.supportingCopy,
            textAlign: isCentered ? TextAlign.center : TextAlign.left,
            style: GoogleFonts.montserrat(
              fontSize: isMobile ? 13 : 15,
              height: 1.65,
              color: secondaryColor,
              letterSpacing: 0.3,
            ),
          ),
        ),

        // Category Chips (Scene 5)
        if (data.chips.isNotEmpty) ...[
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: isCentered ? WrapAlignment.center : WrapAlignment.start,
            children: data.chips.map((chip) {
              return InkWell(
                onTap: () {
                  final catMap = {
                    'Crowns & Tiaras': 'Imperial Jewels',
                    'Necklaces & Jewellery': 'Imperial Jewels',
                    'Royal Clothing': 'Royal Wardrobe',
                    'Palace Furniture': 'Palace Living',
                    'Tableware': 'Dining & Tableware',
                    'Cultural Artefacts': 'Treasures of the World',
                  };
                  final cat = catMap[chip] ?? 'Imperial Jewels';
                  context.go('/shop?category=${Uri.encodeComponent(cat)}');
                },
                borderRadius: BorderRadius.circular(2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFC8A45C)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    chip,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2A211B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _scrollToCollection,
            icon: const Icon(Icons.arrow_downward, size: 15, color: Colors.white),
            label: Text(
              'BROWSE COLLECTION REPERTORY',
              style: GoogleFonts.montserrat(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.8,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B1F3B),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSceneFigure(
    _CinematicSceneData data,
    bool isMobile,
    bool isLight, {
    bool compact = false,
  }) {
    final figureWidth = compact
        ? (isMobile ? 180.0 : 250.0)
        : (isMobile ? 240.0 : 380.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: figureWidth,
          constraints: BoxConstraints(
            maxHeight: isMobile ? 220 : 360,
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: isLight
                    ? const Color(0x180B1F3B)
                    : const Color(0xFFD4622A).withValues(alpha: 0.16),
                blurRadius: 24,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: isLight
                    ? Colors.black.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            data.imageAsset,
            fit: BoxFit.contain,
            semanticLabel: data.imageSemanticLabel,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 220,
                color: const Color(0xFF29262D),
                child: const Center(
                  child: Icon(Icons.castle_outlined, size: 48, color: Color(0xFFC8A45C)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          data.imageCaption,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            letterSpacing: 1.4,
            color: (isLight ? const Color(0xFF5B4D42) : const Color(0xFFD9C7A3))
                .withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Bottom Control Bar
  Widget _buildControlBar({required bool isMobile}) {
    final isLight = _scenes[_currentIndex].theme == 'light';
    final fgColor = isLight ? const Color(0xFF2A211B) : const Color(0xFFF3EAD9);
    final subColor = isLight ? const Color(0xFF5B4D42) : const Color(0xFFD9C7A3);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 16,
      ),
      child: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Previous Scene Button
            _buildRoundNavButton(
              icon: Icons.chevron_left,
              label: 'Previous scene',
              fgColor: fgColor,
              onPressed: () => _goTo(_currentIndex - 1, forward: false),
            ),

            // Play / Pause Autoplay Button
            _buildRoundNavButton(
              icon: _isPlaying ? Icons.pause : Icons.play_arrow,
              label: _isPlaying ? 'Pause autoplay' : 'Play autoplay',
              fgColor: fgColor,
              onPressed: _togglePlayPause,
            ),

            // Next Scene Button
            _buildRoundNavButton(
              icon: Icons.chevron_right,
              label: 'Next scene',
              fgColor: fgColor,
              onPressed: () => _goTo(_currentIndex + 1, forward: true),
            ),

            const SizedBox(width: 8),

            // Progress Indicators (5 dots with fill bar)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_scenes.length, (i) {
                final isCurrent = i == _currentIndex;

                return GestureDetector(
                  onTap: () => _goTo(i),
                  child: Container(
                    width: 38,
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    child: Stack(
                      children: [
                        // Background track line
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 2,
                              color: fgColor.withValues(alpha: 0.25),
                            ),
                          ),
                        ),

                        // Animated fill bar for active scene
                        if (isCurrent)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedBuilder(
                                animation: _autoplayController,
                                builder: (context, _) {
                                  final fillWidth = _isPlaying
                                      ? 30.0 * _autoplayController.value
                                      : 30.0;
                                  return Container(
                                    width: fillWidth,
                                    height: 2,
                                    color: const Color(0xFFC8A45C),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(width: 8),

            // Active Scene Name
            if (!isMobile)
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 160),
                child: Text(
                  _scenes[_currentIndex].name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: subColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundNavButton({
    required IconData icon,
    required String label,
    required Color fgColor,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: fgColor.withValues(alpha: 0.6), width: 1.0),
            color: Colors.black.withValues(alpha: 0.15),
          ),
          child: Icon(icon, color: fgColor, size: 20),
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
      data: data,
      width: width,
      onTap: () => context.go(data.route),
    );
  }
}

class _CollectionCardData {
  _CollectionCardData({
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
    required this.data,
    required this.width,
    required this.onTap,
  });

  final _CollectionCardData data;
  final double width;
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
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: widget.width,
          transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
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
                    ? const Color(0x200B1F3B)
                    : const Color(0x0A0B1F3B),
                blurRadius: _isHovered ? 18 : 8,
                offset: Offset(0, _isHovered ? 10 : 3),
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
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          scale: _isHovered ? 1.04 : 1.0,
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

/// Concentric Celestial Rings Painter for Scene 3 (Emblem)
class _CelestialOrbitalRingsPainter extends CustomPainter {
  const _CelestialOrbitalRingsPainter({required this.orbitProgress});

  final double orbitProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final minDim = math.min(size.width, size.height);
    final baseRadius = minDim * 0.42;

    final ringRatios = [0.14, 0.26, 0.40, 0.56, 0.74];

    for (int i = 0; i < ringRatios.length; i++) {
      final r = baseRadius * ringRatios[i];
      final circleAlpha = (1.0 - (ringRatios[i] * 100) / 110.0).clamp(0.2, 0.95);

      final paint = Paint()
        ..color = const Color(0xFFC8A45C).withValues(alpha: circleAlpha * 0.70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawCircle(center, r, paint);
    }

    // Highlight accent ring with firelight amber stroke & orbiting dash
    final hlRadius = baseRadius * 0.56;
    final hlRotation = orbitProgress * 2 * math.pi;
    final hlPaint = Paint()
      ..color = const Color(0xFFD4622A).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: hlRadius),
      hlRotation,
      math.pi * 0.20,
      false,
      hlPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CelestialOrbitalRingsPainter oldDelegate) {
    return oldDelegate.orbitProgress != orbitProgress;
  }
}
