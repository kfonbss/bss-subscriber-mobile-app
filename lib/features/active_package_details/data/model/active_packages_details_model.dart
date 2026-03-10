import 'package:kfon_subscriber/features/active_package_details/domain/entity/active_packages_details_entity.dart';

class AdOnModel extends AdOnEntity {
  const AdOnModel({
    required super.subPackageId,
    required super.serviceTypeName,
    required super.label,
    required super.packageValue,
    required super.isActive,
  });

  factory AdOnModel.fromJson(Map<String, dynamic> json) {
    return AdOnModel(
      subPackageId: json['subPackageId'] as String,
      serviceTypeName: json['serviceTypeName'] as String,
      label: json['label'] as String,
      packageValue: (json['packageValue'] as num).toDouble(),
      isActive: json['isActive'] as bool,
    );
  }

  AdOnEntity toEntity() => AdOnEntity(
    subPackageId: subPackageId,
    serviceTypeName: serviceTypeName,
    label: label,
    packageValue: packageValue,
    isActive: isActive,
  );

  Map<String, dynamic> toJson() => {
    'subPackageId': subPackageId,
    'serviceTypeName': serviceTypeName,
    'label': label,
    'packageValue': packageValue,
    'isActive': isActive,
  };
}

class ActivePackagesDetailsModel extends ActivePackagesDetailsEntity {
  const ActivePackagesDetailsModel({
    required super.packageId,
    required super.packageName,
    required super.speedMbps,
    required super.packageType,
    required super.daysLeft,
    required super.activeUntil,
    required super.renewalFee,
    required super.totalPackageCount,
    required super.availableVolumeGb,
    required super.totalVolumeGb,
    required super.activeAddOns,
  });

  factory ActivePackagesDetailsModel.fromJson(Map<String, dynamic> json) {
    return ActivePackagesDetailsModel(
      packageId: json['packageId'] as String,
      packageName: json['packageName'] as String,
      speedMbps: (json['speedMbps'] as num).toDouble(),
      packageType: json['packageType'] as String,
      daysLeft: json['daysLeft'] as int,
      activeUntil: DateTime.parse(json['activeUntil'] as String),
      renewalFee: (json['renewalFee'] as num).toDouble(),
      totalPackageCount: json['totalPackageCount'] as int,
      availableVolumeGb: json['availableVolumeGb'] ??0,
      totalVolumeGb: json['totalVolumeGb']??0,
      activeAddOns:
          (json['activeAddOns'] as List<dynamic>)
              .map((e) => AdOnModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  ActivePackagesDetailsEntity toEntity() => ActivePackagesDetailsEntity(
    packageId: packageId,
    packageName: packageName,
    speedMbps: speedMbps,
    packageType: packageType,
    daysLeft: daysLeft,
    activeUntil: activeUntil,
    renewalFee: renewalFee,
    totalPackageCount: totalPackageCount,
    availableVolumeGb: availableVolumeGb,
    totalVolumeGb: totalVolumeGb,
    activeAddOns: activeAddOns,
  );

  Map<String, dynamic> toJson() => {
    'packageId': packageId,
    'packageName': packageName,
    'speedMbps': speedMbps,
    'packageType': packageType,
    'daysLeft': daysLeft,
    'activeUntil': activeUntil.toIso8601String().split('T').first,
    'renewalFee': renewalFee,
    'totalPackageCount': totalPackageCount,
    'availableVolumeGb': availableVolumeGb,
    'totalVolumeGb': totalVolumeGb,
    'activeAddOns': activeAddOns.map((e) => (e as AdOnModel).toJson()).toList(),
  };
}
