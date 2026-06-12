import 'package:kfon_subscriber/features/change_plan/data/models/package_new_model.dart';
import 'package:kfon_subscriber/features/home/domain/entity/home_entity.dart';

class ActiveAdoOnModel {
  final String subPackageId;
  final String serviceTypeName;
  final String label;
  final double packageValue;
  final bool isActive;

  const ActiveAdoOnModel({
    required this.subPackageId,
    required this.serviceTypeName,
    required this.label,
    required this.packageValue,
    required this.isActive,
  });

  factory ActiveAdoOnModel.fromJson(Map<String, dynamic> json) {
    return ActiveAdoOnModel(
      subPackageId: json['subPackageId'] as String? ?? '',
      serviceTypeName: json['serviceTypeName'] as String? ?? '',
      label: json['label'] as String? ?? '',
      packageValue: (json['packageValue'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'subPackageId': subPackageId,
    'serviceTypeName': serviceTypeName,
    'label': label,
    'packageValue': packageValue,
    'isActive': isActive,
  };

  ActiveAdOnEntity toEntity() => ActiveAdOnEntity(
    subPackageId: subPackageId,
    serviceTypeName: serviceTypeName,
    label: label,
    packageValue: packageValue,
    isActive: isActive,
  );
}

class PackageDetailsModel {
  final String packageId;
  final String packageName;
  final int speedMbps;
  final String packageType;
  final int daysLeft;
  final String activeUntil;
  final double renewalFee;
  final int totalPackageCount;
  final double availableVolumeGb;
  final int validity;
  final double totalVolumeGb;
  final PackageItemModel packageInfoModel;
  final List<ActiveAdoOnModel> activeAddOns;

  const PackageDetailsModel({
    required this.packageId,
    required this.packageName,
    required this.speedMbps,
    required this.packageType,
    required this.daysLeft,
    required this.activeUntil,
    required this.renewalFee,
    required this.totalPackageCount,
    required this.validity,
    required this.availableVolumeGb,
    required this.totalVolumeGb,
    required this.packageInfoModel,
    required this.activeAddOns,
  });

  factory PackageDetailsModel.fromJson(Map<String, dynamic> json) {
    return PackageDetailsModel(
      packageId: json['packageId'] as String? ?? '',
      packageName: json['packageName'] as String? ?? '',
      speedMbps: json['speedMbps'] as int? ?? 0,
      packageType: json['packageType'] as String? ?? '',
      packageInfoModel: PackageItemModel.fromJson(
        json['packageInfo'] as Map<String, dynamic>? ?? {},
      ),
      daysLeft: json['daysLeft'] as int? ?? 0,
      activeUntil: json['activeUntil'] as String? ?? '',
      renewalFee: (json['renewalFee'] as num?)?.toDouble() ?? 0.0,
      totalPackageCount: json['totalPackageCount'] as int? ?? 0,
      validity: json['validity'] as int? ?? 0,
      availableVolumeGb: (json['availableVolumeGb'] as num?)?.toDouble() ?? 0.0,
      totalVolumeGb: (json['totalVolumeGb'] as num?)?.toDouble() ?? 0.0,
      activeAddOns:
          (json['activeAddOns'] as List<dynamic>?)
              ?.map((e) => ActiveAdoOnModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'packageId': packageId,
    'packageName': packageName,
    'speedMbps': speedMbps,
    'packageType': packageType,
    'daysLeft': daysLeft,
    'activeUntil': activeUntil,
    'renewalFee': renewalFee,
    'totalPackageCount': totalPackageCount,
    'availableVolumeGb': availableVolumeGb,
    'validity': validity,
    'totalVolumeGb': totalVolumeGb,
    'activeAddOns': activeAddOns.map((e) => e.toJson()).toList(),
  };

  PackageDetailsEntity toEntity() => PackageDetailsEntity(
    packageId: packageId,
    packageName: packageName,
    speedMbps: speedMbps,
    packageType: packageType,
    daysLeft: daysLeft,
    activeUntil: DateTime.tryParse(activeUntil) ?? DateTime.now(),
    renewalFee: renewalFee,
    totalPackageCount: totalPackageCount,
    availableVolumeGb: availableVolumeGb,
    validity: validity,
    totalVolumeGb: totalVolumeGb,
    activeAddOns: activeAddOns.map((e) => e.toEntity()).toList(),
    packageInfoModel:  packageInfoModel.toEntity(),
  );
}

class HomeModel {
  final String firstName;
  final String username;
  final double balance;
  final String lastUpdated;
  final PackageDetailsModel? packageDetails;
  final String subscriberId;

  const HomeModel({
    required this.firstName,
    required this.username,
    required this.balance,
    required this.lastUpdated,
    required this.subscriberId,
    this.packageDetails,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      username: json['username'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastUpdated: json['lastUpdated'] as String? ?? '',
      subscriberId: json['subscriberId'] as String? ?? '',
      packageDetails:
          json['packageDetails'] != null
              ? PackageDetailsModel.fromJson(
                json['packageDetails'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'balance': balance,
    'lastUpdated': lastUpdated,
    'subscriberId': subscriberId,
    'packageDetails': packageDetails?.toJson(),
  };

  HomeEntity toEntity() => HomeEntity(
    username: username,
    firstName: firstName,
    balance: balance,
    subscriberId: subscriberId,
    lastUpdated: DateTime.tryParse(lastUpdated) ?? DateTime.now(),
    packageDetails: packageDetails?.toEntity(),
  );
}
