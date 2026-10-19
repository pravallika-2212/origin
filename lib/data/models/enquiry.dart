enum EnquiryKind { enquiry, privateViewing, makeOffer }

enum EnquiryStatus { newRequest, inDiscussion, closed }

class EnquiryModel {
  const EnquiryModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.productId,
    required this.productName,
    required this.kind,
    required this.contactMethod,
    required this.preferredDate,
    required this.preferredTime,
    required this.message,
    this.offerAmountUsd,
    required this.status,
    required this.createdAt,
    this.adminReply,
  });

  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String productId;
  final String productName;
  final EnquiryKind kind;
  final String contactMethod;
  final String preferredDate;
  final String preferredTime;
  final String message;
  final double? offerAmountUsd;
  final EnquiryStatus status;
  final DateTime createdAt;
  final String? adminReply;

  String get kindLabel {
    switch (kind) {
      case EnquiryKind.enquiry:
        return 'General Enquiry';
      case EnquiryKind.privateViewing:
        return 'Private Viewing Request';
      case EnquiryKind.makeOffer:
        return 'Purchase Offer';
    }
  }

  String get statusLabel {
    switch (status) {
      case EnquiryStatus.newRequest:
        return 'New Request';
      case EnquiryStatus.inDiscussion:
        return 'In Discussion';
      case EnquiryStatus.closed:
        return 'Concluded';
    }
  }

  EnquiryModel copyWith({
    EnquiryStatus? status,
    String? adminReply,
  }) {
    return EnquiryModel(
      id: id,
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
      status: status ?? this.status,
      createdAt: createdAt,
      adminReply: adminReply ?? this.adminReply,
    );
  }
}
