import 'package:flutter/material.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/widgets/origin_footer.dart';
import '../../core/widgets/origin_header.dart';

class AuthenticityPage extends StatelessWidget {
  const AuthenticityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return Scaffold(
      appBar: const OriginHeader(isScrolled: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF3EAD8),
                    OriginColors.ivory,
                    Color(0xFFEBDCD3),
                  ],
                ),
                border: Border(bottom: BorderSide(color: OriginColors.cardBorder)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                  child: Column(
                    children: [
                      Text(
                        'AUTHENTICITY, PROVENANCE & CARE',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                          color: OriginColors.goldDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The ORIGIN Standard of Royal Custody',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isMobile ? 32 : 44,
                          fontWeight: FontWeight.w400,
                          color: OriginColors.royalBronze,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Text(
                          'Our four-pillar methodology for historical verification, laboratory material analysis, legal export compliance, and archival preservation.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            height: 1.6,
                            color: OriginColors.inkLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Sections
            Container(
              constraints: const BoxConstraints(maxWidth: 880),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    icon: Icons.biotech_outlined,
                    kicker: 'PILLAR I',
                    title: 'Non-Destructive Laboratory Examination',
                    body:
                        'Before any piece enters the ORIGIN collection, it undergoes multi-spectral analysis. For precious gold regalia, X-ray fluorescence (XRF) determines exact metallurgical karat compositions without scraping or damaging surfaces. Gemstones are examined for thermal treatments, glass fillings, and geographical origin (e.g. unheated Ceylon sapphires or Old Mine Colombian emeralds).',
                  ),
                  const SizedBox(height: 40),

                  _buildSection(
                    icon: Icons.history_edu,
                    kicker: 'PILLAR II',
                    title: 'Documented Provenance & Archival Ledgers',
                    body:
                        'We adhere to an absolute rule: no antique is ever attributed to a historical monarch or named royal house without corroborated documentary evidence. Provenance records cross-reference palace Toshakhana (treasury) inventories, colonial exhibition registries, Sotheby’s/Christie’s archival ledgers, and court jeweler commission records.',
                  ),
                  const SizedBox(height: 40),

                  _buildSection(
                    icon: Icons.rule_folder_outlined,
                    kicker: 'PILLAR III',
                    title: 'Rigorous Distinction: Antiques vs. Royal-Inspired',
                    body:
                        'Transparency is our guiding creed. Every catalogue item is permanently labelled with one of two tags:\n\n'
                        '• Certified Antique: Authentic historical artifacts verified by independent historians and gemmological authorities. Accompanied by registered Certificates of Authenticity with non-destructive laboratory testing and complete ownership timeline.\n\n'
                        '• Royal-Inspired: Contemporary master creations handcrafted by heritage guilds using historic lost-wax casting, hand-loomed gold zari, and traditional techniques inspired by archival museum masterworks.',
                  ),
                  const SizedBox(height: 40),

                  _buildSection(
                    icon: Icons.public,
                    kicker: 'PILLAR IV',
                    title: 'International Export & UNESCO 1970 Compliance',
                    body:
                        'Antiquities over 100 years of age are subject to strict cultural property laws (including the 1970 UNESCO Convention on Cultural Property and national statutes such as India’s Antiquities and Art Treasures Act 1972). ORIGIN never transports illicit heritage. Before processing payment for international delivery of genuine antiques, our legal council verifies origin export permits.',
                  ),
                  const SizedBox(height: 48),

                  const Divider(color: OriginColors.cardBorder),
                  const SizedBox(height: 36),

                  // Care Guidelines Box
                  Text(
                    'CURATORIAL CARE & PRESERVATION GUIDELINES',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: OriginColors.goldDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Preserving Heirlooms for Future Generations',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: OriginColors.royalBronze,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildCareTip('Kundan & Enamel Jewelry', 'Never immerse in liquid cleaners or ultrasonic machines. Moisture damages the foil seal behind the stones. Clean gently with micro-fiber cloth and natural goat-hair brushes.'),
                  const SizedBox(height: 12),
                  _buildCareTip('Historic Silk Textiles & Zari', 'Keep away from direct sunlight and humidity. Store flat between acid-free archival tissue paper in breathable cedarwood boxes.'),
                  const SizedBox(height: 12),
                  _buildCareTip('Gilded Furniture & Khatam Marquetry', 'Maintain constant 45–55% relative humidity to prevent wood shrinkage and ivory tesserae lifting. Dust only with dry ostrich-feather dusters.'),
                ],
              ),
            ),

            const OriginFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String kicker,
    required String title,
    required String body,
  }) {
    return Container(
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
              Icon(icon, size: 24, color: OriginColors.goldDark),
              const SizedBox(width: 10),
              Text(
                kicker,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: OriginColors.goldDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: OriginColors.royalBronze,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              height: 1.7,
              color: OriginColors.inkLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareTip(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OriginColors.ivoryDark,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield, size: 18, color: OriginColors.goldDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.montserrat(fontSize: 12.5, color: OriginColors.inkLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
