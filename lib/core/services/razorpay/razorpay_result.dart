enum RazorpayResultStatus {
  success,
  failure,
  dismissed,
}

class RazorpayPaymentResult {
  const RazorpayPaymentResult({
    required this.status,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.razorpaySignature,
    this.errorCode,
    this.errorMessage,
  });

  final RazorpayResultStatus status;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? razorpaySignature;
  final String? errorCode;
  final String? errorMessage;

  bool get isSuccess => status == RazorpayResultStatus.success;
  bool get isFailure => status == RazorpayResultStatus.failure;
  bool get isDismissed => status == RazorpayResultStatus.dismissed;

  factory RazorpayPaymentResult.success({
    required String paymentId,
    required String orderId,
    required String signature,
  }) {
    return RazorpayPaymentResult(
      status: RazorpayResultStatus.success,
      razorpayPaymentId: paymentId,
      razorpayOrderId: orderId,
      razorpaySignature: signature,
    );
  }

  factory RazorpayPaymentResult.failure({
    String? code,
    String? message,
  }) {
    return RazorpayPaymentResult(
      status: RazorpayResultStatus.failure,
      errorCode: code ?? 'PAYMENT_FAILED',
      errorMessage: message ?? 'Payment was not authorized.',
    );
  }

  factory RazorpayPaymentResult.dismissed() {
    return const RazorpayPaymentResult(
      status: RazorpayResultStatus.dismissed,
      errorMessage: 'Checkout window was closed by the customer.',
    );
  }
}
