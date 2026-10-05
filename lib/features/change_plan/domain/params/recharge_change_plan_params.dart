import 'package:equatable/equatable.dart';

class RechargeChangePlanParams extends Equatable {
  final String packageId;
  final String? gateway;
  final double amount;
  final double expectedFinalAmount;
  final int durationDays;
  final String? seasonId;
  final bool referral;
  final bool useWallet;
  final bool changePlan;

  const RechargeChangePlanParams({
    required this.packageId,
    required this.gateway,
    required this.amount,
    required this.durationDays,
    required this.expectedFinalAmount,
    this.seasonId,
    required this.referral,
    required this.useWallet,
    required this.changePlan,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'gateway': gateway,
      'amount': amount,
      'durationDays': durationDays,
      'expectedFinalAmount': expectedFinalAmount,
      'seasonId': seasonId,
      'referral': referral,
      'useWallet': useWallet,
      'changePlan': changePlan,
    };
  }

  @override
  List<Object?> get props => [
    packageId,
    gateway,
    amount,
    durationDays,
    expectedFinalAmount,
    seasonId,
    referral,
    useWallet,
    changePlan,
  ];
}
