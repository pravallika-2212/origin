import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/services/payment_api_service.dart';
import '../../core/services/razorpay/razorpay_service.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/origin_button.dart';
import '../../core/widgets/origin_footer.dart';
import '../../core/widgets/origin_header.dart';
import '../../data/models/order.dart';
import '../../data/models/product.dart';
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

  // Form Controllers
  final _nameCtrl = TextEditingController(text: 'Lady Eleanor Vance');
  final _emailCtrl = TextEditingController(text: 'eleanor.vance@origin-patrons.org');
  final _phoneCtrl = TextEditingController(text: '+91 98765 43210');
  final _addressCtrl = TextEditingController(text: 'Kensington Palace Gardens 12');
  final _cityCtrl = TextEditingController(text: 'London');
  final _countryCtrl = TextEditingController(text: 'United Kingdom');
  final _postalCtrl = TextEditingController(text: 'W8 4QP');

  // Shipping Method
  String _shippingMethod = 'White-Glove Art Courier & Armored Escort (Switzerland/UK Vault Dispatch)';

  // Processing & Verification State
  bool _isProcessing = false;
  String _statusMessage = '';
  String? _errorMessage;
  String? _noticeMessage;

  // Active Pending Order Reference
  String? _activeOrderId;

  final Map<String, String> _fieldErrors = {};

  final PaymentApiService _apiService = PaymentApiService();
  final RazorpayService _razorpayService = RazorpayService();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  bool _validateFields() {
    setState(() {
      _fieldErrors.clear();
      if (_nameCtrl.text.trim().length < 2) {
        _fieldErrors['name'] = 'Legal name is required for archival transfer.';
      }
      final email = _emailCtrl.text.trim();
      if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
        _fieldErrors['email'] = 'Valid email is required for certificate delivery.';
      }
      if (_phoneCtrl.text.trim().length < 7) {
        _fieldErrors['phone'] = 'Contact number is required for courier & UPI settlement.';
      }
      if (_addressCtrl.text.trim().length < 4) {
        _fieldErrors['address'] = 'Street or estate address is required.';
      }
      if (_cityCtrl.text.trim().isEmpty) {
        _fieldErrors['city'] = 'City is required for diplomatic routing.';
      }
      if (_postalCtrl.text.trim().isEmpty) {
        _fieldErrors['postal'] = 'Postal / ZIP code is required.';
      }
      if (_countryCtrl.text.trim().isEmpty) {
        _fieldErrors['country'] = 'Destination country is required.';
      }
    });

    return _fieldErrors.isEmpty;
  }

  Future<void> _initiateRazorpayPayment() async {
    if (_isProcessing) return;

    if (!_validateFields()) {
      setState(() {
        _currentStep = 0;
        _errorMessage = 'Please complete all required recipient and delivery fields before settlement.';
      });
      return;
    }

    final cart = ref.read(cartProvider);
    final user = ref.read(authControllerProvider).user;
    final currency = ref.read(currencyProvider);

    if (cart.items.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _noticeMessage = null;
      _statusMessage = 'Authorizing order with vault server...';
    });

    try {
      // 1. Create order on server (validates prices authoritatively from server catalog)
      final orderRes = await _apiService.createOrder(
        items: cart.items,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        postalCode: _postalCtrl.text.trim(),
        shippingMethod: _shippingMethod,
        currency: currency,
        userId: user?.uid ?? 'guest_uid',
      );

      if (!orderRes.success) {
        setState(() {
          _isProcessing = false;
          _errorMessage = orderRes.error ?? 'Order creation was declined by the server.';
        });
        return;
      }

      _activeOrderId = orderRes.orderId;

      // Register internal pending order in local repository
      ref.read(orderRepositoryProvider.notifier).createOrder(
            id: orderRes.orderId,
            userId: user?.uid ?? 'guest_uid',
            customerName: _nameCtrl.text.trim(),
            customerEmail: _emailCtrl.text.trim(),
            customerPhone: _phoneCtrl.text.trim(),
            items: cart.items,
            address: _addressCtrl.text.trim(),
            city: _cityCtrl.text.trim(),
            country: _countryCtrl.text.trim(),
            postalCode: _postalCtrl.text.trim(),
            shippingMethod: _shippingMethod,
            subtotalUsd: cart.subtotalUsd,
            shippingCostUsd: cart.shippingCostUsd,
            razorpayOrderId: orderRes.razorpayOrderId,
            paymentStatus: OrderPaymentStatus.pending,
          );

      if (!mounted) return;
      setState(() {
        _statusMessage = 'Awaiting payment authorization via Razorpay...';
      });

      // 2. Launch Razorpay Checkout Modal
      final rzpResult = await _razorpayService.openCheckout(
        keyId: orderRes.keyId,
        razorpayOrderId: orderRes.razorpayOrderId,
        amountInSubunits: orderRes.amountInSubunits,
        currency: orderRes.currency,
        customerName: _nameCtrl.text.trim(),
        customerEmail: _emailCtrl.text.trim(),
        customerPhone: _phoneCtrl.text.trim(),
        description: 'Custody Transfer — Order ${orderRes.orderId}',
      );

      if (!mounted) return;

      // 3. Handle Razorpay Result States
      if (rzpResult.isDismissed) {
        setState(() {
          _isProcessing = false;
          _noticeMessage = 'Checkout was cancelled. Your order has not been confirmed as paid. You may retry whenever ready.';
        });
        return;
      }

      if (rzpResult.isFailure) {
        ref.read(orderRepositoryProvider.notifier).updatePaymentStatus(
              orderRes.orderId,
              OrderPaymentStatus.failed,
            );

        setState(() {
          _isProcessing = false;
          _errorMessage = "We couldn't confirm your payment: ${rzpResult.errorMessage ?? 'Payment was declined by issuer'}. You can retry after checking your payment status.";
        });
        return;
      }

      // 4. Payment Authorized by User -> Cryptographically Verify Signature on Backend
      setState(() {
        _statusMessage = 'Cryptographically verifying payment signature with server...';
      });

      final verifyRes = await _apiService.verifyPayment(
        orderId: orderRes.orderId,
        razorpayOrderId: rzpResult.razorpayOrderId ?? orderRes.razorpayOrderId,
        razorpayPaymentId: rzpResult.razorpayPaymentId ?? '',
        razorpaySignature: rzpResult.razorpaySignature ?? '',
      );

      if (!mounted) return;

      if (verifyRes.success && verifyRes.verified) {
        // Authoritative verification confirmed
        ref.read(orderRepositoryProvider.notifier).updatePaymentStatus(
              orderRes.orderId,
              OrderPaymentStatus.paid,
              paymentId: rzpResult.razorpayPaymentId,
            );

        // Clear bag
        ref.read(cartProvider.notifier).clear();

        setState(() => _isProcessing = false);
        context.go('/order-success/${orderRes.orderId}');
      } else {
        setState(() {
          _isProcessing = false;
          _errorMessage = verifyRes.error ?? 'Payment signature verification failed. Please check order status.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  Future<void> _checkPendingOrderStatus() async {
    if (_activeOrderId == null) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Querying authoritative order status...';
    });

    try {
      final orderData = await _apiService.getOrderStatus(_activeOrderId!);
      if (!mounted) return;

      if (orderData != null && orderData['paymentStatus'] == 'paid') {
        ref.read(orderRepositoryProvider.notifier).updatePaymentStatus(
              _activeOrderId!,
              OrderPaymentStatus.paid,
              paymentId: orderData['razorpayPaymentId'] as String?,
            );
        ref.read(cartProvider.notifier).clear();
        setState(() => _isProcessing = false);
        context.go('/order-success/$_activeOrderId');
      } else {
        setState(() {
          _isProcessing = false;
          _noticeMessage = 'Your payment is being confirmed. Please avoid paying again until the status is checked.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Could not verify status with server. Please retry in a few moments.';
      });
    }
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
            // Top Luxury Banner
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

            // Notice / Error Alert Banners
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                color: const Color(0xFFFDE8E8),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFF9B1C1C), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.montserrat(fontSize: 12.5, color: const Color(0xFF9B1C1C), fontWeight: FontWeight.w500),
                          ),
                        ),
                        if (_activeOrderId != null)
                          TextButton(
                            onPressed: _checkPendingOrderStatus,
                            child: Text('CHECK STATUS', style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF9B1C1C))),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Color(0xFF9B1C1C)),
                          onPressed: () => setState(() => _errorMessage = null),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (_noticeMessage != null)
              Container(
                width: double.infinity,
                color: const Color(0xFFFEF08A).withValues(alpha: 0.35),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: OriginColors.royalBronze, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _noticeMessage!,
                            style: GoogleFonts.montserrat(fontSize: 12.5, color: OriginColors.royalBronze, fontWeight: FontWeight.w500),
                          ),
                        ),
                        if (_activeOrderId != null)
                          TextButton(
                            onPressed: _checkPendingOrderStatus,
                            child: Text('REFRESH STATUS', style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: OriginColors.royalBronze)),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: OriginColors.royalBronze),
                          onPressed: () => setState(() => _noticeMessage = null),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Stepper and Content
            Container(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final isWide = constraints.maxWidth > 850;
                  final form = _buildCheckoutForm(currency);
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

  Widget _buildCheckoutForm(Currency currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 3-Step Indicator Bar
        Row(
          children: [
            _buildStepTab(0, '1. Recipient & Estate'),
            _buildStepTab(1, '2. Courier Method'),
            _buildStepTab(2, '3. Payment & Settlement'),
          ],
        ),
        const SizedBox(height: 28),

        // Step 0: Recipient & Address Details
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

                _buildInput(
                  label: 'Full Legal Name for Provenance Certificate',
                  controller: _nameCtrl,
                  errorText: _fieldErrors['name'],
                ),
                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInput(
                        label: 'Email (For Certificate & Receipts)',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _fieldErrors['email'],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildInput(
                        label: 'Contact Phone (For Courier & UPI)',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        errorText: _fieldErrors['phone'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _buildInput(
                  label: 'Estate / Street Address',
                  controller: _addressCtrl,
                  errorText: _fieldErrors['address'],
                ),
                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInput(
                        label: 'City',
                        controller: _cityCtrl,
                        errorText: _fieldErrors['city'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInput(
                        label: 'Postal / ZIP Code',
                        controller: _postalCtrl,
                        errorText: _fieldErrors['postal'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _buildInput(
                  label: 'Destination Country',
                  controller: _countryCtrl,
                  errorText: _fieldErrors['country'],
                ),
                const SizedBox(height: 20),

                // Compliance Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: OriginColors.sageLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 16, color: OriginColors.royalBronze),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Archival provenance documents and international cultural export permits are authorized by our Geneva & London registry bureaus.',
                          style: GoogleFonts.montserrat(fontSize: 11.5, color: OriginColors.inkLight),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                OriginButton(
                  text: 'PROCEED TO COURIER METHOD',
                  onPressed: () {
                    if (_validateFields()) {
                      setState(() => _currentStep = 1);
                    }
                  },
                ),
              ],
            ),
          ),
        ],

        // Step 1: Courier Method Selection
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
                  desc: 'Direct hand delivery by bonded heritage couriers in custom climate-sealed crates with diplomatic escort.',
                  time: '3–5 business days',
                  selected: _shippingMethod.contains('White-Glove'),
                  onSelect: () => setState(() => _shippingMethod =
                      'White-Glove Art Courier & Armored Escort (Switzerland/UK Vault Dispatch)'),
                ),
                const SizedBox(height: 12),

                _buildShippingOption(
                  title: 'Royal Insured Air Express',
                  desc: 'Insured priority priority air freight with continuous biometric custody tracking and vault inspection.',
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

        // Step 2: Payment & Settlement via Razorpay
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'SECURE RAZORPAY PAYMENT GATEWAY',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                          color: OriginColors.goldDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: OriginColors.ivoryDark,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: OriginColors.goldDark, width: 0.8),
                      ),
                      child: Text(
                        '256-BIT ENCRYPTED',
                        style: GoogleFonts.montserrat(fontSize: 9.5, fontWeight: FontWeight.w700, color: OriginColors.royalBronze),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Settle seamlessly using India UPI, Credit/Debit Cards, Net Banking, or International Cards via official Razorpay Checkout.',
                  style: GoogleFonts.montserrat(fontSize: 12.5, color: OriginColors.inkMuted, height: 1.4),
                ),
                const SizedBox(height: 20),

                // Accepted Payment Methods Badges
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OriginColors.ivoryLight,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: OriginColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: OriginColors.goldDark, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Supported: UPI (Google Pay, PhonePe, Paytm), Visa, Mastercard, RuPay, Amex & Net Banking',
                              style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: OriginColors.ink),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.verified_user_outlined, color: OriginColors.goldDark, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Server-side HMAC-SHA256 signature verification & zero browser card credential storage.',
                              style: GoogleFonts.montserrat(fontSize: 11.5, color: OriginColors.inkMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (_isProcessing) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF8F1),
                      border: Border.all(color: OriginColors.goldDark.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: OriginColors.goldDark),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: GoogleFonts.montserrat(fontSize: 12.5, fontWeight: FontWeight.w600, color: OriginColors.royalBronze),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                Row(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: OriginColors.cardBorder),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                      onPressed: _isProcessing ? null : () => setState(() => _currentStep = 1),
                      child: Text('BACK', style: GoogleFonts.montserrat(color: OriginColors.inkLight)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OriginButton(
                        text: _isProcessing ? 'PROCESSING...' : 'AUTHORIZE SETTLEMENT VIA RAZORPAY',
                        isLoading: _isProcessing,
                        onPressed: _isProcessing ? null : _initiateRazorpayPayment,
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
        onTap: _isProcessing ? null : () => setState(() => _currentStep = step),
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

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    String? errorText,
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
            letterSpacing: 1.4,
            color: errorText != null ? const Color(0xFF9B1C1C) : OriginColors.inkLight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.montserrat(fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: OriginColors.ivoryLight,
            errorText: errorText,
            errorStyle: GoogleFonts.montserrat(fontSize: 11, color: const Color(0xFF9B1C1C)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: errorText != null ? const Color(0xFF9B1C1C) : OriginColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: errorText != null ? const Color(0xFF9B1C1C) : OriginColors.cardBorder),
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
      onTap: _isProcessing ? null : onSelect,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              InkWell(
                onTap: () => ref.read(currencyProvider.notifier).toggleCurrency(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: OriginColors.ivoryDark,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: OriginColors.goldDark, width: 0.8),
                  ),
                  child: Text(
                    currency == Currency.inr ? 'INR ₹ (Switch to USD)' : 'USD \$ (Switch to INR)',
                    style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600, color: OriginColors.royalBronze),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Items list with thumbnail, variant and price
          for (final item in cart.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Thumbnail
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: OriginColors.ivoryDark,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: OriginColors.cardBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildThumbnail(item.product),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(fontSize: 12.5, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.product.typeLabel} · Qty: ${item.quantity}',
                          style: GoogleFonts.montserrat(fontSize: 11, color: OriginColors.inkMuted),
                        ),
                      ],
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
              Text('Subtotal (Vault Archival)', style: GoogleFonts.montserrat(fontSize: 13)),
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
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cart.shippingCostUsd == 0 ? OriginColors.goldDark : OriginColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cultural Provenance License', style: GoogleFonts.montserrat(fontSize: 13, color: OriginColors.inkMuted)),
              Text(
                'Complimentary',
                style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: OriginColors.goldDark),
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

  Widget _buildThumbnail(Product product) {
    final img = product.primaryImage;
    if (img == null) {
      return const Icon(Icons.account_balance, size: 20, color: OriginColors.goldDark);
    }
    if (img.startsWith('assets/')) {
      return Image.asset(img, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 18));
    }
    return Image.network(img, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 18));
  }
}
