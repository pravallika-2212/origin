import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/widgets/artefact_art.dart';
import '../../core/widgets/origin_footer.dart';
import '../../core/widgets/origin_header.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/origin_heritage_image.dart';
import '../../data/repositories/product_repository.dart';

class HeritagePage extends ConsumerWidget {
  const HeritagePage({super.key, required this.country});

  final String country;

  String _getCountryImagePath(String c) {
    final lower = c.toLowerCase();
    if (lower.contains('india')) return 'assets/images/hero_mysore_durbar.jpg';
    if (lower.contains('china')) return 'assets/images/hero_forbidden_city.jpg';
    if (lower.contains('korea')) return 'assets/images/prod_korean_wonsam.jpg';
    if (lower.contains('europe')) return 'assets/images/hero_versailles_hall.jpg';
    if (lower.contains('persia') || lower.contains('ottoman')) return 'assets/images/prod_khatam_box.jpg';
    if (lower.contains('japan')) return 'assets/images/prod_japan_makie.jpg';
    if (lower.contains('africa')) return 'assets/images/prod_benin_bronze.jpg';
    if (lower.contains('america')) return 'assets/images/prod_chimu_gold.jpg';
    if (lower.contains('asia') || lower.contains('indonesia') || lower.contains('thailand')) return 'assets/images/prod_songket_palembang.jpg';
    return 'assets/images/hero_versailles_hall.jpg';
  }

  ArtefactType _getArtefactType(String c) {
    final lower = c.toLowerCase();
    if (lower.contains('india')) return ArtefactType.neck;
    if (lower.contains('china')) return ArtefactType.vase;
    if (lower.contains('korea')) return ArtefactType.robe;
    if (lower.contains('europe')) return ArtefactType.crown;
    if (lower.contains('persia')) return ArtefactType.box;
    if (lower.contains('america')) return ArtefactType.crown;
    return ArtefactType.lotus;
  }

