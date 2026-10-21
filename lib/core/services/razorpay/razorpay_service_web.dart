import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'razorpay_result.dart';
import 'razorpay_service.dart';

@JS('window.OriginRazorpayBridge.openCheckout')
external void _openCheckoutJs(
  JSString optionsJson,
  JSFunction onSuccess,
  JSFunction onFailure,
  JSFunction onDismiss,
);

class WebRazorpayService implements RazorpayService {
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
  }) {
    final completer = Completer<RazorpayPaymentResult>();

    final optionsMap = {
      'key': keyId,
      'amount': amountInSubunits,
      'currency': currency,
      'name': 'ORIGIN — Royal Heritage',
      'description': description,
      'order_id': razorpayOrderId,
      'prefill': {
        'name': customerName,
        'email': customerEmail,
        'contact': customerPhone,
      },
      'theme': {
        'color': '#B38E46',
      },
    };

    final optionsJson = jsonEncode(optionsMap).toJS;

    final onSuccessJs = ((JSString responseJsonStr) {
      if (completer.isCompleted) return;
      try {
        final data = jsonDecode(responseJsonStr.toDart) as Map<String, dynamic>;
        completer.complete(
          RazorpayPaymentResult.success(
            paymentId: (data['razorpay_payment_id'] ?? '') as String,
            orderId: (data['razorpay_order_id'] ?? '') as String,
            signature: (data['razorpay_signature'] ?? '') as String,
          ),
        );
      } catch (e) {
        completer.complete(
          RazorpayPaymentResult.failure(
            message: 'Failed to parse payment confirmation: $e',
          ),
        );
      }
    }).toJS;

    final onFailureJs = ((JSString errorJsonStr) {
      if (completer.isCompleted) return;
      try {
        final data = jsonDecode(errorJsonStr.toDart) as Map<String, dynamic>;
        completer.complete(
          RazorpayPaymentResult.failure(
            code: data['code'] as String?,
            message: data['description'] as String?,
          ),
        );
      } catch (_) {
        completer.complete(
          RazorpayPaymentResult.failure(
            message: errorJsonStr.toDart,
          ),
        );
      }
    }).toJS;

    final onDismissJs = (() {
      if (!completer.isCompleted) {
        completer.complete(RazorpayPaymentResult.dismissed());
      }
    }).toJS;

    try {
      _openCheckoutJs(optionsJson, onSuccessJs, onFailureJs, onDismissJs);
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(
          RazorpayPaymentResult.failure(
            message: 'Error invoking Razorpay Checkout window: $e',
          ),
        );
      }
    }

    return completer.future;
  }
}

RazorpayService getRazorpayService() => WebRazorpayService();
