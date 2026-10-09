import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';

class PackageEntity extends Equatable {
  final String packageId;
  final String packageName;
  final double price;
  final String speed;
  final String data;
  final int validity;
  final String planType;
  final String? status;
  final int? renewPeriod;
  final String? remarks;
  final String? badgeLabel;
  final String? seasonId;
  final String? seasonName;
  final PackageTypeEntity? packageType;
  final String? subscriptionType;

  /// When provided by the API (e.g. MRP / list price), shown crossed out above [price].
  final double? listPrice;

  /// Optional seasonal/promotional discount amount from the API (e.g. seasonal preview).
  final double? discountAmount;

  const PackageEntity({
    required this.packageId,
    required this.packageName,
    required this.price,
    required this.speed,
    required this.data,
    required this.validity,
    required this.planType,
    this.status,
    this.renewPeriod,
    this.remarks,
    this.badgeLabel,
    this.seasonId,
    this.seasonName,
    this.packageType,
    this.subscriptionType,
    this.listPrice,
    this.discountAmount,
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
    status,
    renewPeriod,
    remarks,
    badgeLabel,
    seasonId,
    seasonName,
    packageType,
    subscriptionType,
    listPrice,
    discountAmount,
  ];
}
