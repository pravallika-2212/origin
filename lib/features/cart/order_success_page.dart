import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/animation/success_checkmark_painter.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/origin_button.dart';
import '../../core/widgets/origin_footer.dart';
import '../../core/widgets/origin_header.dart';
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

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderRepositoryProvider);
    final currency = ref.watch(currencyProvider);
    final order = orders.firstWhere(
      (o) => o.id == widget.orderId,
      orElse: () => orders.first,
    );

    return Scaffold(
      appBar: const OriginHeader(isScrolled: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 680),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: OriginColors.gold, width: 1.2),
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
                  // Self-drawing checkmark animation (900ms)
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
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'ACQUISITION CONFIRMED',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.8,
                      color: OriginColors.goldDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome to the Custody of Royalty',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: OriginColors.royalBronze,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Order Identifier: ${order.id}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: OriginColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tracking Protocol: ${order.trackingNumber}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: OriginColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Divider(color: OriginColors.cardBorder),
                  const SizedBox(height: 20),

                  // Order items list
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CUSTODY SUMMARY',
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
                      Text('Total Settlement', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w600)),
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
                  const SizedBox(height: 32),

                  Wrap(
                    spacing: 14,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
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
}
