import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/widgets/origin_button.dart';
import '../../core/widgets/origin_toast.dart';
import 'auth_controller.dart';

Future<bool?> showAuthDialog(
  BuildContext context, {
  required String reason,
  bool initialIsRegister = true,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x8C2E2414),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => AuthDialog(
      reason: reason,
      initialIsRegister: initialIsRegister,
    ),
    transitionBuilder: (context, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class AuthDialog extends ConsumerStatefulWidget {
  const AuthDialog({
    super.key,
    required this.reason,
    this.initialIsRegister = true,
  });

  final String reason;
  final bool initialIsRegister;

  @override
  ConsumerState<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends ConsumerState<AuthDialog> {
  late bool _isRegister;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'United States');

  String? _inlineError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.initialIsRegister;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _inlineError = null;
      _isLoading = true;
    });

    final auth = ref.read(authControllerProvider.notifier);
    bool success = false;

    if (_isRegister) {
      success = await auth.register(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        phone: _phoneCtrl.text,
        country: _countryCtrl.text,
      );
    } else {
      success = await auth.login(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final user = ref.read(authControllerProvider).user;
      showOriginToast(
        context,
        'Welcome to the royal circle, ${user?.firstName ?? "Patron"}',
      );
      Navigator.of(context).pop(true);
    } else {
      final err = ref.read(authControllerProvider).errorMessage ??
          'Authentication failed. Please check your details.';
      setState(() => _inlineError = err);
    }
  }

  Future<void> _submitGoogle() async {
    setState(() {
      _inlineError = null;
      _isLoading = true;
    });

    final success = await ref.read(authControllerProvider.notifier).loginWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final user = ref.read(authControllerProvider).user;
      showOriginToast(
        context,
        'Welcome to the royal circle, ${user?.firstName ?? "Patron"}',
      );
      Navigator.of(context).pop(true);
    }
  }

  void _quickDemoLogin({required bool asAdmin}) {
    if (asAdmin) {
      ref.read(authControllerProvider.notifier).switchToAdminDemo();
      showOriginToast(context, 'Signed in as Imperial Curator (Admin)');
    } else {
      ref.read(authControllerProvider.notifier).switchToMemberDemo();
      showOriginToast(context, 'Signed in as Princess Sophia (Member)');
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: OriginColors.ivoryLight,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: OriginColors.gold, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x662E2414),
                blurRadius: 36,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: Brand & Close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ORIGIN',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        letterSpacing: 4,
                        color: OriginColors.royalBronze,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: OriginColors.inkLight),
                      onPressed: () => Navigator.of(context).pop(false),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Reason line from PRD
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: OriginColors.blushLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: OriginColors.gold.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 15, color: OriginColors.goldDark),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.reason,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: OriginColors.royalBronze,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tab Switcher (Register / Login)
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() {
                          _isRegister = true;
                          _inlineError = null;
                        }),
                        child: Column(
                          children: [
                            Text(
                              'REGISTER',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: _isRegister
                                    ? OriginColors.goldDark
                                    : OriginColors.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 2,
                              color: _isRegister
                                  ? OriginColors.goldDark
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() {
                          _isRegister = false;
                          _inlineError = null;
                        }),
                        child: Column(
                          children: [
                            Text(
                              'LOG IN',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: !_isRegister
                                    ? OriginColors.goldDark
                                    : OriginColors.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 2,
                              color: !_isRegister
                                  ? OriginColors.goldDark
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Inline Error message if any
                if (_inlineError != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8E8),
                      border: Border.all(color: Colors.redAccent, width: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _inlineError!,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Form Fields
                if (_isRegister) ...[
                  _buildTextField(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    hint: 'e.g. Lady Vivienne Montgomery',
                  ),
                  const SizedBox(height: 14),
                ],

                _buildTextField(
                  controller: _emailCtrl,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  hint: 'name@domain.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _passwordCtrl,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  hint: 'Minimum 6 characters',
                  obscureText: true,
                ),

                if (_isRegister) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _phoneCtrl,
                          label: 'Phone (Optional)',
                          icon: Icons.phone_outlined,
                          hint: '+1 ...',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _countryCtrl,
                          label: 'Country',
                          icon: Icons.public_outlined,
                          hint: 'Country',
                        ),
                      ),
                    ],
                  ),
                ],

                if (!_isRegister) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        showOriginToast(
                          context,
                          'Password reset instructions sent to ${_emailCtrl.text.isEmpty ? "your email" : _emailCtrl.text}',
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: OriginColors.goldDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Primary Submit Button
                OriginButton(
                  text: _isRegister ? 'JOIN THE ROYAL CIRCLE' : 'ENTER ORIGIN',
                  isFullWidth: true,
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),

                // Google Sign In
                OriginButton(
                  text: 'CONTINUE WITH GOOGLE',
                  variant: OriginButtonVariant.outlined,
                  isFullWidth: true,
                  icon: const Icon(Icons.g_mobiledata, size: 22),
                  onPressed: _isLoading ? null : _submitGoogle,
                ),
                const SizedBox(height: 20),

                // Quick Demo Preset buttons for pairing evaluation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: OriginColors.sageLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: OriginColors.sage.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'QUICK DEMO SHORTCUTS',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: OriginColors.inkLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: OriginColors.goldDark),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              onPressed: () => _quickDemoLogin(asAdmin: false),
                              child: Text(
                                'Member Demo',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: OriginColors.goldDark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: OriginColors.royalBronze),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              onPressed: () => _quickDemoLogin(asAdmin: true),
                              child: Text(
                                'Admin Demo',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: OriginColors.royalBronze,
                                ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: OriginColors.inkLight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.montserrat(fontSize: 13, color: OriginColors.ink),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: OriginColors.goldDark),
            hintText: hint,
            hintStyle: GoogleFonts.montserrat(
              fontSize: 12,
              color: OriginColors.inkMuted.withValues(alpha: 0.6),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: OriginColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: OriginColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: OriginColors.goldDark, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
