class AdOnEntity {
  final String subPackageId;
  final String serviceTypeName;
  final String label;
  final double packageValue;
  final bool isActive;

  const AdOnEntity({
    required this.subPackageId,
    required this.serviceTypeName,
    required this.label,
    required this.packageValue,
    required this.isActive,
  });
}

class ActivePackagesDetailsEntity {
  final String packageId;
  final String packageName;
  final double speedMbps;
  final String packageType;
  final int daysLeft;
  final DateTime activeUntil;
  final double renewalFee;
  final int totalPackageCount;
  final double availableVolumeGb;
  final int totalVolumeGb;
  final List<AdOnEntity> activeAddOns;

  const ActivePackagesDetailsEntity({
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
}