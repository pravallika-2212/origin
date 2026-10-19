import 'package:flutter/material.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/widgets/origin_footer.dart';
import '../../core/widgets/origin_header.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalScaffold(
      kicker: 'OUR MISSION',
      title: 'About ORIGIN',
      subtitle: 'Where Royalty Begins and Sovereign Stories Endure',
      content: '''ORIGIN was established in 2026 as a luxury heritage bridge between forgotten imperial courts and discerning collectors worldwide.

We believe that true royal treasures cannot be understood in isolation from the courts, artisans, and historical struggles that brought them into existence. Every object in our repository—from seventeenth-century Mughal kundan collars to Joseon court wonsam and Habsburg coronation diadems—is curated alongside its living narrative.

Our curatorial headquarters are based in Zurich, with archival research outposts in London, Kyoto, and New Delhi. We work in direct partnership with accredited gemmologists, independent museum historians, and traditional hereditary craft guilds to preserve endangered artisanal traditions.

Whether acquiring a verified historic antique or an heirloom piece inspired by palace court culture, every patron becomes a custodian of living human heritage.''',
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalScaffold(
      kicker: 'CONFIDENTIALITY & SECURITY',
      title: 'Privacy Policy',
      subtitle: 'Discretion and Protection of Royal Patron Data',
      content: '''1. Information We Collect
We collect personal identification information including legal names, confidential estate addresses, email addresses, and contact preferences exclusively to execute acquisition orders, arrange private viewing consultations, and prepare official Certificates of Provenance.

2. Discretion in Private Viewings & Acquisition Inquiries
All inquiries, private video streams, and valuation offers are treated with strict diplomatic confidentiality. We never publish member identity details or transaction amounts.

3. Payment Security & Data Retention
Payment details are processed through encrypted financial institutions complying with PCI-DSS Tier 1 protocols. ORIGIN does not store credit card CVV credentials.

4. Cultural Compliance & Verification Records
Provenance certificates and export audit documentation are securely preserved in encrypted vault archives for historical verification purposes as required by international antiquities compliance.''',
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalScaffold(
      kicker: 'LEGAL COVENANT',
      title: 'Terms of Service',
      subtitle: 'Conditions of Acquisition and Heritage Custody',
      content: '''1. Acceptance of Terms
By accessing the ORIGIN repository or creating a royal member account, you agree to these Terms of Service.

2. Accuracy of Provenance & Attribution
ORIGIN guarantees the authenticity of all pieces tagged as Certified Antique for a lifetime. If any certified piece is definitively proven by an accredited international museum tribunal to be misattributed, ORIGIN will issue a full refund upon return of the artifact in its original condition.

3. Export Permitting & Pre-Payment Authorization
For genuine antiquities requiring origin government export authorization, acquisition funds are authorized and held in escrow. Final charging occurs only upon issuance of valid export certification.

4. Single-Quantity Unique Pieces
Antiques are one-of-a-kind museum pieces. In the rare event of concurrent acquisition attempts, priority is granted based on verified timestamp order submission.''',
    );
  }
}

class ShippingPage extends StatelessWidget {
  const ShippingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalScaffold(
      kicker: 'WHITE-GLOVE LOGISTICS',
      title: 'Shipping and Returns',
      subtitle: 'Armored Transport, Export Regulations & 14-Day Guarantee',
      content: '''1. Armored Courier Delivery
Every certified artifact and royal-inspired creation is dispatched in custom-engineered, shock-absorbent, climate-stabilized sealed cases. Deliveries are executed via bonded art couriers with armed escort services available upon request.

2. International Cultural Export Clearance
Before international dispatch of certified antiques, our legal team verifies origin state antiquities permits (e.g. UNESCO 1970 and national antiquities acts). The client will receive tracking updates directly from our Zurich vault dispatch bureau.

3. 14-Day Insured Inspection & Return Policy
Patrons have 14 days from estate delivery receipt to inspect the piece with their independent gemmological advisor. If not completely enchanted, the piece may be returned in its un-tampered archival seal for a full acquisition refund. Return armored transport is arranged directly by the ORIGIN concierge.''',
    );
  }
}

class _LegalScaffold extends StatelessWidget {
  const _LegalScaffold({
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.content,
  });

  final String kicker;
  final String title;
  final String subtitle;
  final String content;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return Scaffold(
      appBar: const OriginHeader(isScrolled: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF7F0),
                border: Border(bottom: BorderSide(color: OriginColors.cardBorder)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    children: [
                      Text(
                        kicker,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.8,
                          color: OriginColors.goldDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isMobile ? 32 : 44,
                          fontWeight: FontWeight.w400,
                          color: OriginColors.royalBronze,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: OriginColors.goldDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: OriginColors.cardBorder),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final paragraph in content.split('\n\n')) ...[
                      Text(
                        paragraph,
                        style: GoogleFonts.montserrat(
                          fontSize: 14.5,
                          height: 1.8,
                          color: OriginColors.ink,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            const OriginFooter(),
          ],
        ),
      ),
    );
  }
}
