import 'package:equatable/equatable.dart';

class ChangePlanRequestParams extends Equatable {
  final String subscriberName;
  final String packageId;
  final String packageName;
  final String planType;
  final String? seasonId;
  final String? seasonName;
  final String? referralCode;
  final num expectedFinalAmount;
  final bool refferal;

  const ChangePlanRequestParams({
    this.subscriberName = '',
    required this.packageId,
    required this.packageName,
    required this.planType,
    this.seasonId,
    this.seasonName,
    this.referralCode,
    this.expectedFinalAmount = 0,
    this.refferal = false,
  });

  Map<String, dynamic> toSingleRechargeJson(String subscriberUuid) {
    return {
      'subscriberId': subscriberUuid,
      'subscriberName': subscriberName,
      'packageId': packageId,
      'packageName': packageName,
      'seasonId': seasonId,
      'seasonName': seasonName,
      'referralCode': referralCode,
      'expectedFinalAmount': expectedFinalAmount,
      'refferal': refferal,
    };
  }

  @override
  List<Object?> get props => [
    subscriberName,
    packageId,
    packageName,
    planType,
    seasonId,
    seasonName,
    referralCode,
    expectedFinalAmount,
    refferal,
  ];
}
