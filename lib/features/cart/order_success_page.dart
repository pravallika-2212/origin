import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/animation/success_checkmark_painter.dart';
import '../../core/services/payment_api_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/origin_button.dart';
import '../../core/widgets/origin_footer.dart';
import '../../core/widgets/origin_header.dart';
import '../../data/models/order.dart';
import '../../data/repositories/currency_provider.dart';
import '../../data/repositories/order_repository.dart';

class OrderSuccessPage extends ConsumerStatefulWidget {
  const OrderSuccessPage({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends ConsumerState<OrderSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _refreshOrderStatus() async {
    setState(() => _isCheckingStatus = true);
    final apiService = PaymentApiService();
    final data = await apiService.getOrderStatus(widget.orderId);
    if (!mounted) return;

    if (data != null && data['paymentStatus'] == 'paid') {
      ref.read(orderRepositoryProvider.notifier).updatePaymentStatus(
            widget.orderId,
            OrderPaymentStatus.paid,
            paymentId: data['razorpayPaymentId'] as String?,
          );
    }

    setState(() => _isCheckingStatus = false);
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderRepositoryProvider);
    final currency = ref.watch(currencyProvider);
    final order = orders.firstWhere(
      (o) => o.id == widget.orderId,
      orElse: () => orders.first,
    );

    final isPaid = order.paymentStatus == OrderPaymentStatus.paid;

    return Scaffold(
      appBar: const OriginHeader(isScrolled: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 720),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isPaid ? OriginColors.gold : const Color(0xFFD97706),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x385A3C14),
                    blurRadius: 32,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Checkmark or Pending Indicator
                  if (isPaid)
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return SizedBox(
                          width: 80,
                          height: 80,
                          child: CustomPaint(
                            painter: SuccessCheckmarkPainter(
                              progress: _animController.value,
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD97706), width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.hourglass_top, color: Color(0xFFD97706), size: 36),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPaid ? OriginColors.ivoryDark : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: isPaid ? OriginColors.goldDark : const Color(0xFFD97706),
                      ),
                    ),
                    child: Text(
                      isPaid ? 'PAYMENT VERIFIED & CONFIRMED' : 'PAYMENT CONFIRMATION PENDING',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                        color: isPaid ? OriginColors.goldDark : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    isPaid ? 'Welcome to the Custody of Royalty' : 'Settlement Verification in Progress',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: OriginColors.royalBronze,
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (!isPaid)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Your payment is currently being confirmed by the banking network. Please avoid paying again while status is verified.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(fontSize: 12.5, color: OriginColors.inkMuted, height: 1.4),
                      ),
                    ),

                  // Reference Identifiers
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ORIGIN Order Identifier', style: GoogleFonts.montserrat(fontSize: 12, color: OriginColors.inkLight)),
                            Text(order.id, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: OriginColors.ink)),
                          ],
                        ),
                        if (order.razorpayPaymentId != null && order.razorpayPaymentId!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Razorpay Settlement ID', style: GoogleFonts.montserrat(fontSize: 12, color: OriginColors.inkLight)),
                              Text(order.razorpayPaymentId!, style: GoogleFonts.montserrat(fontSize: 12.5, fontWeight: FontWeight.w600, color: OriginColors.royalBronze)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Archival Protocol', style: GoogleFonts.montserrat(fontSize: 12, color: OriginColors.inkLight)),
                            Text(order.trackingNumber ?? 'ORIGIN-SECURE-VAULT', style: GoogleFonts.montserrat(fontSize: 12.5, fontWeight: FontWeight.w600, color: OriginColors.goldDark)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Delivery Estate Details
                  if (order.address.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'DELIVERY DESTINATION',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: OriginColors.inkMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: OriginColors.cardBorder),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (order.customerName != null && order.customerName!.isNotEmpty)
                            Text(order.customerName!, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('${order.address}, ${order.city}, ${order.country} ${order.postalCode}', style: GoogleFonts.montserrat(fontSize: 12, color: OriginColors.inkMuted)),
                          const SizedBox(height: 4),
                          Text('Method: ${order.shippingMethod}', style: GoogleFonts.montserrat(fontSize: 11.5, color: OriginColors.royalBronze)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Divider(color: OriginColors.cardBorder),
                  const SizedBox(height: 16),

                  // Order items list
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACQUISITION REPOSITORY BREAKDOWN',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: OriginColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final item in order.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.star_border, size: 16, color: OriginColors.goldDark),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${item.product.name} (Qty: ${item.quantity})',
                                  style: GoogleFonts.montserrat(fontSize: 13),
                                ),
                              ),
                              Text(
                                OriginFormatters.formatPrice(item.total, currency),
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: OriginColors.cardBorder),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Settlement Total',
                          style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        OriginFormatters.formatPrice(order.totalUsd, currency),
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: OriginColors.royalBronze,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Next Steps
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: OriginColors.ivoryDark.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: OriginColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CUSTODIAL NEXT STEPS', style: GoogleFonts.montserrat(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: OriginColors.royalBronze)),
                        const SizedBox(height: 10),
                        _buildStepItem('1', 'Vault Allocation: Archival conservation experts seal your acquisitions in custom climate-stable cases.'),
                        const SizedBox(height: 8),
                        _buildStepItem('2', 'Export Licensing: International heritage permits are stamped by the Geneva Antiquities Board.'),
                        const SizedBox(height: 8),
                        _buildStepItem('3', 'Armored Escort: Bonded diplomatic couriers coordinate discreet personal delivery to your estate.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Wrap(
                    spacing: 14,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      if (!isPaid)
                        OriginButton(
                          text: _isCheckingStatus ? 'VERIFYING...' : 'REFRESH SETTLEMENT STATUS',
                          isLoading: _isCheckingStatus,
                          onPressed: _refreshOrderStatus,
                        ),
                      OriginButton(
                        text: 'VIEW IN MY ORDERS',
                        onPressed: () => context.go('/account'),
                      ),
                      OriginButton(
                        text: 'CONTINUE SHOPPING',
                        variant: OriginButtonVariant.outlined,
                        onPressed: () => context.go('/shop'),
                      ),
                    ],
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

  Widget _buildStepItem(String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: OriginColors.goldDark,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(num, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: GoogleFonts.montserrat(fontSize: 12, color: OriginColors.ink, height: 1.3)),
        ),
      ],
    );
  }
}
