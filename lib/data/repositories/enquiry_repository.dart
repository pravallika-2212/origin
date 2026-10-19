import '../../core/riverpod.dart';
import '../models/enquiry.dart';
import 'seed_data.dart';

class EnquiryRepository extends StateNotifier<List<EnquiryModel>> {
  EnquiryRepository()
      : super([
          EnquiryModel(
            id: 'ENQ-1042',
            userId: 'member_demo_001',
            userName: 'Princess Sophia of Bavaria',
            userEmail: 'sophia.bavaria@royalhouse.org',
            productId: seedProducts[0].id,
            productName: seedProducts[0].name,
            kind: EnquiryKind.privateViewing,
            contactMethod: 'Private Video Consultation',
            preferredDate: '2026-10-25',
            preferredTime: '15:00 CET',
            message: 'Requesting a private high-resolution inspection of the Patiala Kundan necklace enameling.',
            status: EnquiryStatus.inDiscussion,
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            adminReply: 'Our Senior Curator has prepared the laboratory microscope stream for your scheduled appointment.',
          ),
        ]);

  EnquiryModel submitEnquiry({
    required String userId,
    required String userName,
    required String userEmail,
    required String productId,
    required String productName,
    required EnquiryKind kind,
    required String contactMethod,
    required String preferredDate,
    required String preferredTime,
    required String message,
    double? offerAmountUsd,
  }) {
    final enquiry = EnquiryModel(
      id: 'ENQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      productId: productId,
      productName: productName,
      kind: kind,
      contactMethod: contactMethod,
      preferredDate: preferredDate,
      preferredTime: preferredTime,
      message: message,
      offerAmountUsd: offerAmountUsd,
      status: EnquiryStatus.newRequest,
      createdAt: DateTime.now(),
    );

    state = [enquiry, ...state];
    return enquiry;
  }

  void updateStatus(String id, EnquiryStatus status, {String? adminReply}) {
    state = [
      for (final e in state)
        if (e.id == id) e.copyWith(status: status, adminReply: adminReply) else e,
    ];
  }

  List<EnquiryModel> getEnquiriesForUser(String userId) {
    return state.where((e) => e.userId == userId).toList();
  }
}

final enquiryRepositoryProvider =
    StateNotifierProvider<EnquiryRepository, List<EnquiryModel>>((ref) {
  return EnquiryRepository();
});
