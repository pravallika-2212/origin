import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/auth_dialog.dart';
import 'origin_button.dart';

class TeaserCard extends ConsumerWidget {
  const TeaserCard({
    super.key,
    required this.isVisible,
    required this.onDismiss,
  });

  final bool isVisible;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    if (authState.isSignedIn) return const SizedBox.shrink();

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      bottom: isVisible ? 24 : -260,
      right: 24,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: isVisible ? 1.0 : 0.0,
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: OriginColors.ivoryLight,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: OriginColors.gold, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x385A3C14),
                blurRadius: 28,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: OriginColors.goldDark),
                      const SizedBox(width: 6),
                      Text(
                        'THE ROYAL PRIVILEGE',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: OriginColors.goldDark,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: onDismiss,
                    child: const Icon(Icons.close, size: 16, color: OriginColors.inkMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'There is more to explore.',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: OriginColors.royalBronze,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Register to save pieces to your royal collection, request private viewings, and get early access to newly discovered arrivals.',
                style: GoogleFonts.montserrat(
                  fontSize: 12.5,
                  height: 1.5,
                  color: OriginColors.inkLight,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OriginButton(
                      text: 'REGISTER / LOGIN',
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      fontSize: 10.5,
                      onPressed: () {
                        onDismiss();
                        showAuthDialog(
                          context,
                          reason: 'Please register or log in to unlock royal features.',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onDismiss,
                    child: Text(
                      'Maybe later',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: OriginColors.inkMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
