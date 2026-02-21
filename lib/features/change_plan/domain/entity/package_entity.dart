import 'package:equatable/equatable.dart';

class PackageEntity extends Equatable {
  final String packageId;
  final String packageName;
  final double price;
  final String speed;
  final String data;
  final int validity;
  final String planType;

  const PackageEntity({
    required this.packageId,
    required this.packageName,
    required this.price,
    required this.speed,
    required this.data,
    required this.validity,
    required this.planType,
  });

  @override
  List<Object?> get props => [
    packageId,
    packageName,
    price,
    speed,
    data,
    validity,
    planType,
  ];
}
