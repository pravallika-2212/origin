import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../data/models/product.dart';
import '../../data/repositories/currency_provider.dart';
import '../../data/repositories/enquiry_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../auth/auth_controller.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  int _activeTab = 0; // 0: Dashboard, 1: Catalogue, 2: Orders, 3: Enquiries

  void _showAddProductDialog() {
    final nameCtrl = TextEditingController();
    final countryCtrl = TextEditingController(text: 'India');
    final eraCtrl = TextEditingController(text: 'Mughal (c. 1750)');
    final catCtrl = TextEditingController(text: 'Imperial Jewels');
    final priceCtrl = TextEditingController(text: '9500');
    final storyCtrl = TextEditingController(
      text: 'Exquisite ceremonial jewelry commissioned under the patronage of the imperial court.',
    );
    ProductType selectedType = ProductType.certifiedAntique;
    String artefactCode = 'neck';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 540),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: OriginColors.goldDark, width: 1.5),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add New Royal Piece',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: OriginColors.royalBronze,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildField('Piece Name', nameCtrl),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(child: _buildField('Country', countryCtrl)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField('Monarchical Era', eraCtrl)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(child: _buildField('Category', catCtrl)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField('Price (USD)', priceCtrl)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Product Type selector
                    Text(
                      'AUTHENTICITY CLASSIFICATION',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: OriginColors.inkLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ChoiceChip(
                          selected: selectedType == ProductType.certifiedAntique,
                          selectedColor: OriginColors.royalBronze,
                          label: Text(
                            'Certified Antique',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: selectedType == ProductType.certifiedAntique ? Colors.white : OriginColors.ink,
                            ),
                          ),
                          onSelected: (_) => setDialogState(() => selectedType = ProductType.certifiedAntique),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          selected: selectedType == ProductType.royalInspired,
                          selectedColor: OriginColors.sage,
                          label: Text(
                            'Royal-Inspired',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: selectedType == ProductType.royalInspired ? Colors.white : OriginColors.ink,
                            ),
                          ),
                          onSelected: (_) => setDialogState(() => selectedType = ProductType.royalInspired),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Artefact Visual Code
                    Text(
                      'ARTEFACT VECTOR ART',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: OriginColors.inkLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ['neck', 'crown', 'vase', 'robe', 'fan', 'box', 'chair', 'ear'].map((code) {
                        final isSel = artefactCode == code;
                        return ChoiceChip(
                          selected: isSel,
                          selectedColor: OriginColors.goldDark,
                          label: Text(
                            code.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSel ? Colors.white : OriginColors.ink,
                            ),
                          ),
                          onSelected: (_) => setDialogState(() => artefactCode = code),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    _buildField('Historical Story & Lore', storyCtrl, maxLines: 3),
                    const SizedBox(height: 20),

                    OriginButton(
                      text: 'PUBLISH TO REPOSITORY',
                      onPressed: () {
                        if (nameCtrl.text.isEmpty) {
                          showOriginToast(context, 'Please enter a name for the piece.');
                          return;
                        }

                        final newProd = Product(
                          id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          country: countryCtrl.text.trim(),
                          civilization: countryCtrl.text.trim(),
                          era: eraCtrl.text.trim(),
                          category: catCtrl.text.trim(),
                          story: storyCtrl.text.trim(),
                          priceUsd: double.tryParse(priceCtrl.text) ?? 5000,
                          type: selectedType,
                          images: [artefactCode],
                          artefactCode: artefactCode,
                          published: true,
                        );

                        ref.read(productRepositoryProvider.notifier).addProduct(newProd);
                        Navigator.pop(ctx);
                        showOriginToast(context, '${newProd.name} published to catalogue');
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showReplyEnquiryDialog(EnquiryModel enq) {
    final replyCtrl = TextEditingController(text: enq.adminReply ?? 'We look forward to hosting your private consultation.');
    EnquiryStatus status = enq.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: OriginColors.goldDark, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Curator Reply & Status',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: OriginColors.royalBronze,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enquiry regarding ${enq.productName} by ${enq.userName}',
                    style: GoogleFonts.montserrat(fontSize: 12, color: OriginColors.inkMuted),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<EnquiryStatus>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: EnquiryStatus.newRequest, child: Text('New Request')),
                      DropdownMenuItem(value: EnquiryStatus.inDiscussion, child: Text('In Discussion / Confirmed')),
                      DropdownMenuItem(value: EnquiryStatus.closed, child: Text('Closed / Completed')),
                    ],
                    onChanged: (s) {
                      if (s != null) setDialogState(() => status = s);
                    },
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: replyCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Curator Official Response',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  OriginButton(
                    text: 'SAVE AND SEND UPDATE',
                    onPressed: () {
                      ref.read(enquiryRepositoryProvider.notifier).updateStatus(
                            enq.id,
                            status,
                            adminReply: replyCtrl.text.trim(),
                          );
                      Navigator.pop(ctx);
                      showOriginToast(context, 'Enquiry updated for ${enq.userName}');
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isMobile = Breakpoints.isMobile(context);

    // Safeguard: Check if admin
    if (!auth.isAdmin) {
      return Scaffold(
        appBar: const OriginHeader(isScrolled: true),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: OriginColors.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings_outlined, size: 54, color: OriginColors.goldDark),
                const SizedBox(height: 16),
                Text(
                  'Imperial Curator Access Only',
                  style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'The Admin Panel requires imperial curator credentials. Switch to the Admin Demo below for testing.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(fontSize: 13, color: OriginColors.inkMuted),
                ),
                const SizedBox(height: 24),
                OriginButton(
                  text: 'SWITCH TO ADMIN DEMO',
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).switchToAdminDemo();
                    showOriginToast(context, 'Admin access granted');
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final products = ref.watch(productRepositoryProvider);
    final orders = ref.watch(orderRepositoryProvider);
    final enquiries = ref.watch(enquiryRepositoryProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: const OriginHeader(isScrolled: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Admin Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
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
                                  color: OriginColors.royalBronze,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  'PROTECTED CURATOR CONSOLE',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Imperial Vault Administration',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: isMobile ? 26 : 34,
                              fontWeight: FontWeight.w500,
                              color: OriginColors.royalBronze,
                            ),
                          ),
                        ],
                      ),
                      OriginButton(
                        text: 'ADD ROYAL PIECE',
                        icon: const Icon(Icons.add, size: 16, color: Colors.white),
                        onPressed: _showAddProductDialog,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tab Buttons Row
            Container(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab(0, 'Dashboard Overview', Icons.dashboard_outlined),
                    const SizedBox(width: 8),
                    _buildTab(1, 'Catalogue (${products.length})', Icons.inventory_2_outlined),
                    const SizedBox(width: 8),
                    _buildTab(2, 'Orders (${orders.length})', Icons.local_shipping_outlined),
                    const SizedBox(width: 8),
                    _buildTab(3, 'Enquiries (${enquiries.length})', Icons.video_camera_front_outlined),
                  ],
                ),
              ),
            ),

            // Main Console Tab View
            Container(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _activeTab == 0
                  ? _buildDashboardView(products, orders, enquiries, currency)
                  : _activeTab == 1
                      ? _buildCatalogueView(products, currency)
                      : _activeTab == 2
                          ? _buildOrdersView(orders, currency)
                          : _buildEnquiriesView(enquiries),
            ),

            const OriginFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int idx, String label, IconData icon) {
    final isSel = _activeTab == idx;
    return InkWell(
      onTap: () => setState(() => _activeTab = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSel ? OriginColors.royalBronze : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSel ? OriginColors.royalBronze : OriginColors.cardBorder),
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

  Widget _buildDashboardView(
    List<Product> products,
    List<OrderModel> orders,
    List<EnquiryModel> enquiries,
    Currency currency,
  ) {
    final totalInventoryValue = products.fold(0.0, (sum, p) => sum + p.priceUsd);
    final totalOrderVolume = orders.fold(0.0, (sum, o) => sum + o.totalUsd);

    return Column(
      children: [
        // Metric cards
        LayoutBuilder(
          builder: (ctx, constraints) {
            int cols = 4;
            if (constraints.maxWidth < 600) {
              cols = 1;
            } else if (constraints.maxWidth < 950) {
              cols = 2;
            }

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: [
                _buildMetricCard(
                  'CATALOGUE VALUE',
                  OriginFormatters.formatPrice(totalInventoryValue, currency),
                  '${products.length} registered pieces',
                  Icons.account_balance_outlined,
                ),
                _buildMetricCard(
                  'ORDER VOLUME',
                  OriginFormatters.formatPrice(totalOrderVolume, currency),
                  '${orders.length} orders processed',
                  Icons.payments_outlined,
                ),
                _buildMetricCard(
                  'OPEN ENQUIRIES',
                  '${enquiries.where((e) => e.status != EnquiryStatus.closed).length}',
                  'Private viewings & offers',
                  Icons.contact_mail_outlined,
                ),
                _buildMetricCard(
                  'CERTIFIED ANTIQUES',
                  '${products.where((p) => p.type == ProductType.certifiedAntique).length}',
                  'Museum grade with provenance',
                  Icons.verified_outlined,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 36),

        // Quick Overview Table
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
                'Recent Orders & Vault Dispatches',
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              for (final o in orders)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(o.id, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                      Text(o.statusDisplay, style: GoogleFonts.montserrat(color: OriginColors.goldDark)),
                      Text(OriginFormatters.formatPrice(o.totalUsd, currency), style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: OriginColors.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: OriginColors.inkMuted,
                ),
              ),
              Icon(icon, size: 20, color: OriginColors.goldDark),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: OriginColors.royalBronze,
            ),
          ),
          const SizedBox(height: 4),
          Text(sub, style: GoogleFonts.montserrat(fontSize: 11, color: OriginColors.inkMuted)),
        ],
      ),
    );
  }

  Widget _buildCatalogueView(List<Product> products, Currency currency) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: OriginColors.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        separatorBuilder: (ctx, idx) => const Divider(height: 1),
        itemBuilder: (ctx, idx) {
          final p = products[idx];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(
              p.name,
              style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${p.typeLabel} · ${p.country} · ${OriginFormatters.formatPrice(p.priceUsd, currency)}',
              style: GoogleFonts.montserrat(fontSize: 12, color: OriginColors.inkMuted),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Publish switch
                Switch(
                  value: p.published,
                  activeThumbColor: OriginColors.goldDark,
                  onChanged: (_) {
                    ref.read(productRepositoryProvider.notifier).togglePublish(p.id);
                    showOriginToast(
                      context,
                      p.published ? 'Piece hidden from public shop' : 'Piece published to shop',
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                  onPressed: () {
                    ref.read(productRepositoryProvider.notifier).deleteProduct(p.id);
                    showOriginToast(context, '${p.name} removed from catalogue');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersView(List<OrderModel> orders, Currency currency) {
    return Column(
      children: [
        for (final o in orders)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: OriginColors.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ORDER ${o.id}', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                    Text(
                      '${o.items.length} items · ${o.city}, ${o.country} · ${OriginFormatters.formatPrice(o.totalUsd, currency)}',
                      style: GoogleFonts.montserrat(fontSize: 12, color: OriginColors.inkMuted),
                    ),
                  ],
                ),
                DropdownButton<OrderStatus>(
                  value: o.status,
                  items: const [
                    DropdownMenuItem(value: OrderStatus.placed, child: Text('Order Placed')),
                    DropdownMenuItem(value: OrderStatus.packed, child: Text('Vault Packed')),
                    DropdownMenuItem(value: OrderStatus.shipped, child: Text('Courier Dispatched')),
                    DropdownMenuItem(value: OrderStatus.delivered, child: Text('Delivered')),
                  ],
                  onChanged: (status) {
                    if (status != null) {
                      ref.read(orderRepositoryProvider.notifier).updateStatus(o.id, status);
                      showOriginToast(context, 'Order ${o.id} status updated to $status');
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEnquiriesView(List<EnquiryModel> enquiries) {
    return Column(
      children: [
        for (final e in enquiries)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: OriginColors.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${e.kindLabel}: ${e.productName}',
                        style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'From: ${e.userName} (${e.userEmail}) · ${e.preferredDate} (${e.contactMethod})',
                        style: GoogleFonts.montserrat(fontSize: 12, color: OriginColors.inkMuted),
                      ),
                      if (e.offerAmountUsd != null)
                        Text(
                          'Purchase Offer: \$${e.offerAmountUsd!.toStringAsFixed(0)} USD',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: OriginColors.royalBronze,
                          ),
                        ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('REPLY / STATUS'),
                  onPressed: () => _showReplyEnquiryDialog(e),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: OriginColors.inkLight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: GoogleFonts.montserrat(fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: OriginColors.cardBorder),
            ),
          ),
        ),
      ],
    );
  }
}
