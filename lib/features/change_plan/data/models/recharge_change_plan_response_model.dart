import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';

class RechargeChangePlanResponseModel {
  final RechargeChangePlanRedirectModel? redirect;
  final String gatewayType;
  final String orderId;
  final bool activated;
  final String message;

  const RechargeChangePlanResponseModel({
    this.redirect,
    required this.gatewayType,
    required this.orderId,
    this.activated = false,
    this.message = '',
  });

  factory RechargeChangePlanResponseModel.fromJson(
    Map<String, dynamic> json, {
    String message = '',
  }) {
    return RechargeChangePlanResponseModel(
      activated: json['activated'] == true,
      message: message,
      redirect:
          json['redirect'] != null
              ? RechargeChangePlanRedirectModel.fromJson(
                json['redirect'] as Map<String, dynamic>,
              )
              : null,
      gatewayType: json['gatewayType']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
    );
  }

  RechargeChangePlanResponseEntity toEntity() {
    return RechargeChangePlanResponseEntity(
      redirect: redirect?.toEntity(),
      gatewayType: gatewayType,
      orderId: orderId,
      activated: activated,
      message: message,
    );
  }
}

class RechargeChangePlanRedirectModel {
  final String type;
  // Nullable on purpose: for some redirect types (e.g. PAYTM_CHECKOUT) the
  // backend legitimately sends no actionUrl, because the client is expected
  // to construct Paytm's hosted-checkout URL itself from `mid` + `orderId`.
  // Coercing this to '' made a genuinely-missing URL indistinguishable from
  // a backend bug, and caused PaymentWebViewPage to POST a form to action=""
  // (submitting back to the blank WebView) instead of surfacing an error.
  final String? actionUrl;
  final String method;
  final Map<String, String> params;
  final String? orderId;

  const RechargeChangePlanRedirectModel({
    required this.type,
    required this.actionUrl,
    required this.method,
    required this.params,
    this.orderId,
  });

  factory RechargeChangePlanRedirectModel.fromJson(Map<String, dynamic> json) {
    // Handle both response structures:
    // 1. { "data": { "redirect": { ... }, "orderId": "..." } }
    // 2. { "redirect": { ... }, "orderId": "..." }
    // 3. Direct redirect object: { "type": "...", "actionUrl": "...", ... }

    Map<String, dynamic> redirect;
    String? orderId;

    if (json.containsKey('data') && json['data'] is Map) {
      final data = json['data'] as Map<String, dynamic>;
      redirect = data['redirect'] as Map<String, dynamic>? ?? {};
      orderId = data['orderId']?.toString();
    } else if (json.containsKey('redirect') && json['redirect'] is Map) {
      redirect = json['redirect'] as Map<String, dynamic>;
      orderId = json['orderId']?.toString();
    } else if (json.containsKey('type') && json.containsKey('actionUrl')) {
      // Direct redirect object
      redirect = json;
      orderId = json['orderId']?.toString();
    } else {
      redirect = {};
      orderId = json['orderId']?.toString();
    }

    final paramsMap = redirect['params'] as Map<String, dynamic>? ?? {};
    final rawActionUrl = redirect['actionUrl'];

    return RechargeChangePlanRedirectModel(
      type: redirect['type']?.toString() ?? '',
      // Preserve null instead of collapsing it to '' — see field doc comment.
      actionUrl: rawActionUrl == null ? null : rawActionUrl.toString(),
      method: redirect['method']?.toString() ?? '',
      params: paramsMap.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
      orderId: orderId,
    );
  }

  RechargeChangePlanRedirectEntity toEntity() {
    return RechargeChangePlanRedirectEntity(
      type: type,
      actionUrl: actionUrl,
      method: method,
      params: params,
      orderId: orderId,
    );
  }
}
