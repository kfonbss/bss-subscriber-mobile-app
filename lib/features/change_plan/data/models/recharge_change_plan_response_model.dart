import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';

class RechargeChangePlanResponseModel {
  final RechargeChangePlanRedirectModel? redirect;
  final String gatewayType;
  final String orderId;

  const RechargeChangePlanResponseModel({
    this.redirect,
    required this.gatewayType,
    required this.orderId,
  });

  factory RechargeChangePlanResponseModel.fromJson(Map<String, dynamic> json) {
    return RechargeChangePlanResponseModel(
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
    );
  }
}

class RechargeChangePlanRedirectModel {
  final String type;
  final String actionUrl;
  final String method;
  final Map<String, dynamic> params;

  const RechargeChangePlanRedirectModel({
    required this.type,
    required this.actionUrl,
    required this.method,
    required this.params,
  });

  factory RechargeChangePlanRedirectModel.fromJson(Map<String, dynamic> json) {
    return RechargeChangePlanRedirectModel(
      type: json['type']?.toString() ?? '',
      actionUrl: json['actionUrl']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      params:
          json['params'] != null
              ? Map<String, dynamic>.from(json['params'] as Map)
              : {},
    );
  }

  RechargeChangePlanRedirectEntity toEntity() {
    return RechargeChangePlanRedirectEntity(
      type: type,
      actionUrl: actionUrl,
      method: method,
      params: params,
    );
  }
}
