import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/recharge_change_plan_params.dart';

abstract class DiscountEvent extends Equatable {
  const DiscountEvent();

  @override
  List<Object?> get props => [];
}

class SubmitTopUp extends DiscountEvent {
  final String subscriberUuid;
  final String subscriberName;
  final String packageId;
  final String packageName;
  final num expectedFinalAmount;
  final String? seasonId;
  final String? seasonName;
  final String? referralCode;
  final bool refferal;

  const SubmitTopUp({
    required this.subscriberUuid,
    required this.subscriberName,
    required this.packageId,
    required this.packageName,
    required this.expectedFinalAmount,
    this.seasonId,
    this.seasonName,
    this.referralCode,
    this.refferal = false,
  });

  @override
  List<Object?> get props => [
    subscriberUuid,
    subscriberName,
    packageId,
    packageName,
    expectedFinalAmount,
    seasonId,
    seasonName,
    referralCode,
    refferal,
  ];
}

class FetchTopUpDiscount extends DiscountEvent {
  final String packageId;
  final String? seasonId;
  final bool referral;
  final String referralCode;

  const FetchTopUpDiscount({
    required this.packageId,
    this.seasonId,
    this.referral = false,
    this.referralCode = '',
  });

  @override
  List<Object?> get props => [packageId, seasonId, referral, referralCode];
}

class GetSeasonalId extends DiscountEvent {
  final String packageId;

  const GetSeasonalId({required this.packageId});

  @override
  List<Object?> get props => [packageId];
}

class ResetTopUpState extends DiscountEvent {
  const ResetTopUpState();
}
class FetchRechargePaymentStatus extends DiscountEvent {
  final String orderId;

  const FetchRechargePaymentStatus({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class RechargeChangePlan extends DiscountEvent {
  final RechargeChangePlanParams params;

  const RechargeChangePlan({required this.params});

  @override
  List<Object?> get props => [params];
}
