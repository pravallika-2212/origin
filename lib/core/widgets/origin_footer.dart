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
      margin: const EdgeInsets.only(top: 60),
      color: OriginColors.sageLight,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Main content row
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 32,
                runSpacing: 28,
                children: [
                  // Brand & Tagline
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CustomPaint(
                              painter: LotusPainter(
                                progress: 1.0,
                                strokeWidth: 1.8,
                                color: OriginColors.goldDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ORIGIN',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              letterSpacing: 4,
                              color: OriginColors.royalBronze,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Where Royalty Begins.',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: OriginColors.goldDark,
                        ),
                      ),
                    ],
                  ),

                  // Navigation links
                  Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    children: [
                      _FooterLink(label: 'Shop', onTap: () => context.go('/shop')),
                      _FooterLink(label: 'About', onTap: () => context.go('/about')),
                      _FooterLink(label: 'Journal', onTap: () => context.go('/journal')),
                      _FooterLink(label: 'Authenticity', onTap: () => context.go('/authenticity')),
                      _FooterLink(label: 'Help & Contact', onTap: () => context.go('/help')),
                    ],
                  ),

                  // Newsletter subscription form
                  Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.montserrat(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Your email address',
                              hintStyle: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: OriginColors.inkMuted,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(3),
                                ),
                                borderSide: const BorderSide(color: OriginColors.sage),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(3),
                                ),
                                borderSide: const BorderSide(color: OriginColors.sage),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(3),
                                ),
                                borderSide: const BorderSide(color: OriginColors.goldDark),
                              ),
                            ),
                            onSubmitted: (_) => _subscribeNewsletter(),
                          ),
                        ),
                        InkWell(
                          onTap: _subscribeNewsletter,
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
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
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              const Divider(color: Color(0x338CA68B)),
              const SizedBox(height: 20),

              // Legal line & copyright
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    '© 2026 ORIGIN. All rights reserved.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: const Color(0xFF66705F),
                    ),
                  ),
                  const Text('·', style: TextStyle(color: Color(0xFF66705F))),
                  _LegalLink(label: 'Privacy Policy', onTap: () => context.go('/privacy')),
                  const Text('·', style: TextStyle(color: Color(0xFF66705F))),
                  _LegalLink(label: 'Terms of Service', onTap: () => context.go('/terms')),
                  const Text('·', style: TextStyle(color: Color(0xFF66705F))),
                  _LegalLink(label: 'Shipping & Returns', onTap: () => context.go('/shipping')),
                  const Text('·', style: TextStyle(color: Color(0xFF66705F))),
                  _LegalLink(label: 'Archival Rights & Provenance', onTap: () => showFullRegistryDialog(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: OriginColors.ink,
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          color: const Color(0xFF66705F),
        ),
      ),
    );
  }
}
