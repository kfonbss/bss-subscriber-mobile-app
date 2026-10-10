import 'package:equatable/equatable.dart';

class UpgradePlanPreviewEntity extends Equatable {
  final String subscriberId;
  final String currentPackageId;
  final String currentPackageName;
  final int currentRenewPeriod;
  final String currentExpiry;
  final int usedDays;
  final int remainingDays;
  final double amountActuallyPaid;
  final double currentPerDayValue;
  final double remainingValue;
  final String newPackageId;
  final String newPackageName;
  final int newRenewPeriod;
  final double newPackageFee;
  final double newPackageTotal;
  final double newPerDayValue;
  final int newValidityDays;
  final String newExpiry;

  const UpgradePlanPreviewEntity({
    required this.subscriberId,
    required this.currentPackageId,
    required this.currentPackageName,
    required this.currentRenewPeriod,
    required this.currentExpiry,
    required this.usedDays,
    required this.remainingDays,
    required this.amountActuallyPaid,
    required this.currentPerDayValue,
    required this.remainingValue,
    required this.newPackageId,
    required this.newPackageName,
    required this.newRenewPeriod,
    required this.newPackageFee,
    required this.newPackageTotal,
    required this.newPerDayValue,
    required this.newValidityDays,
    required this.newExpiry,
  });

  @override
  List<Object?> get props => [
    subscriberId,
    currentPackageId,
    currentPackageName,
    currentRenewPeriod,
    currentExpiry,
    usedDays,
    remainingDays,
    amountActuallyPaid,
    currentPerDayValue,
    remainingValue,
    newPackageId,
    newPackageName,
    newRenewPeriod,
    newPackageFee,
    newPackageTotal,
    newPerDayValue,
    newValidityDays,
    newExpiry,
  ];
}
