import 'package:kfon_subscriber/features/change_plan/domain/entity/payment_gateway_entity.dart';

class PaymentGatewayModel extends PaymentGatewayEntity {
  const PaymentGatewayModel({
    required super.id,
    required super.masterId,
    required super.code,
    required super.icon,
    required super.name,
    required super.isActive,
  });

  factory PaymentGatewayModel.fromJson(Map<String, dynamic> json) =>
      PaymentGatewayModel(
        id: json['id'] as String? ?? '',
        masterId: json['masterId'] as int? ?? 0,
        code: json['code'] as String? ?? '',
        icon: json['icon'] as String? ?? '',
        name: json['name'] as String? ?? '',
        isActive: json['isActive'] as bool? ?? true,
      );

  PaymentGatewayEntity toEntity() => PaymentGatewayEntity(
    id: id,
    masterId: masterId,
    code: code,
    name: name,
    icon: icon,
    isActive: isActive,
  );
}
