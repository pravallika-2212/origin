import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/animation/dust_painter.dart';
import '../../core/animation/lotus_painter.dart';
import '../../core/animation/sway_widget.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/widgets/artefact_art.dart';
import '../../core/widgets/origin_button.dart';
import '../../core/widgets/origin_footer.dart';
import '../../core/widgets/origin_header.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/teaser_card.dart';
import '../../core/widgets/image_credit_dialog.dart';
import '../../core/widgets/origin_heritage_image.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_dialog.dart';
import 'origin_cinematic_section.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with TickerProviderStateMixin {
  // Intro controllers
  bool _showIntro = true;
  late final AnimationController _introController;
  late final Animation<double> _lotusDraw;
  late final Animation<double> _originFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _introExitFade;
  late final Animation<double> _introExitScale;

  // Hero slideshow
  int _curShowcase = 0;
  Timer? _showcaseTimer;
  final List<List<dynamic>> _showcaseData = [
    [ArtefactType.crown, 'Europe · Imperial Crown of Austria · Hofburg Vienna', 'assets/images/prod_austria_crown.jpg', 'img-habsburg-crown'],
    [ArtefactType.neck, 'India · Mughal Kundan & Emerald Necklace · The Met', 'assets/images/prod_kundan_necklace.jpg', 'img-kundan-necklace'],
    [ArtefactType.vase, 'China · Imperial Cobalt Dragon Porcelain · Wanli Period', 'assets/images/prod_ming_vase.jpg', 'img-ming-vase'],
    [ArtefactType.robe, 'Korea · Joseon Royal Court Robe (Wonsam)', 'assets/images/prod_korean_wonsam.jpg', 'img-joseon-wonsam'],
    [ArtefactType.fan, 'Japan · Heian Court Maki-e Lacquered Treasures', 'assets/images/prod_japan_makie.jpg', 'img-japan-makie'],
    [ArtefactType.box, 'Persia · Isfahan Khatamkari Royal Inlaid Casket', 'assets/images/prod_khatam_box.jpg', 'img-isfahan-casket'],
    [ArtefactType.chair, 'France · Versailles Giltwood Royal Console', 'assets/images/prod_versailles_console.jpg', 'img-versailles-console'],
  ];

  // Parallax on hero arches
  double _mouseX = 0.0;
  double _mouseY = 0.0;

  // Scroll & Teaser logic
  final _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _teaserShown = false;
  bool _teaserDismissed = false;

  // Civilization journey tabs
  int _selectedTab = 0;
  final List<Map<String, dynamic>> _civilizations = [
    {
      'country': 'India',
      'title': 'Rajput and Mughal Imperial Heritage',
      'desc':
          'Richly embroidered zari drapes, kundan and meenakari gemstone jewelry, and ceremonial treasury pieces crafted under the patronage of imperial ateliers.',
      'code': ArtefactType.neck,
      'bg': Color(0xFFF3E3C4),
      'image': 'assets/images/hero_mysore_durbar.jpg',
      'fallbackCode': 'neck',
    },
    {
      'country': 'China',
      'title': 'Forbidden City Imperial Court Traditions',
      'desc':
          'Embroidered nine-dragon court robes, carved lacquerware, jade ornaments, and celestial cobalt porcelain from the imperial kilns of Jingdezhen.',
      'code': ArtefactType.vase,
      'bg': Color(0xFFE6EDF4),
      'image': 'assets/images/hero_forbidden_city.jpg',
      'fallbackCode': 'vase',
    },
    {
      'country': 'Korea',
      'title': 'Joseon Palace Royal Heritage',
      'desc':
          'Sacred ceremonial court wonsam, jade norigae, and mother-of-pearl royal lacquerware inspired by court dress codes preserved in state archives.',
      'code': ArtefactType.robe,
      'bg': Color(0xFFE9E0F3),
      'image': 'assets/images/prod_korean_wonsam.jpg',
      'fallbackCode': 'robe',
    },
    {
      'country': 'Europe',
      'title': 'Grand Courts and Royal Coronations',
      'desc':
          'Imperial crowns, Sèvres royal dining porcelain, water-gilded console furniture, and haute couture court gowns from European royal houses.',
      'code': ArtefactType.crown,
      'bg': Color(0xFFF6DCD5),
      'image': 'assets/images/hero_versailles_hall.jpg',
      'fallbackCode': 'crown',
    },
    {
      'country': 'Persia & Ottoman',
      'title': 'Imperial Inlay, Velvet and Safavid Silk',
      'desc':
          'Master khatam marquetry caskets of Isfahan, Bursa voided silk velvets, and hand-knotted imperial Kashan silk carpets.',
      'code': ArtefactType.box,
      'bg': Color(0xFFEFE0CC),
      'image': 'assets/images/prod_khatam_box.jpg',
      'fallbackCode': 'box',
    },
    {
      'country': 'Japan',
      'title': 'Heian & Edo Court Masterpieces',
      'desc':
          'Gold and silver maki-e urushi lacquerware, silk ceremonial kimono with plum blossom embroidery, and imperial folding fans.',
      'code': ArtefactType.fan,
      'bg': Color(0xFFF7EBE2),
      'image': 'assets/images/prod_japan_makie.jpg',
      'fallbackCode': 'fan',
    },
    {
      'country': 'Africa',
      'title': 'Kingdom of Benin & Asante Sovereign Regalia',
      'desc':
          'Documented lost-wax relief brass court plaques with coral regalia, and Asante lost-wax solid river gold lion emblems of sacred kingship.',
      'code': ArtefactType.crown,
      'bg': Color(0xFFEAE3D6),
      'image': 'assets/images/prod_benin_bronze.jpg',
      'fallbackCode': 'crown',
    },
    {
      'country': 'The Americas',
      'title': 'Pre-Columbian Sovereign Gold Regalia',
      'desc':
          'Sacred repoussé Chimú native Andean sheet gold sun plaques and ceremonial beakers excavated and preserved with verified cultural provenance.',
      'code': ArtefactType.crown,
      'bg': Color(0xFFE3EBDE),
      'image': 'assets/images/prod_chimu_gold.jpg',
      'fallbackCode': 'crown',
    },
    {
      'country': 'Southeast Asia',
      'title': 'Royal Songket & Court Regalia',
      'desc':
          'Supplementary pure gold thread songket textiles of the Palembang Sultanate and ceremonial palace regalia preserved across Southeast Asian courts.',
      'code': ArtefactType.robe,
      'bg': Color(0xFFEFE6D8),
      'image': 'assets/images/prod_songket_palembang.jpg',
      'fallbackCode': 'robe',
    },
    {
      'country': 'Central Asia',
      'title': 'Silk Road Suzani & Royal Canopies',
      'desc':
          'Hand-embroidered Samarkand and Bukhara suzani wall canopies dyed with madder root and pomegranate rinds, capturing solar rosettes.',
      'code': ArtefactType.chair,
      'bg': Color(0xFFEBE0D2),
      'image': 'assets/images/prod_suzani_silk.jpg',
      'fallbackCode': 'chair',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Intro animation controller (total 8s)
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    // 1. Lotus draws itself line-by-line (0.0 to 3.2s / 8.0 = 0.0 to 0.4)
    _lotusDraw = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeInOut),
      ),
    );

    // 2. ORIGIN fades in at 2.4s (2.4 / 8.0 = 0.30 to 0.50)
    _originFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.30, 0.50, curve: Curves.easeIn),
      ),
    );

    // 3. "Where Royalty Begins." fades in at 4.0s (4.0 / 8.0 = 0.50 to 0.70)
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.50, 0.70, curve: Curves.easeIn),
      ),
    );

    // 4. Intro exit (6.6s to 8.0s): fade out & scale up to 1.12
    _introExitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.82, 1.0, curve: Curves.easeInOut),
      ),
    );

    _introExitScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.82, 1.0, curve: Curves.easeInOut),
      ),
    );

    _introController.forward().then((_) {
      if (mounted) setState(() => _showIntro = false);
    });

    // Start hero slideshow rotation every 4.5s
    _startShowcaseTimer();

    // Scroll listener for sticky header & teaser card
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _introController.dispose();
    _showcaseTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _skipIntro() {
    setState(() => _showIntro = false);
    _introController.stop();
  }

  void _startShowcaseTimer() {
    _showcaseTimer?.cancel();
    _showcaseTimer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
      if (mounted) {
        setState(() {
          _curShowcase = (_curShowcase + 1) % _showcaseData.length;
        });
      }
    });
  }

  void _onScroll() {
    if (!mounted) return;
    final offset = _scrollController.offset;
    final isScrolledNow = offset > 20;
    if (isScrolledNow != _isScrolled) {
      setState(() => _isScrolled = isScrolledNow);
    }

    // Teaser card trigger near product section (~700px scroll)
    final isSignedIn = ref.read(authControllerProvider).isSignedIn;
    if (!_teaserShown && !_teaserDismissed && !isSignedIn && offset > 600) {
      setState(() => _teaserShown = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productRepositoryProvider);
    final featuredProducts = products.where((p) => p.featured).toList();
    final isMobile = Breakpoints.isMobile(context);
    final isReducedMotion = Breakpoints.isReducedMotion(context);

    // If reduced motion is requested, skip intro immediately
    if (isReducedMotion && _showIntro) {
      _showIntro = false;
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main Scrollable Page
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Sticky Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  isScrolled: _isScrolled,
                  onSearchTap: () => context.go('/shop'),
                ),
              ),

              // Page Content Sections
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // C. HERO SECTION (Preserved)
                    _buildHeroSection(isMobile),

                    const SizedBox(height: 50),

                    // CINEMATIC SCROLL EXPERIENCE & COLLECTION SECTION
                    OriginCinematicSection(scrollController: _scrollController),

                    const SizedBox(height: 70),

                    // D. SHOP BY COLLECTION
                    _buildCollectionsSection(context),

                    const SizedBox(height: 80),

                    // E. FEATURED COLLECTION
                    _buildFeaturedSection(featuredProducts),

                    const SizedBox(height: 80),

                    // F. AUTHENTICITY AND PROVENANCE
                    _buildAuthenticitySection(),

                    const SizedBox(height: 80),

                    // G. QUOTE BAND
                    _buildQuoteBand(),

                    const SizedBox(height: 80),

                    // H. A JOURNEY ACROSS ROYAL CIVILIZATIONS
                    _buildJourneySection(),

                    const SizedBox(height: 80),

                    // I. THE ROYAL EDIT BANNER
                    _buildRoyalEditBanner(),

                    const SizedBox(height: 60),

                    // J. TRUST STRIP
                    _buildTrustStrip(isMobile),

                    // K. FOOTER
                    const OriginFooter(),
                  ],
                ),
              ),
            ],
          ),

          // A. INTRO SCREEN OVERLAY
          if (_showIntro)
            AnimatedBuilder(
              animation: _introController,
              builder: (context, child) {
                return Opacity(
                  opacity: _introExitFade.value,
                  child: Transform.scale(
                    scale: _introExitScale.value,
                    child: Container(
                      color: OriginColors.ivory,
                      child: Stack(
                        children: [
                          // Background radial gradient
                          Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment(0, -0.2),
                                radius: 0.85,
                                colors: [
                                  Color(0xFFFFFDF6),
                                  OriginColors.ivory,
                                ],
                              ),
                            ),
                          ),

                          // Gold dust particles
                          const DustParticlesWidget(particleCount: 70),

                          // Center Lotus & Title
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Lotus drawing itself line-by-line
                                SizedBox(
                                  width: 130,
                                  height: 130,
                                  child: CustomPaint(
                                    painter: LotusPainter(
                                      progress: _lotusDraw.value,
                                      strokeWidth: 2.0,
                                      color: OriginColors.goldDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // ORIGIN text fade in
                                Opacity(
                                  opacity: _originFade.value,
                                  child: Text(
                                    'ORIGIN',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 48,
                                      letterSpacing: 10,
                                      color: OriginColors.royalBronze,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // "Where Royalty Begins." italic tagline fade in
                                Opacity(
                                  opacity: _taglineFade.value,
                                  child: Text(
                                    'Where Royalty Begins.',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                      color: OriginColors.goldDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Skip Intro Button in bottom right
                          Positioned(
                            bottom: 32,
                            right: 32,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: OriginColors.gold),
                                backgroundColor: OriginColors.ivory.withValues(alpha: 0.8),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              ),
                              onPressed: _skipIntro,
                              child: Text(
                                'SKIP INTRO',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.2,
                                  color: OriginColors.goldDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // TEASER CARD SLIDE-IN
          TeaserCard(
            isVisible: _teaserShown && !_teaserDismissed,
            onDismiss: () => setState(() => _teaserDismissed = true),
          ),
        ],
      ),
    );
  }

  // C. HERO SECTION BUILDER
  Widget _buildHeroSection(bool isMobile) {
    return Container(
      constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3E6D0),
            Color(0xFFF8EFE0),
            Color(0xFFEFDCCB),
          ],
        ),
      ),
      child: isMobile
          ? Column(
              children: [
                _buildHeroText(isMobile),
                _buildHeroGallery(height: 380),
              ],
            )
          : Row(
              children: [
                Expanded(child: _buildHeroText(isMobile)),
                Expanded(child: _buildHeroGallery(height: 540)),
              ],
            ),
    );
  }

  Widget _buildHeroText(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 54,
        vertical: isMobile ? 36 : 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'LUXURY + HERITAGE + TIMELESS',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.5,
              color: OriginColors.goldDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ORIGIN',
            style: GoogleFonts.playfairDisplay(
              fontSize: isMobile ? 44 : 64,
              letterSpacing: 8,
              color: OriginColors.royalBronze,
              fontWeight: FontWeight.w400,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Where Royalty Begins.',
            style: GoogleFonts.playfairDisplay(
              fontSize: isMobile ? 20 : 26,
              fontStyle: FontStyle.italic,
              color: OriginColors.goldDark,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Explore extraordinary royal antiques and royal-inspired treasures. Each piece is presented with documented provenance, rich court tradition, and museum-grade care.',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              height: 1.6,
              color: OriginColors.inkLight,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            children: [
              OriginButton(
                text: 'GET STARTED',
                onPressed: () {
                  showAuthDialog(
                    context,
                    reason: 'Please register or log in to explore the royal collections.',
                  );
                },
              ),
              OriginButton(
                text: 'BROWSE THE COLLECTION',
                variant: OriginButtonVariant.outlined,
                onPressed: () => context.go('/shop'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroGallery({required double height}) {
    final curItem = _showcaseData[_curShowcase];

    return MouseRegion(
      onHover: (e) {
        setState(() {
          _mouseX = (e.localPosition.dx / 400.0) - 0.5;
          _mouseY = (e.localPosition.dy / height) - 0.5;
        });
      },
      onExit: (_) {
        setState(() {
          _mouseX = 0.0;
          _mouseY = 0.0;
        });
      },
      child: SizedBox(
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Back arch (shifts opposite to pointer)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              bottom: 0,
              left: 60 - (_mouseX * 14),
              right: 60 + (_mouseX * 14),
              height: height * 0.76 - (_mouseY * 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(999)),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF4E4CB), Color(0xFFE9D2B0)],
                  ),
                  border: Border.all(color: OriginColors.gold.withValues(alpha: 0.5)),
                ),
              ),
            ),

            // Front main arch (shifts with pointer at greater depth)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              bottom: 0,
              left: 30 + (_mouseX * 22),
              right: 30 - (_mouseX * 22),
              height: height * 0.88 + (_mouseY * 12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(999)),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFF8EA), Color(0xFFF1DFC4)],
                  ),
                  border: Border.all(color: OriginColors.gold.withValues(alpha: 0.7)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x289A7440),
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
              ),
            ),

            // Floor soft shadow
            Positioned(
              bottom: 60,
              child: Container(
                width: 220,
                height: 26,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x403C280A),
                      blurRadius: 36,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),

            // Rotating Showcase Artefact with 3D Sway Animation
            Positioned(
              bottom: 85,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 1200),
                transitionBuilder: (child, anim) {
                  return FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.0).animate(anim),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_curShowcase),
                  child: SwayingObject(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: height > 400 ? 255 : 200,
                        maxWidth: 280,
                      ),
                      child: Center(
                        child: OriginHeritageImage(
                          localAssetPath: curItem.length > 2 ? curItem[2] as String : null,
                          artefactCode: (curItem[0] as ArtefactType).name,
                          fit: BoxFit.contain,
                          height: height > 400 ? 250 : 195,
                          semanticLabel: curItem[1] as String,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Caption with provenance icon
            Positioned(
              bottom: 34,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      curItem[1] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.3,
                        color: const Color(0xFF6B5330),
                      ),
                    ),
                  ),
                  if (curItem.length > 3) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => showImageCreditDialog(
                        context,
                        imageSourceId: curItem[3] as String,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.info_outline,
                          size: 13,
                          color: OriginColors.goldDark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Slideshow indicators (dots)
            Positioned(
              bottom: 14,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_showcaseData.length, (idx) {
                  final isCurrent = idx == _curShowcase;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _curShowcase = idx);
                      _startShowcaseTimer();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isCurrent ? 28 : 16,
                      height: 3,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? OriginColors.goldDark
                            : OriginColors.goldDark.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // D. SHOP BY COLLECTION SECTION
  Widget _buildCollectionsSection(BuildContext context) {
    final categories = ref.watch(productRepositoryProvider.notifier).getCategories();

    return Container(
      constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop by Collection',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: OriginColors.royalBronze,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Royal treasures for every moment and heirloom space.',
                    style: GoogleFonts.montserrat(
                      fontSize: 13.5,
                      color: OriginColors.inkMuted,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.go('/shop'),
                child: Text(
                  'View All Collections →',
                  style: GoogleFonts.montserrat(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: OriginColors.goldDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // 3-Column Grid of Collections
          LayoutBuilder(
            builder: (ctx, constraints) {
              int crossAxisCount = 3;
              if (constraints.maxWidth < 650) {
                crossAxisCount = 1;
              } else if (constraints.maxWidth < 950) {
                crossAxisCount = 2;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (ctx, idx) {
                  final cat = categories[idx];
                  return _CollectionCard(category: cat);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // E. FEATURED COLLECTION SECTION
  Widget _buildFeaturedSection(List<Product> products) {
    return Container(
      constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Collection',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: OriginColors.royalBronze,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Authenticated museum antiques and royal-inspired treasures.',
                    style: GoogleFonts.montserrat(
                      fontSize: 13.5,
                      color: OriginColors.inkMuted,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.go('/shop'),
                child: Text(
                  'View Full Catalogue →',
                  style: GoogleFonts.montserrat(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: OriginColors.goldDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Grid of Product Cards
          LayoutBuilder(
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
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.64,
                ),
                itemBuilder: (ctx, idx) => ProductCard(product: products[idx]),
              );
            },
          ),
        ],
      ),
    );
  }

  // F. AUTHENTICITY AND PROVENANCE CARDS
  Widget _buildAuthenticitySection() {
    final cards = [
      {
        'icon': Icons.verified_outlined,
        'title': 'Certificate of Authenticity',
        'desc': 'Every genuine antique is accompanied by a registered Certificate of Provenance with archival ledgers and non-destructive laboratory spectroscopic analysis.',
      },
      {
        'icon': Icons.auto_stories_outlined,
        'title': 'Story of the Piece',
        'desc': 'We unearth the royal court, specific monarchial era, historical craftsmanship technique, and spiritual significance behind each creation.',
      },
      {
        'icon': Icons.visibility_outlined,
        'title': 'Private Viewing & Offers',
        'desc': 'Request private 1-on-1 video consultations with our senior curators, high-resolution microscope streams, or submit purchase offers for rare pieces.',
      },
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'Export & Shipping Care',
        'desc': 'Strict compliance with international cultural property conventions (UNESCO 1970). Climate-controlled armored courier delivery directly to your estate.',
      },
    ];

    return Container(
      constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'AUTHENTICITY & HERITAGE GUARANTEE',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              color: OriginColors.goldDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Building Royal Trust Across Centuries',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: OriginColors.royalBronze,
            ),
          ),
          const SizedBox(height: 36),

          LayoutBuilder(
            builder: (ctx, constraints) {
              int cols = 4;
              if (constraints.maxWidth < 650) {
                cols = 1;
              } else if (constraints.maxWidth < 950) {
                cols = 2;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (ctx, idx) {
                  final c = cards[idx];
                  return Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: OriginColors.cardBorder),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(c['icon'] as IconData, size: 28, color: OriginColors.goldDark),
                        const SizedBox(height: 14),
                        Text(
                          c['title'] as String,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: OriginColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            c['desc'] as String,
                            style: GoogleFonts.montserrat(
                              fontSize: 12.5,
                              height: 1.5,
                              color: OriginColors.inkLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // G. QUOTE BAND
  Widget _buildQuoteBand() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          // Gold diamond divider
          CustomPaint(
            size: const Size(160, 14),
            painter: _DiamondDividerPainter(),
          ),
          const SizedBox(height: 24),
          Text(
            '“Every treasure carries a story. Every story leaves a legacy.”',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontStyle: FontStyle.italic,
              color: OriginColors.royalBronze,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // H. A JOURNEY ACROSS ROYAL CIVILIZATIONS
  Widget _buildJourneySection() {
    final curCiv = _civilizations[_selectedTab];

    return Container(
      constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A Journey Across Royal Civilizations',
            style: GoogleFonts.playfairDisplay(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: OriginColors.royalBronze,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Each royal tradition is presented on its own terms with dedicated court history.',
            style: GoogleFonts.montserrat(
              fontSize: 13.5,
              color: OriginColors.inkMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Civilization tabs
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_civilizations.length, (idx) {
              final isSel = idx == _selectedTab;
              return InkWell(
                onTap: () => setState(() => _selectedTab = idx),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSel ? OriginColors.goldDark : Colors.transparent,
                    border: Border.all(
                      color: isSel ? OriginColors.goldDark : OriginColors.gold.withValues(alpha: 0.6),
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    _civilizations[idx]['country'] as String,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: isSel ? Colors.white : OriginColors.ink,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Tab Content Panel
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey<int>(_selectedTab),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: OriginColors.cardBorder),
                borderRadius: BorderRadius.circular(4),
              ),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final isNarrow = constraints.maxWidth < 700;
                  final textCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${curCiv['country']}: ${curCiv['title']}',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: OriginColors.royalBronze,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        curCiv['desc'] as String,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          height: 1.6,
                          color: OriginColors.inkLight,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.verified, size: 13, color: OriginColors.goldDark),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Verified historical artefacts & museum archive provenance',
                              style: GoogleFonts.montserrat(
                                fontSize: 11.5,
                                color: OriginColors.goldDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      OriginButton(
                        text: 'EXPLORE ${curCiv['country'].toString().toUpperCase()} TRADITION',
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        fontSize: 11,
                        onPressed: () {
                          context.go('/heritage/${curCiv['country']}');
                        },
                      ),
                    ],
                  );

                  final artCol = Container(
                    height: 260,
                    decoration: BoxDecoration(
                      color: curCiv['bg'] as Color,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: OriginColors.gold.withValues(alpha: 0.5)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        OriginHeritageImage(
                          localAssetPath: curCiv['image'] as String?,
                          artefactCode: curCiv['fallbackCode'] as String?,
                          fit: BoxFit.cover,
                          semanticLabel: curCiv['title'] as String?,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                              ],
                              stops: const [0.65, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 14,
                          right: 14,
                          child: Text(
                            'AUTHENTIC ARCHIVAL SPECIMEN · ${curCiv['country'].toString().toUpperCase()}',
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  return isNarrow
                      ? Column(
                          children: [
                            artCol,
                            const SizedBox(height: 24),
                            textCol,
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(flex: 3, child: textCol),
                            const SizedBox(width: 32),
                            Expanded(flex: 2, child: artCol),
                          ],
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // I. THE ROYAL EDIT BANNER
  Widget _buildRoyalEditBanner() {
    return Container(
      constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 42),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFE1C9),
            Color(0xFFF7ECDA),
            Color(0xFFF1DCD5),
          ],
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
        runSpacing: 20,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THE ROYAL EDIT',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.8,
                  color: OriginColors.goldDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Curated Essays & Imperial Court Chronicles',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: OriginColors.royalBronze,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Text(
                  'Immerse yourself in deep-dive historical narratives on forgotten goldsmithing techniques, royal coronation attire, and palace treasury inventories.',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    height: 1.5,
                    color: OriginColors.inkLight,
                  ),
                ),
              ),
            ],
          ),
          OriginButton(
            text: 'EXPLORE THE JOURNAL',
            onPressed: () => context.go('/journal'),
          ),
        ],
      ),
    );
  }

  // J. TRUST STRIP
  Widget _buildTrustStrip(bool isMobile) {
    final trustItems = [
      {'title': 'Worldwide Shipping', 'sub': 'To your palace doorstep'},
      {'title': 'Secure Payments', 'sub': 'Fully encrypted & audited'},
      {'title': 'Easy Returns', 'sub': '14-day insured guarantee'},
      {'title': 'Royal Concierge', 'sub': 'Dedicated heritage advisors'},
    ];

    return Container(
      constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          int cols = 4;
          if (constraints.maxWidth < 950) {
            cols = 2;
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: trustItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: cols == 4 ? 3.2 : 2.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (ctx, idx) {
              final t = trustItems[idx];
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t['title']!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: OriginColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t['sub']!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        color: OriginColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Collection Card helper
class _CollectionCard extends StatefulWidget {
  const _CollectionCard({required this.category});

  final dynamic category;

  @override
  State<_CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<_CollectionCard> {
  bool _hovered = false;


  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.go('/shop?category=${Uri.encodeComponent(widget.category.name)}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: _hovered ? OriginColors.gold : OriginColors.cardBorder,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: _hovered ? const Color(0x289A7440) : const Color(0x08000000),
                blurRadius: _hovered ? 24 : 8,
                offset: Offset(0, _hovered ? 10 : 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photographic Art Panel with smooth hover scale
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: widget.category.bgColor as Color),
                      AnimatedScale(
                        scale: _hovered ? 1.06 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: OriginHeritageImage(
                          localAssetPath: widget.category.localAssetPath as String?,
                          networkUrl: widget.category.imageUrl as String?,
                          artefactCode: widget.category.artefactCode as String?,
                          fit: BoxFit.cover,
                          semanticLabel: widget.category.name as String?,
                        ),
                      ),
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
                            widget.category.name as String,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w600,
                              color: OriginColors.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.category.tagline as String,
                            style: GoogleFonts.montserrat(
                              fontSize: 11.5,
                              color: OriginColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 200),
                      offset: _hovered ? const Offset(0.3, 0) : Offset.zero,
                      child: const Text(
                        '→',
                        style: TextStyle(
                          color: OriginColors.goldDark,
                          fontSize: 18,
                        ),
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

// Diamond Divider CustomPainter for Quote Band
class _DiamondDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final goldLine = Paint()
      ..color = OriginColors.gold
      ..strokeWidth = 1.0;

    final darkDiamond = Paint()
      ..color = OriginColors.goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final cy = size.height / 2;

    // Left line: 0 to 62
    canvas.drawLine(Offset(0, cy), Offset(62, cy), goldLine);
    // Right line: 98 to 160
    canvas.drawLine(Offset(98, cy), Offset(160, cy), goldLine);

    // Diamond: 80 1, 87 7, 80 13, 73 7
    final diamond = Path()
      ..moveTo(80, 1)
      ..lineTo(87, 7)
      ..lineTo(80, 13)
      ..lineTo(73, 7)
      ..close();
    canvas.drawPath(diamond, darkDiamond);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Persistent Header Delegate for Sticky Header
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickyHeaderDelegate({required this.isScrolled, required this.onSearchTap});

  final bool isScrolled;
  final VoidCallback onSearchTap;

  @override
  double get minExtent => 68;

  @override
  double get maxExtent => 68;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return OriginHeader(isScrolled: shrinkOffset > 0 || isScrolled, onSearchTap: onSearchTap);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return oldDelegate.isScrolled != isScrolled;
  }
}
