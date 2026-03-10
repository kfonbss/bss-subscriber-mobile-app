import 'package:equatable/equatable.dart';

class RechargeChangePlanResponseEntity extends Equatable {
  final RechargeChangePlanRedirectEntity? redirect;
  final String gatewayType;
  final String orderId;

  const RechargeChangePlanResponseEntity({
    this.redirect,
    required this.gatewayType,
    required this.orderId,
  });

  @override
  List<Object?> get props => [redirect, gatewayType, orderId];
}

class RechargeChangePlanRedirectEntity extends Equatable {
  final String type;
  final String actionUrl;
  final String method;
  final Map<String, dynamic> params;

  const RechargeChangePlanRedirectEntity({
    required this.type,
    required this.actionUrl,
    required this.method,
    required this.params,
  });

  @override
  List<Object?> get props => [type, actionUrl, method, params];
}
