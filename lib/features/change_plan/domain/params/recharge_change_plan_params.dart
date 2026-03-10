import 'package:equatable/equatable.dart';

class RechargeChangePlanParams extends Equatable {
  final String packageId;
  final String gateway;
  final double amount;
  final int durationDays;

  const RechargeChangePlanParams({
    required this.packageId,
    required this.gateway,
    required this.amount,
    required this.durationDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'gateway': gateway,
      'amount': amount,
      'durationDays': durationDays,
    };
  }

  @override
  List<Object?> get props => [packageId, gateway, amount, durationDays];
}
