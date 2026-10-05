import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_state.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Opens Razorpay's native checkout (razorpay_flutter) for a
/// `RAZORPAY_CHECKOUT` redirect from the recharge API.
///
/// Razorpay's web checkout does not work inside a WebView: net banking opens
/// the bank in a popup window, which a WebView can't show. The native SDK
/// handles net banking, cards, wallets and UPI apps.
///
/// Resolves with the same results as `PaymentWebViewPage`, so callers handle
/// both the same way: paymentSuccess (then check the order status),
/// paymentFailed or paymentCancelled.
class RazorpayCheckout {
  RazorpayCheckout._();

  static const String redirectType = 'RAZORPAY_CHECKOUT';

  static bool supports(RechargeChangePlanRedirectEntity redirect) =>
      redirect.type == redirectType;

  static Future<RechargeStatus> open(
    RechargeChangePlanRedirectEntity redirect,
  ) {
    final params = redirect.params;
    final keyId = params['razorpayKeyId'] ?? '';
    final orderId = params['razorpayOrderId'] ?? '';
    final amount = int.tryParse(params['amount'] ?? ''); // in paise
    if (keyId.isEmpty || orderId.isEmpty || amount == null) {
      debugPrint('❌ Razorpay checkout missing params: $params');
      return Future.value(RechargeStatus.paymentFailed);
    }

    final completer = Completer<RechargeStatus>();
    final razorpay = Razorpay();

    void finish(RechargeStatus status) {
      if (completer.isCompleted) return;
      completer.complete(status);
      razorpay.clear();
    }

    razorpay
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
        debugPrint('💳 Razorpay success: ${response.paymentId}');
        finish(RechargeStatus.paymentSuccess);
      })
      ..on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
        debugPrint(
          '💳 Razorpay error ${response.code}: ${response.message}',
        );
        finish(
          response.code == Razorpay.PAYMENT_CANCELLED
              ? RechargeStatus.paymentCancelled
              : RechargeStatus.paymentFailed,
        );
      })
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
        // External wallets aren't configured for these orders.
        debugPrint('💳 Razorpay external wallet: ${response.walletName}');
        finish(RechargeStatus.paymentCancelled);
      });

    final primary = AppColor.kPrimaryColor.toARGB32() & 0xFFFFFF;
    razorpay.open({
      'key': keyId,
      'order_id': orderId,
      'amount': amount,
      'currency': params['currency'] ?? 'INR',
      'theme': {'color': '#${primary.toRadixString(16).padLeft(6, '0')}'},
    });

    return completer.future;
  }
}
