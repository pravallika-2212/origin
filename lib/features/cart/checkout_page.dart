import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/origin_button.dart';
import '../../core/widgets/origin_footer.dart';
import '../../core/widgets/origin_header.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/currency_provider.dart';
import '../../data/repositories/order_repository.dart';
import '../auth/auth_controller.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  int _currentStep = 0;

  // Address Step Controllers
  final _nameCtrl = TextEditingController(text: 'Lady Eleanor Vance');
  final _addressCtrl = TextEditingController(text: 'Kensington Palace Gardens 12');
  final _cityCtrl = TextEditingController(text: 'London');
  final _countryCtrl = TextEditingController(text: 'United Kingdom');
  final _postalCtrl = TextEditingController(text: 'W8 4QP');

  // Shipping Method
  String _shippingMethod = 'White-Glove Art Courier & Armored Escort (Switzerland/UK Vault Dispatch)';

  // Payment method
  final _cardNumberCtrl = TextEditingController(text: '•••• •••• •••• 1884');
  final _cardExpCtrl = TextEditingController(text: '12/29');
  final _cardCvvCtrl = TextEditingController(text: '884');

  bool _isProcessing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _postalCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardExpCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = ref.read(cartProvider);
    final user = ref.read(authControllerProvider).user;
    if (cart.items.isEmpty) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 900));

    final order = ref.read(orderRepositoryProvider.notifier).createOrder(
      userId: user?.uid ?? 'guest_uid',
      items: cart.items,
      address: _addressCtrl.text,
      city: _cityCtrl.text,
      country: _countryCtrl.text,
      postalCode: _postalCtrl.text,
      shippingMethod: _shippingMethod,
      subtotalUsd: cart.subtotalUsd,
      shippingCostUsd: cart.shippingCostUsd,
    );

    // Clear cart
    ref.read(cartProvider.notifier).clear();

    if (!mounted) return;
    setState(() => _isProcessing = false);

    context.go('/order-success/${order.id}');
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final currency = ref.watch(currencyProvider);
    final isMobile = Breakpoints.isMobile(context);

    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: const OriginHeader(isScrolled: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Your bag is empty', style: GoogleFonts.playfairDisplay(fontSize: 22)),
              const SizedBox(height: 12),
              OriginButton(text: 'SHOP REPOSITORY', onPressed: () => context.go('/shop')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const OriginHeader(isScrolled: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF7F0),
                border: Border(bottom: BorderSide(color: OriginColors.cardBorder)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                  child: Column(
                    children: [
                      Text(
                        'SECURE WHITE-GLOVE CHECKOUT',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.8,
                          color: OriginColors.goldDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Estate Delivery & Provenance Transfer',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isMobile ? 26 : 34,
                          fontWeight: FontWeight.w500,
                          color: OriginColors.royalBronze,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Stepper and checkout contents
            Container(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final isWide = constraints.maxWidth > 850;

                  final form = _buildCheckoutForm();
                  final summary = _buildCartMiniSummary(cart, currency);

                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: form),
                            const SizedBox(width: 48),
                            Expanded(flex: 4, child: summary),
                          ],
                        )
                      : Column(
                          children: [
                            form,
                            const SizedBox(height: 36),
                            summary,
                          ],
                        );
                },
              ),
            ),

            const OriginFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 3-Step Indicator Bar
        Row(
          children: [
            _buildStepTab(0, '1. Address & Estate'),
            _buildStepTab(1, '2. Courier Method'),
            _buildStepTab(2, '3. Simulated Settlement'),
          ],
        ),
        const SizedBox(height: 28),

        // Step 0: Address
        if (_currentStep == 0) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: OriginColors.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DELIVERY & ARCHIVAL RECIPIENT',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: OriginColors.goldDark,
                  ),
                ),
                const SizedBox(height: 18),

                _buildInput(label: 'Full Legal Name for Certificate', controller: _nameCtrl),
                const SizedBox(height: 14),

                _buildInput(label: 'Estate / Street Address', controller: _addressCtrl),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(child: _buildInput(label: 'City', controller: _cityCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInput(label: 'Postal / ZIP Code', controller: _postalCtrl)),
                  ],
                ),
                const SizedBox(height: 14),

                _buildInput(label: 'Destination Country', controller: _countryCtrl),
                const SizedBox(height: 20),

                // Antique Export Compliance notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: OriginColors.sageLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: OriginColors.royalBronze),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'International cultural export licenses are prepared by our Zurich legal bureau prior to vault dispatch.',
                          style: GoogleFonts.montserrat(fontSize: 11.5, color: OriginColors.inkLight),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                OriginButton(
                  text: 'PROCEED TO COURIER METHOD',
                  onPressed: () => setState(() => _currentStep = 1),
                ),
              ],
            ),
          ),
        ],

        // Step 1: Shipping Method
        if (_currentStep == 1) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: OriginColors.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT WHITE-GLOVE COURIER DISPATCH',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: OriginColors.goldDark,
                  ),
                ),
                const SizedBox(height: 18),

                _buildShippingOption(
                  title: 'White-Glove Art Courier & Armored Escort',
                  desc: 'Direct hand delivery by bonded heritage couriers in custom climate-sealed crates.',
                  time: '3–5 business days',
                  selected: _shippingMethod.contains('White-Glove'),
                  onSelect: () => setState(() => _shippingMethod =
                      'White-Glove Art Courier & Armored Escort (Switzerland/UK Vault Dispatch)'),
                ),
                const SizedBox(height: 12),

                _buildShippingOption(
                  title: 'Royal Insured Air Express',
                  desc: 'Insured priority priority air freight with continuous biometric custody tracking.',
                  time: '5–7 business days',
                  selected: _shippingMethod.contains('Royal Insured'),
                  onSelect: () => setState(() => _shippingMethod = 'Royal Insured Air Express'),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: OriginColors.cardBorder),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                      onPressed: () => setState(() => _currentStep = 0),
                      child: Text('BACK', style: GoogleFonts.montserrat(color: OriginColors.inkLight)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OriginButton(
                        text: 'PROCEED TO SETTLEMENT',
                        onPressed: () => setState(() => _currentStep = 2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        // Step 2: Payment
        if (_currentStep == 2) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: OriginColors.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SIMULATED SETTLEMENT (OCTOBER 2026 ASSIGNMENT)',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: OriginColors.goldDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No real money is charged. Payment is fully simulated per assignment specification.',
                  style: GoogleFonts.montserrat(fontSize: 12, color: OriginColors.inkMuted),
                ),
                const SizedBox(height: 18),

                _buildInput(label: 'Card Number', controller: _cardNumberCtrl),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(child: _buildInput(label: 'Expires (MM/YY)', controller: _cardExpCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInput(label: 'Security Code (CVV)', controller: _cardCvvCtrl)),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: OriginColors.cardBorder),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                      onPressed: () => setState(() => _currentStep = 1),
                      child: Text('BACK', style: GoogleFonts.montserrat(color: OriginColors.inkLight)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OriginButton(
                        text: 'CONFIRM & ACQUIRE HEIRLOOMS',
                        isLoading: _isProcessing,
                        onPressed: _placeOrder,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStepTab(int step, String label) {
    final isCurrent = _currentStep == step;
    final isPast = _currentStep > step;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentStep = step),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isCurrent || isPast ? OriginColors.goldDark : OriginColors.cardBorder,
                width: isCurrent ? 2.5 : 1.0,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 11.5,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isCurrent ? OriginColors.goldDark : OriginColors.inkMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: OriginColors.inkLight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: GoogleFonts.montserrat(fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: OriginColors.ivoryLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: OriginColors.cardBorder),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShippingOption({
    required String title,
    required String desc,
    required String time,
    required bool selected,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? OriginColors.ivoryDark.withValues(alpha: 0.5) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? OriginColors.goldDark : OriginColors.cardBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? OriginColors.goldDark : OriginColors.inkMuted,
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: GoogleFonts.montserrat(fontSize: 11.5, color: OriginColors.inkMuted),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: OriginColors.royalBronze,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartMiniSummary(CartState cart, Currency currency) {
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
          Text(
            'ACQUISITION SUMMARY',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: OriginColors.goldDark,
            ),
          ),
          const SizedBox(height: 16),

          for (final item in cart.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} (x${item.quantity})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(fontSize: 12.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    OriginFormatters.formatPrice(item.total, currency),
                    style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: GoogleFonts.montserrat(fontSize: 13)),
              Text(
                OriginFormatters.formatPrice(cart.subtotalUsd, currency),
                style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Insured Armored Courier', style: GoogleFonts.montserrat(fontSize: 13)),
              Text(
                cart.shippingCostUsd == 0 ? 'Complimentary' : OriginFormatters.formatPrice(cart.shippingCostUsd, currency),
                style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payable',
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                OriginFormatters.formatPrice(cart.totalUsd, currency),
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: OriginColors.royalBronze,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
