import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';

extension PackageEntityX on PackageEntity {
  PackageInfoEntity toPackageInfoEntity() {
    final original = listPrice ?? price;
    final saved = discountAmount ?? (original - price).clamp(0, double.infinity).toDouble();

    return PackageInfoEntity(
      id: packageId,
      packageName: packageName,
      freeValidity: 0,
      initialFreeValidity: 0,
      renewalFee: price,
      allocatedVolume: _parseVolume(data),
      discount: null,
      fallbackSpeed: '',
      subPackageCount: 0,
      totalPackageCount: null,
      remarks: remarks,
      renewPeriod: renewPeriod ?? 0,
      speedInKbps: 0,
      type: subscriptionType,
      packageType: packageType!,
      category: null,
      seasonalDiscount: seasonName,
      subscriberCategory: null,
      broadbandCategory: null,
      discountType: null,
      festivalTag: badgeLabel,
      createCorrespondingTermPlan: false,
      speedProfile: '',
      status: status ?? '',
      fbSpeedInKbps: 0,
      editable: false,
      amount: price,
      originalAmount: original,
      discountAmount: discountAmount ?? 0,
      savedAmount: saved,
      speed: speed,
      validity: validity,
      volumeType: '',
      volumeValue: data,
      planTypeName: planType,
    );
  }

  /// Extracts the number from strings like "100 GB" or "Unlimited".
  static double _parseVolume(String data) =>
      double.tryParse(RegExp(r'[\d.]+').firstMatch(data)?.group(0) ?? '') ?? 0;
}