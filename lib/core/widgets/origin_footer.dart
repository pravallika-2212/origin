import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/utils/breakpoints.dart';
import '../animation/lotus_painter.dart';
import 'origin_toast.dart';
import 'image_credit_dialog.dart';

class OriginFooter extends StatefulWidget {
  const OriginFooter({super.key});

  @override
  State<OriginFooter> createState() => _OriginFooterState();
}

class _OriginFooterState extends State<OriginFooter> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _subscribeNewsletter() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      showOriginToast(context, 'Please enter a valid email address.', isError: true);
      return;
    }
    showOriginToast(context, 'Thank you for joining the royal circle');
    _emailCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: const BoxDecoration(
        color: Color(0xFF14110F),
        border: Border(
          top: BorderSide(color: Color(0x38D4AF7C), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Main content row
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 36,
                runSpacing: 32,
                children: [
                  // Brand & Editorial Statement
                  Container(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 26,
                              height: 26,
                              child: CustomPaint(
                                painter: LotusPainter(
                                  progress: 1.0,
                                  strokeWidth: 1.8,
                                  color: OriginColors.goldLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'ORIGIN',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                letterSpacing: 4.5,
                                color: OriginColors.ivory,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Where Royalty Begins.',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: OriginColors.gold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'A curated sovereign repertory of certified royal antiques, imperial regalia, and living heirlooms preserved from historic dynasties worldwide.',
                          style: GoogleFonts.montserrat(
                            fontSize: 12.5,
                            height: 1.6,
                            color: const Color(0xFFB5A898),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Navigation Columns
                  Wrap(
                    spacing: 36,
                    runSpacing: 20,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COLLECTIONS',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.2,
                              color: OriginColors.goldLight,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _FooterLink(label: 'Imperial Jewels', onTap: () => context.go('/shop?category=Imperial%20Jewels')),
                          const SizedBox(height: 10),
                          _FooterLink(label: 'Royal Wardrobe', onTap: () => context.go('/shop?category=Royal%20Wardrobe')),
                          const SizedBox(height: 10),
                          _FooterLink(label: 'Palace Living', onTap: () => context.go('/shop?category=Palace%20Living')),
                          const SizedBox(height: 10),
                          _FooterLink(label: 'Dining & Tableware', onTap: () => context.go('/shop?category=Dining%20%26%20Tableware')),
                          const SizedBox(height: 10),
                          _FooterLink(label: 'Treasures of the World', onTap: () => context.go('/shop?category=Treasures%20of%20the%20World')),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DISCOVERY',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.2,
                              color: OriginColors.goldLight,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _FooterLink(label: 'The Curated Shop', onTap: () => context.go('/shop')),
                          const SizedBox(height: 10),
                          _FooterLink(label: 'Heritage Journal', onTap: () => context.go('/journal')),
                          const SizedBox(height: 10),
                          _FooterLink(label: 'Authenticity & Provenance', onTap: () => context.go('/authenticity')),
                          const SizedBox(height: 10),
                          _FooterLink(label: 'Private Salon Viewing', onTap: () => context.go('/help')),
                          const SizedBox(height: 10),
                          _FooterLink(label: 'About the Foundation', onTap: () => context.go('/about')),
                        ],
                      ),
                    ],
                  ),

                  // Newsletter Subscription
                  Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THE ROYAL CIRCLE',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.2,
                            color: OriginColors.goldLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Receive private salon invitations and curated acquisitions direct from the vaults.',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            height: 1.5,
                            color: const Color(0xFFB5A898),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.montserrat(fontSize: 12.5, color: OriginColors.ivory),
                                decoration: InputDecoration(
                                  hintText: 'Enter your email address',
                                  hintStyle: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: const Color(0xFF7E7264),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF1E1A17),
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(3),
                                    ),
                                    borderSide: const BorderSide(color: Color(0x38D4AF7C)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(3),
                                    ),
                                    borderSide: const BorderSide(color: Color(0x38D4AF7C)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(3),
                                    ),
                                    borderSide: const BorderSide(color: OriginColors.gold),
                                  ),
                                ),
                                onSubmitted: (_) => _subscribeNewsletter(),
                              ),
                            ),
                            InkWell(
                              onTap: _subscribeNewsletter,
                              child: Container(
                                height: 46,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: const BoxDecoration(
                                  color: OriginColors.goldDark,
                                  borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(3),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              const Divider(color: Color(0x24D4AF7C)),
              const SizedBox(height: 24),

              // Legal line & copyright
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 14,
                runSpacing: 8,
                children: [
                  Text(
                    '© 2026 ORIGIN IMPERIAL HERITAGE. ALL RIGHTS RESERVED.',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: const Color(0xFF7A6E60),
                    ),
                  ),
                  const Text('·', style: TextStyle(color: Color(0xFF7A6E60))),
                  _LegalLink(label: 'Privacy Policy', onTap: () => context.go('/privacy')),
                  const Text('·', style: TextStyle(color: Color(0xFF7A6E60))),
                  _LegalLink(label: 'Terms of Service', onTap: () => context.go('/terms')),
                  const Text('·', style: TextStyle(color: Color(0xFF7A6E60))),
                  _LegalLink(label: 'Archival & Museum Provenance', onTap: () => showFullRegistryDialog(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.montserrat(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: _hovered ? OriginColors.goldLight : const Color(0xFFD4C7B8),
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _LegalLink extends StatefulWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_LegalLink> createState() => _LegalLinkState();
}

class _LegalLinkState extends State<_LegalLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.montserrat(
            fontSize: 11,
            letterSpacing: 0.8,
            color: _hovered ? OriginColors.goldLight : const Color(0xFF8A7E70),
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
