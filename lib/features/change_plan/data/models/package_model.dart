import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';

class PackageModel {
  final String packageId;
  final String packageName;
  final double price;
  final String speed;
  final String data;
  final int validity;
  final String planType;

  const PackageModel({
    required this.packageId,
    required this.packageName,
    required this.price,
    required this.speed,
    required this.data,
    required this.validity,
    required this.planType,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      packageId: json['packageId']?.toString() ?? '',
      packageName: json['packageName']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      speed: json['speed']?.toString() ?? '',
      data: json['data']?.toString() ?? '',
      validity: json['validity'] as int? ?? 0,
      planType: json['planType']?.toString() ?? '',
    );
  }

  PackageEntity toEntity() {
    return PackageEntity(
      packageId: packageId,
      packageName: packageName,
      price: price,
      speed: speed,
      data: data,
      validity: validity,
      planType: planType,
    );
  }
}
