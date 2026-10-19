import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:origin/core/fonts.dart';
import '../../app/theme.dart';
import '../../core/widgets/origin_button.dart';
import '../../core/widgets/origin_toast.dart';
import '../../data/models/enquiry.dart';
import '../../data/models/product.dart';
import '../../data/repositories/enquiry_repository.dart';
import '../auth/auth_controller.dart';

void showEnquiryDialog(
  BuildContext context, {
  required Product product,
  EnquiryKind initialKind = EnquiryKind.privateViewing,
}) {
  showDialog(
    context: context,
    builder: (ctx) => EnquiryDialog(product: product, initialKind: initialKind),
  );
}

class EnquiryDialog extends ConsumerStatefulWidget {
  const EnquiryDialog({
    super.key,
    required this.product,
    this.initialKind = EnquiryKind.privateViewing,
  });

  final Product product;
  final EnquiryKind initialKind;

  @override
  ConsumerState<EnquiryDialog> createState() => _EnquiryDialogState();
}

class _EnquiryDialogState extends ConsumerState<EnquiryDialog> {
  late EnquiryKind _kind;
  String _contactMethod = 'Private Video Consultation';
  final _dateCtrl = TextEditingController(text: '2026-10-28');
  final _timeCtrl = TextEditingController(text: '14:00 CET');
  final _messageCtrl = TextEditingController();
  final _offerAmountCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _kind = widget.initialKind;
    _messageCtrl.text = _kind == EnquiryKind.privateViewing
        ? 'I would like to request an exclusive private viewing and provenance document examination for ${widget.product.name}.'
        : 'I am interested in acquiring ${widget.product.name} and would like additional details regarding shipping and care.';
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _messageCtrl.dispose();
    _offerAmountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = ref.read(authControllerProvider);
    final user = auth.user;
    if (user == null) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));

    double? offerVal;
    if (_kind == EnquiryKind.makeOffer && _offerAmountCtrl.text.isNotEmpty) {
      offerVal = double.tryParse(_offerAmountCtrl.text.replaceAll(',', ''));
    }

    ref.read(enquiryRepositoryProvider.notifier).submitEnquiry(
      userId: user.uid,
      userName: user.name,
      userEmail: user.email,
      productId: widget.product.id,
      productName: widget.product.name,
      kind: _kind,
      contactMethod: _contactMethod,
      preferredDate: _dateCtrl.text.trim(),
      preferredTime: _timeCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
      offerAmountUsd: offerVal,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pop();

    showOriginToast(
      context,
      'Your request has been submitted to the Imperial Concierge. We will contact you within 24 hours.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 540),
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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IMPERIAL CONCIERGE',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.2,
                            color: OriginColors.goldDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Private Viewing & Enquiries',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: OriginColors.royalBronze,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Selected Piece Summary Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: OriginColors.cardBorder),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: OriginColors.ivoryDark,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.stars, color: OriginColors.goldDark, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${widget.product.typeLabel} · ${widget.product.country} (${widget.product.era})',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: OriginColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Request Type Selector (Viewing, General Enquiry, Make Offer)
                Text(
                  'REQUEST TYPE',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: OriginColors.inkLight,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildKindChip(
                      EnquiryKind.privateViewing,
                      'Private Viewing',
                      Icons.video_camera_front_outlined,
                    ),
                    _buildKindChip(
                      EnquiryKind.enquiry,
                      'General Enquiry',
                      Icons.mail_outline,
                    ),
                    if (widget.product.type == ProductType.certifiedAntique)
                      _buildKindChip(
                        EnquiryKind.makeOffer,
                        'Make an Offer',
                        Icons.gavel_outlined,
                      ),
                  ],
                ),
                const SizedBox(height: 18),

                // Contact Method
                Text(
                  'PREFERRED CONSULTATION METHOD',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: OriginColors.inkLight,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _contactMethod,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: OriginColors.cardBorder),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Private Video Consultation',
                      child: Text('Private Video Consultation (Curator 1-on-1)'),
                    ),
                    DropdownMenuItem(
                      value: 'In-Vault London Viewing',
                      child: Text('In-Vault London Viewing (By Appointment)'),
                    ),
                    DropdownMenuItem(
                      value: 'Confidential Phone Call',
                      child: Text('Confidential Phone Call'),
                    ),
                    DropdownMenuItem(
                      value: 'Direct Email Communication',
                      child: Text('Direct Email Communication'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _contactMethod = val);
                  },
                ),
                const SizedBox(height: 16),

                // Date & Time row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PREFERRED DATE',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: OriginColors.inkLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _dateCtrl,
                            style: GoogleFonts.montserrat(fontSize: 13),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.calendar_today, size: 16, color: OriginColors.goldDark),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(color: OriginColors.cardBorder),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PREFERRED TIME',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: OriginColors.inkLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _timeCtrl,
                            style: GoogleFonts.montserrat(fontSize: 13),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.access_time, size: 16, color: OriginColors.goldDark),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(color: OriginColors.cardBorder),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Offer amount if make offer
                if (_kind == EnquiryKind.makeOffer) ...[
                  const SizedBox(height: 16),
                  Text(
                    'OFFER AMOUNT (USD)',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: OriginColors.inkLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _offerAmountCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.attach_money, size: 18, color: OriginColors.goldDark),
                      hintText: 'e.g. 17,500',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: OriginColors.cardBorder),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Message Notes
                Text(
                  'NOTES & SPECIFIC INTERESTS',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: OriginColors.inkLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _messageCtrl,
                  maxLines: 3,
                  style: GoogleFonts.montserrat(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Share any provenance questions or viewing requirements...',
                    contentPadding: const EdgeInsets.all(12),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: OriginColors.cardBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                OriginButton(
                  text: 'SUBMIT REQUEST TO CURATOR',
                  isFullWidth: true,
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKindChip(EnquiryKind kind, String label, IconData icon) {
    final isSelected = _kind == kind;
    return ChoiceChip(
      selected: isSelected,
      selectedColor: OriginColors.goldDark,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? OriginColors.goldDark : OriginColors.cardBorder,
      ),
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : OriginColors.goldDark,
      ),
      label: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.white : OriginColors.ink,
        ),
      ),
      onSelected: (val) {
        if (val) setState(() => _kind = kind);
      },
    );
  }
}
