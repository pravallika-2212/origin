import 'razorpay_result.dart';
import 'razorpay_service_stub.dart'
    if (dart.library.js) 'razorpay_service_web.dart';

abstract class RazorpayService {
  factory RazorpayService() => getRazorpayService();

  Future<RazorpayPaymentResult> openCheckout({
    required String keyId,
    required String razorpayOrderId,
    required int amountInSubunits,
    required String currency,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String description,
  });
}
