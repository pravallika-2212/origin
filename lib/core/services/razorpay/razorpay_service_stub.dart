import 'dart:async';
import 'razorpay_result.dart';
import 'razorpay_service.dart';

class StubRazorpayService implements RazorpayService {
  @override
  Future<RazorpayPaymentResult> openCheckout({
    required String keyId,
    required String razorpayOrderId,
    required int amountInSubunits,
    required String currency,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String description,
  }) async {
    // In local VM unit testing, simulate settlement authorization
    await Future.delayed(const Duration(milliseconds: 100));
    return RazorpayPaymentResult.success(
      paymentId: 'pay_simulated_${DateTime.now().millisecondsSinceEpoch}',
      orderId: razorpayOrderId,
      signature: 'simulated_valid_signature_test',
    );
  }
}

RazorpayService getRazorpayService() => StubRazorpayService();
