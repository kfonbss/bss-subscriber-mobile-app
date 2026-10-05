import 'package:equatable/equatable.dart';

class RechargeChangePlanResponseEntity extends Equatable {
  final RechargeChangePlanRedirectEntity? redirect;
  final String gatewayType;
  final String orderId;

  /// True when the recharge completed immediately (e.g. paid from wallet)
  /// and no gateway redirect is needed.
  final bool activated;

  /// Server message, e.g. "Recharge successful. Subscriber activated."
  final String message;

  const RechargeChangePlanResponseEntity({
    this.redirect,
    required this.gatewayType,
    required this.orderId,
    this.activated = false,
    this.message = '',
  });

  @override
  List<Object?> get props => [
    redirect,
    gatewayType,
    orderId,
    activated,
    message,
  ];
}

class RechargeChangePlanRedirectEntity extends Equatable {
  final String type;
  final String? actionUrl;
  final String method;
  final Map<String, String> params;
  final String? orderId;

  const RechargeChangePlanRedirectEntity({
    required this.type,
    required this.actionUrl,
    required this.method,
    required this.params,
    this.orderId,
  });

  @override
  List<Object?> get props => [type, actionUrl, method, params,orderId];
}
