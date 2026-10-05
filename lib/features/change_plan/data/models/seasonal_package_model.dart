
import 'package:kfon_subscriber/features/change_plan/data/models/package_new_model.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';

class SeasonalPackageModel {
  final String packageId;
  final String packageName;
  final double price;
  final String speed;
  final String data;
  final int validity;
  final String planType;
  final String status;
  final int renewPeriod;
  final String? remarks;
  final String? badgeLabel;
  final String? seasonId;
  final String? seasonName;
  final PackageTypeModel? packageType;
  final String? subscriptionType;
  final double? listPrice;
  final double? discountAmount;

  const SeasonalPackageModel({
    required this.packageId,
    required this.packageName,
    required this.price,
    required this.speed,
    required this.data,
    required this.validity,
    required this.planType,
    required this.status,
    required this.renewPeriod,
    this.remarks,
    this.badgeLabel,
    this.seasonId,
    this.seasonName,
    this.packageType,
    this.subscriptionType,
    this.listPrice,
    this.discountAmount,
  });

  static double? _optionalDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String? _nameOrString(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      return value['code']?.toString() ?? value['name']?.toString();
    }
    return value.toString();
  }

  /// Matches seasonal list API: [speed] (Mbps tier string), else [speedInKbps].
  static String _speedLabel(Map<String, dynamic> json) {
    final raw = json['speed']?.toString().trim();
    if (raw != null && raw.isNotEmpty) {
      final parsed = double.tryParse(raw);
      if (parsed != null) {
        if (parsed == parsed.roundToDouble()) {
          return '${parsed.round()} Mbps';
        }
        return '${parsed.toStringAsFixed(1)} Mbps';
      }
      final lower = raw.toLowerCase();
      if (lower.contains('mbps') || lower.contains('kbps')) {
        return raw;
      }
      return '$raw Mbps';
    }
    final speedInKbps = (json['speedInKbps'] as num?)?.toInt() ?? 0;
    if (speedInKbps > 0) {
      final mbps = speedInKbps / 1024;
      return '${mbps.round()} Mbps';
    }
    return '--';
  }

  /// Prefers [volumeValue], then [allocatedVolume] + GB, then [volumeType] unlimited.
  static String _volumeDisplay(Map<String, dynamic> json) {
    final volumeValue = json['volumeValue']?.toString().trim();
    if (volumeValue != null && volumeValue.isNotEmpty) {
      return volumeValue;
    }
    final allocated = (json['allocatedVolume'] as num?)?.toInt();
    if (allocated != null) {
      return '$allocated GB';
    }
    final volumeType = json['volumeType']?.toString().toLowerCase();
    if (volumeType == 'unlimited') {
      return 'Unlimited';
    }
    return '--';
  }

  /// Billing validity in days: [validity] → [renewPeriod] → [freeValidity].
  static int _validityDays(Map<String, dynamic> json) {
    final v = (json['validity'] as num?)?.toInt();
    if (v != null && v > 0) return v;
    final r = (json['renewPeriod'] as num?)?.toInt();
    if (r != null && r > 0) return r;
    return (json['freeValidity'] as num?)?.toInt() ?? 0;
  }

  factory SeasonalPackageModel.fromJson(Map<String, dynamic> json) {
    final planTypeMap = json['planType'] as Map<String, dynamic>?;
    final seasonalDiscount = json['seasonalDiscount'] as Map<String, dynamic>?;
    final listPrice =
        _optionalDouble(json['listPrice']) ??
        _optionalDouble(json['originalAmount']) ??
        _optionalDouble(json['mrp']) ??
        _optionalDouble(json['originalPrice']);
    final discountFromSeasonal = seasonalDiscount == null
        ? null
        : (_optionalDouble(seasonalDiscount['discountAmount']) ??
            _optionalDouble(seasonalDiscount['amount']) ??
            _optionalDouble(seasonalDiscount['discount']) ??
            _optionalDouble(seasonalDiscount['discountValue']) ??
            _optionalDouble(seasonalDiscount['value']));
    final rootDiscount = _optionalDouble(json['discountAmount']);
    final saved = _optionalDouble(json['savedAmount']);
    final discountAmount = (rootDiscount != null && rootDiscount > 0)
        ? rootDiscount
        : (discountFromSeasonal != null && discountFromSeasonal > 0)
            ? discountFromSeasonal
            : (saved != null && saved > 0 ? saved : null);

    final festival = json['festivalTag']?.toString().trim();
    final String? badgeLabel;
    if (festival != null && festival.isNotEmpty) {
      badgeLabel = festival;
    } else if (seasonalDiscount != null) {
      badgeLabel = 'SEASONAL';
    } else {
      badgeLabel = null;
    }

    final planTypeLabel = json['planTypeName']?.toString().trim();
    final planTypeResolved = planTypeLabel != null && planTypeLabel.isNotEmpty
        ? planTypeLabel
        : (planTypeMap?['name']?.toString() ?? '');

    return SeasonalPackageModel(
      packageId: json['id']?.toString() ?? '',
      packageName: json['packageName']?.toString() ?? '',
      price: (json['amount'] as num?)?.toDouble() ??
          (json['renewalFee'] as num?)?.toDouble() ??
          0,
      speed: _speedLabel(json),
      data: _volumeDisplay(json),
      validity: _validityDays(json),
      planType: planTypeResolved,
      status: json['status']?.toString() ?? '',
      renewPeriod: (json['renewPeriod'] as num?)?.toInt() ?? 0,
      remarks: json['remarks']?.toString(),
      badgeLabel: badgeLabel,
      seasonId: seasonalDiscount?['seasonId']?.toString(),
      seasonName: seasonalDiscount?['seasonName']?.toString(),
      packageType: PackageTypeModel.fromJson(
        json['packageType'] as Map<String, dynamic>? ?? {},
      ),
      subscriptionType: _nameOrString(json['subscriberProfile']) ??
          json['subscriberCategory']?.toString() ??
          _nameOrString(json['subscriptionType']),
      listPrice: listPrice,
      discountAmount: discountAmount,
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
      status: status,
      renewPeriod: renewPeriod,
      remarks: remarks,
      badgeLabel: badgeLabel,
      seasonId: seasonId,
      seasonName: seasonName,
      packageType: packageType!.toEntity(),
      subscriptionType: subscriptionType,
      listPrice: listPrice,
      discountAmount: discountAmount,
    );
  }
}
