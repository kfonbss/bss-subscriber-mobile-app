import 'package:equatable/equatable.dart';

class PaymentGatewayEntity extends Equatable {
  final String id;
  final int masterId;
  final String code;
  final String name;
  final String icon;
  final bool isActive;

  const PaymentGatewayEntity({
    required this.id,
    required this.masterId,
    required this.code,
    required this.name,
    required this.icon,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, masterId, code, icon, name, isActive];
}
