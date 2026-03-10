import 'package:equatable/equatable.dart';

class ActiveAdOnEntity extends Equatable {
  final String subPackageId;
  final String serviceTypeName;
  final String label;
  final double packageValue;
  final bool isActive;

  const ActiveAdOnEntity({
    required this.subPackageId,
    required this.serviceTypeName,
    required this.label,
    required this.packageValue,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    subPackageId,
    serviceTypeName,
    label,
    packageValue,
    isActive,
  ];
}

class PackageDetailsEntity extends Equatable {
  final String packageId;
  final String packageName;
  final double speedMbps;
  final String packageType;
  final int daysLeft;
  final DateTime activeUntil;
  final double renewalFee;
  final int totalPackageCount;
  final double availableVolumeGb;
  final double totalVolumeGb;
  final List<ActiveAdOnEntity> activeAddOns;

  const PackageDetailsEntity({
    required this.packageId,
    required this.packageName,
    required this.speedMbps,
    required this.packageType,
    required this.daysLeft,
    required this.activeUntil,
    required this.renewalFee,
    required this.totalPackageCount,
    required this.availableVolumeGb,
    required this.totalVolumeGb,
    required this.activeAddOns,
  });

  @override
  List<Object?> get props => [
    packageId,
    packageName,
    speedMbps,
    packageType,
    daysLeft,
    activeUntil,
    renewalFee,
    totalPackageCount,
    availableVolumeGb,
    totalVolumeGb,
    activeAddOns,
  ];
}

class HomeEntity extends Equatable {
  final double balance;
  final DateTime lastUpdated;
  final String subscriberId;
  final PackageDetailsEntity? packageDetails;

  const HomeEntity({
    required this.balance,
    required this.lastUpdated,
    required this.subscriberId,
    this.packageDetails,
  });

  @override
  List<Object?> get props => [balance, lastUpdated, packageDetails,subscriberId];
}

