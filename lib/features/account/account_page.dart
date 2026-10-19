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
import '../../core/widgets/origin_toast.dart';
import '../../data/models/enquiry.dart';
import '../../data/models/order.dart';
import '../../data/repositories/currency_provider.dart';
import '../../data/repositories/enquiry_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../auth/auth_controller.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  int _activeTab = 0; // 0: Orders, 1: Enquiries & Viewings, 2: Profile

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final currency = ref.watch(currencyProvider);
    final orders = ref.watch(orderRepositoryProvider);
    final enquiries = ref.watch(enquiryRepositoryProvider);
    final isMobile = Breakpoints.isMobile(context);

    if (!auth.isSignedIn || user == null) {
      return Scaffold(
        appBar: const OriginHeader(isScrolled: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: OriginColors.goldDark),
              const SizedBox(height: 16),
              Text(
                'Royal Member Access Required',
                style: GoogleFonts.playfairDisplay(fontSize: 24),
              ),
              const SizedBox(height: 12),
              OriginButton(
                text: 'LOG IN OR REGISTER',
                onPressed: () => context.go('/'),
              ),
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
            // Account Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF7F0),
                border: Border(bottom: BorderSide(color: OriginColors.cardBorder)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: user.isAdmin ? OriginColors.royalBronze : OriginColors.goldDark,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  user.isAdmin ? 'IMPERIAL CURATOR' : 'ROYAL PATRON',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Member since ${OriginFormatters.formatDate(user.createdAt)}',
                                style: GoogleFonts.montserrat(fontSize: 11, color: OriginColors.inkMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: isMobile ? 26 : 34,
                              fontWeight: FontWeight.w500,
                              color: OriginColors.royalBronze,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: GoogleFonts.montserrat(fontSize: 13, color: OriginColors.inkLight),
                          ),
                        ],
                      ),

                      // Sign out button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: OriginColors.cardBorder),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        icon: const Icon(Icons.logout, size: 16, color: OriginColors.inkMuted),
                        label: Text(
                          'SIGN OUT',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                            color: OriginColors.inkLight,
                          ),
                        ),
                        onPressed: () {
                          ref.read(authControllerProvider.notifier).logout();
                          showOriginToast(context, 'Signed out from ORIGIN');
                          context.go('/');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tab bar
            Container(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  _buildTabButton(0, 'Orders & Acquisitions (${orders.length})', Icons.local_shipping_outlined),
                  const SizedBox(width: 8),
                  _buildTabButton(1, 'Enquiries & Private Viewings (${enquiries.length})', Icons.video_camera_front_outlined),
                  const SizedBox(width: 8),
                  _buildTabButton(2, 'Member Profile', Icons.person_outline),
                ],
              ),
            ),

            // Main Tab View
            Container(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _activeTab == 0
                  ? _buildOrdersTab(orders, currency)
                  : _activeTab == 1
                      ? _buildEnquiriesTab(enquiries)
                      : _buildProfileTab(user),
            ),

            const OriginFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int idx, String label, IconData icon) {
    final isSel = _activeTab == idx;
    return InkWell(
      onTap: () => setState(() => _activeTab = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSel ? OriginColors.goldDark : Colors.white,
          border: Border.all(color: isSel ? OriginColors.goldDark : OriginColors.cardBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSel ? Colors.white : OriginColors.goldDark),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                color: isSel ? Colors.white : OriginColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab(List<OrderModel> orders, Currency currency) {
    if (orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, size: 48, color: OriginColors.goldDark),
            const SizedBox(height: 12),
            Text('No Orders Placed Yet', style: GoogleFonts.playfairDisplay(fontSize: 20)),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final order in orders)
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: OriginColors.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ORDER ${order.id}',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: OriginColors.royalBronze,
                          ),
                        ),
                        Text(
                          'Placed on ${OriginFormatters.formatDate(order.createdAt)}',
                          style: GoogleFonts.montserrat(fontSize: 12, color: OriginColors.inkMuted),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: OriginColors.sageLight,
                        border: Border.all(color: OriginColors.sage),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        order.statusDisplay.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: OriginColors.royalBronze,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Live Tracking Timeline Bar
                _buildTrackingTimeline(order.status),
                const SizedBox(height: 24),

                // Item Details
                for (final item in order.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.product.name} (x${item.quantity})',
                          style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
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
                    Text(
                      'Courier: ${order.shippingMethod}',
                      style: GoogleFonts.montserrat(fontSize: 11.5, color: OriginColors.inkMuted),
                    ),
                    Text(
                      'Total: ${OriginFormatters.formatPrice(order.totalUsd, currency)}',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: OriginColors.royalBronze,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTrackingTimeline(OrderStatus currentStatus) {
    final stages = [
      {'status': OrderStatus.placed, 'label': 'Order Placed'},
      {'status': OrderStatus.packed, 'label': 'Vault Inspected'},
      {'status': OrderStatus.shipped, 'label': 'White-Glove Dispatched'},
      {'status': OrderStatus.delivered, 'label': 'Delivered'},
    ];

    final currentIndex = OrderStatus.values.indexOf(currentStatus);

    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Row(
          children: List.generate(stages.length, (idx) {
            final isDone = idx <= currentIndex;
            return Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 2,
                          color: idx == 0
                              ? Colors.transparent
                              : (idx <= currentIndex ? OriginColors.goldDark : OriginColors.cardBorder),
                        ),
                      ),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? OriginColors.goldDark : Colors.white,
                          border: Border.all(
                            color: isDone ? OriginColors.goldDark : OriginColors.cardBorder,
                            width: 2,
                          ),
                        ),
                        child: isDone
                            ? const Icon(Icons.check, size: 11, color: Colors.white)
                            : null,
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: idx == stages.length - 1
                              ? Colors.transparent
                              : (idx < currentIndex ? OriginColors.goldDark : OriginColors.cardBorder),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stages[idx]['label'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                      color: isDone ? OriginColors.ink : OriginColors.inkMuted,
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildEnquiriesTab(List<EnquiryModel> enquiries) {
    if (enquiries.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.question_answer_outlined, size: 48, color: OriginColors.goldDark),
            const SizedBox(height: 12),
            Text('No Enquiries Yet', style: GoogleFonts.playfairDisplay(fontSize: 20)),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final enq in enquiries)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enq.kindLabel.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: OriginColors.goldDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          enq.productName,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: OriginColors.ink,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: enq.status == EnquiryStatus.inDiscussion
                            ? OriginColors.lavenderLight
                            : OriginColors.ivoryDark,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: OriginColors.gold.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        enq.statusLabel,
                        style: GoogleFonts.montserrat(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: OriginColors.royalBronze,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text(
                  '“${enq.message}”',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: OriginColors.inkLight,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  'Method: ${enq.contactMethod} · Scheduled: ${enq.preferredDate} (${enq.preferredTime})',
                  style: GoogleFonts.montserrat(fontSize: 11.5, color: OriginColors.inkMuted),
                ),

                if (enq.adminReply != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: OriginColors.ivoryDark,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: OriginColors.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.support_agent, size: 20, color: OriginColors.goldDark),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'IMPERIAL CURATOR RESPONSE:',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: OriginColors.royalBronze,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                enq.adminReply!,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12.5,
                                  color: OriginColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProfileTab(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: OriginColors.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROYAL PATRON DOSSIER',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: OriginColors.goldDark,
            ),
          ),
          const SizedBox(height: 20),

          _buildProfileField('Full Legal Name', user.name),
          const Divider(height: 24),
          _buildProfileField('Registered Email', user.email),
          const Divider(height: 24),
          _buildProfileField('Contact Phone', user.phone.isNotEmpty ? user.phone : 'Not provided'),
          const Divider(height: 24),
          _buildProfileField('Primary Country', user.country),
          const Divider(height: 24),
          _buildProfileField('Member Tier', user.isAdmin ? 'Imperial Curator (Admin Privilege)' : 'Certified Royal Collector'),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: OriginColors.inkMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: OriginColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