  Map<String, dynamic> _getHeritageData(String c) {
    final lower = c.toLowerCase();
    if (lower.contains('india')) {
      return {
        'title': 'The Sovereign Courts of India',
        'subtitle': 'Mughal Imperial Splendor & Rajput Chivalric Regalia',
        'lore':
            'From the marbled courtyards of the Red Fort in Delhi to the desert fortresses of Amber and Udaipur, Indian royal court jewelry represented the pinnacle of gemstone refinement. The Mughal emperors elevated the Kundan foil-setting and Meenakari champlevé enameling into sacred arts, while royal banaras silks adorned sovereign durbars across the subcontinent.',
        'timeline': [
          {'year': 'c. 1526–1707', 'event': 'The Golden Age of Mughal Goldsmithing under Akbar and Shah Jahan.'},
          {'year': 'c. 1740', 'event': 'Flourishing of provincial royal treasuries in Patiala, Hyderabad, and Awadh.'},
          {'year': 'c. 1911', 'event': 'Imperial Delhi Durbar jewelry commissions merging Cartier Paris and Indian maharajas.'},
        ],
        'credits': 'Archival imagery and historical ledgers courtesy of the Patiala State Toshakhana Records and Gemmological Institute of India.',
      };
    } else if (lower.contains('china')) {
      return {
        'title': 'The Celestial Empire of China',
        'subtitle': 'Ming & Qing Dynasties Imperial Kilns and Dragon Robes',
        'lore':
            'For millennia, the Son of Heaven governed within the Forbidden City, where yellow silk, mutton-fat jade, and celestial blue porcelain served as tangible conduits of the Mandate of Heaven. The imperial kilns of Jingdezhen were guarded like state secrets, producing porcelain of such mathematical and chromatic precision that imperfect specimens were smashed to protect the emperor’s divine prestige.',
        'timeline': [
          {'year': 'c. 1368–1644', 'event': 'Ming Dynasty: Wanli period blue-and-white porcelain and gold repoussé filigree.'},
          {'year': 'c. 1735–1796', 'event': 'Qianlong Emperor reign: Zenith of imperial textile weaving and cloisonné enamel.'},
        ],
        'credits': 'Archival documentation referenced from the National Palace Museum and Jingdezhen Imperial Kiln Museum Archives.',
      };
    } else if (lower.contains('korea')) {
      return {
        'title': 'The Joseon Dynasty of Korea',
        'subtitle': 'Court Etiquette, Five Cosmic Elements & The Wonsam',
        'lore':
            'Governed by Neo-Confucian harmony and profound respect for ancestral balance, the five-hundred-year Joseon royal court of Seoul maintained rigorous sartorial codes. Royal consorts wore hand-woven silk Wonsam embroidered with cloud roundels, paired with gold-embossed hairpins (binyeo) and norigae tassels made with precious jade.',
        'timeline': [
          {'year': 'c. 1392', 'event': 'Establishment of the Joseon Dynasty and codification of royal dress in the Gyeongguk Daejeon.'},
          {'year': 'c. 1897', 'event': 'Proclamation of the Korean Empire: elevation of imperial yellow court dress.'},
        ],
        'credits': 'Textile records referenced from the National Palace Museum of Korea.',
      };
    } else if (lower.contains('europe')) {
      return {
        'title': 'Coronations of Europe',
        'subtitle': 'Habsburg, Bourbon, Romanov & British Dynastic Diadems',
        'lore':
            'European sovereign regalia was characterized by the divine right of kings, manifested in chiseled gold diadems set with old-mine diamonds and river pearls. Master court jewelers such as Köchert in Vienna, Chaumet in Paris, and Garrard in London competed to forge heirloom diadems worn at coronation banquets and imperial congresses.',
        'timeline': [
          {'year': 'c. 1804', 'event': 'Napoleonic coronation regalia created by French imperial goldsmiths.'},
          {'year': 'c. 1867', 'event': 'Austro-Hungarian Compromise: Archducal diadems forged by Köchert Vienna.'},
        ],
        'credits': 'Archival court ledgers referenced from the Kunsthistorisches Museum Vienna and European Royal Jewel Archives.',
      };
    } else if (lower.contains('persia')) {
      return {
        'title': 'The Persian and Ottoman Empires',
        'subtitle': 'Khatam Marquetry, Isfahan Metalwork & Topkapi Regalia',
        'lore':
            'In the golden bazaar workshops of Isfahan and Istanbul, artisans forged decorative masterworks that intertwined Islamic sacred geometry with royal luxury. Khatam marquetry combined hundreds of thousands of micro-tesserae of camel bone, silver wire, and precious woods to create caskets worthy of royal decrees and royal jewels.',
        'timeline': [
          {'year': 'c. 1587–1629', 'event': 'Safavid renaissance in Isfahan under Shah Abbas I.'},
          {'year': 'c. 1794–1925', 'event': 'Qajar court atelier boom in fine enamel and micro-inlaid woodwork.'},
        ],
        'credits': 'Court archives referenced from the Topkapi Palace Museum and Isfahan Heritage Master Guild.',
      };
    } else {
      return {
        'title': 'Pre-Columbian Regalia of The Americas',
        'subtitle': 'The Sacred Gold Metallurgy of Andean Sovereign Lords',
        'lore':
            'In the sacred kingdoms of Chimú, Moche, and Inka, gold was reverently regarded as the sweat of the Sun God Inti. Andean master metallurgists hammered sheets of high-karat native gold into repoussé crowns, ear flares, and pectorals, combining divine cosmology with aristocratic rulership centuries before European contact.',
        'timeline': [
          {'year': 'c. 900–1470 CE', 'event': 'Chimú Kingdom: Peak of sheet-gold repoussé regalia in Chan Chan.'},
          {'year': 'c. 1438–1533 CE', 'event': 'Inka Empire: Consolidation of imperial gold metallurgy in Cusco.'},
        ],
        'credits': 'Archaeological documentation compliant with UNESCO 1970 convention regulations.',
      };
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = _getHeritageData(country);
    final allProducts = ref.watch(productRepositoryProvider);
    final civProducts = allProducts.where((p) {
      final match = p.civilization.toLowerCase().contains(country.toLowerCase()) ||
          p.country.toLowerCase().contains(country.toLowerCase());
      return match;
    }).toList();
    final isMobile = Breakpoints.isMobile(context);

    return Scaffold(
      appBar: const OriginHeader(isScrolled: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Heritage Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF4EAD8),
                    OriginColors.ivory,
                    Color(0xFFEBD7CB),
                  ],
                ),
                border: Border(bottom: BorderSide(color: OriginColors.cardBorder)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ROYAL CIVILIZATION ODYSSEY',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3,
                                color: OriginColors.goldDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['title'] as String,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: isMobile ? 32 : 46,
                                fontWeight: FontWeight.w400,
                                color: OriginColors.royalBronze,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['subtitle'] as String,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: isMobile ? 16 : 20,
                                fontStyle: FontStyle.italic,
                                color: OriginColors.goldDark,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              data['lore'] as String,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                height: 1.7,
                                color: OriginColors.inkLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(width: 48),
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(110),
                            border: Border.all(color: OriginColors.gold, width: 2),
                            boxShadow: const [
                              BoxShadow(color: Color(0x289A7440), blurRadius: 28),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: OriginHeritageImage(
                            localAssetPath: _getCountryImagePath(country),
                            artefactCode: _getArtefactType(country).name,
                            fit: BoxFit.cover,
                            semanticLabel: '$country Royal Heritage Specimen',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Timeline & Court Tradition
            Container(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HISTORICAL CHRONOLOGY',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                      color: OriginColors.goldDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Milestones of Sovereign Craftsmanship',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: OriginColors.royalBronze,
                    ),
                  ),
                  const SizedBox(height: 28),

                  for (final item in data['timeline'] as List<Map<String, String>>)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: OriginColors.goldDark,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              item['year']!,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              item['event']!,
                              style: GoogleFonts.montserrat(
                                fontSize: 13.5,
                                height: 1.5,
                                color: OriginColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: OriginColors.cardBorder),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance, size: 20, color: OriginColors.goldDark),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            data['credits'] as String,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: OriginColors.inkMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: OriginColors.cardBorder),

            // Products from this civilization
            Container(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COLLECTION PIECES',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                      color: OriginColors.goldDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Treasures of $country',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: OriginColors.royalBronze,
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (civProducts.isEmpty)
                    Text(
                      'No pieces currently published for this civilization.',
                      style: GoogleFonts.montserrat(fontSize: 13, color: OriginColors.inkMuted),
                    )
                  else
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
                          itemCount: civProducts.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.68,
                          ),
                          itemBuilder: (ctx, idx) => ProductCard(product: civProducts[idx]),
                        );
                      },
                    ),
                ],
              ),
            ),

            const OriginFooter(),
          ],
        ),
      ),
    );
  }
}
