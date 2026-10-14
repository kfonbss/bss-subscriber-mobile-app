import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_state.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Result of a gateway payment screen: the [status] plus, for Razorpay's
/// SDK, the success response the backend needs to verify the payment.
class PaymentOutcome {
  final RechargeStatus status;

  /// razorpay_payment_id / razorpay_order_id / razorpay_signature on a
  /// Razorpay success; empty otherwise.
  final Map<String, String> razorpayResponse;

  const PaymentOutcome(this.status, {this.razorpayResponse = const {}});
}

/// Opens Razorpay's native checkout (razorpay_flutter) for a
/// `RAZORPAY_CHECKOUT` redirect from the recharge API.
///
/// Razorpay's web checkout does not work inside a WebView: net banking opens
/// the bank in a popup window, which a WebView can't show. The native SDK
/// handles net banking, cards, wallets and UPI apps.
///
/// Resolves with paymentSuccess (then report it and check the order status),
/// paymentFailed or paymentCancelled.
class RazorpayCheckout {
  RazorpayCheckout._();

  static const String redirectType = 'RAZORPAY_CHECKOUT';

  static bool supports(RechargeChangePlanRedirectEntity redirect) =>
      redirect.type == redirectType;

  static Future<PaymentOutcome> open(
    RechargeChangePlanRedirectEntity redirect,
  ) {
    final params = redirect.params;
    final keyId = params['razorpayKeyId'] ?? '';
    final orderId = params['razorpayOrderId'] ?? '';
    final amount = int.tryParse(params['amount'] ?? ''); // in paise
    if (keyId.isEmpty || orderId.isEmpty || amount == null) {
      debugPrint('❌ Razorpay checkout missing params: $params');
      return Future.value(const PaymentOutcome(RechargeStatus.paymentFailed));
    }

    final completer = Completer<PaymentOutcome>();
    final razorpay = Razorpay();

    void finish(PaymentOutcome outcome) {
      if (completer.isCompleted) return;
      completer.complete(outcome);
      razorpay.clear();
    }

    razorpay
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
        debugPrint(
          '💳 Razorpay success: ${response.paymentId} '
          'order=${response.orderId}',
        );
        finish(
          PaymentOutcome(
            RechargeStatus.paymentSuccess,
            razorpayResponse: {
              'razorpay_payment_id': response.paymentId ?? '',
              'razorpay_order_id': response.orderId ?? orderId,
              'razorpay_signature': response.signature ?? '',
            },
          ),
        );
      })
      ..on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
        debugPrint('💳 Razorpay error ${response.code}: ${response.message}');
        finish(PaymentOutcome(_errorStatus(response)));
      })
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
        // External wallets aren't configured for these orders.
        debugPrint('💳 Razorpay external wallet: ${response.walletName}');
        finish(const PaymentOutcome(RechargeStatus.paymentCancelled));
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

  /// After a failed attempt Razorpay keeps checkout open for a retry, so
  /// closing it then still arrives as PAYMENT_CANCELLED. The plugin puts
  /// only the error description in `message`; the error body (`reason`,
  /// `metadata.payment_id`) is in `response.error`. A real attempt has a
  /// payment_id (or a failure reason) — that's a failure, not a cancel.
  static RechargeStatus _errorStatus(PaymentFailureResponse response) {
    debugPrint('💳 Razorpay error body: ${response.error}');
    if (response.code != Razorpay.PAYMENT_CANCELLED) {
      return RechargeStatus.paymentFailed;
    }
    final error = response.error ?? const {};
    final metadata = error['metadata'];
    final paymentId =
        metadata is Map ? metadata['payment_id']?.toString() ?? '' : '';
    final reason = error['reason']?.toString().toLowerCase() ?? '';
    final description =
        '${error['description'] ?? response.message ?? ''}'.toLowerCase();
    final attempted =
        paymentId.isNotEmpty ||
        reason.contains('fail') ||
        (description.contains('fail') && !description.contains('cancelled'));
    return attempted
        ? RechargeStatus.paymentFailed
        : RechargeStatus.paymentCancelled;
  }
}
