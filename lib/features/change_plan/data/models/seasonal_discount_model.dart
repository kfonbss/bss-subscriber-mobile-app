import 'package:kfon_subscriber/features/change_plan/domain/entity/seasonal_discount_entity.dart';

class SeasonalDiscountModel {
  final String? seasonId;
  final String? seasonName;
  final String? seasonTypeName;
  final int? discountValue;
  final String? discountType;
  final double? discountedRenewalFee;

  const SeasonalDiscountModel({
     this.seasonId,
     this.seasonName,
     this.seasonTypeName,
     this.discountValue,
     this.discountType,
     this.discountedRenewalFee
  });

  factory SeasonalDiscountModel.fromJson(Map<String, dynamic> json) {
    return SeasonalDiscountModel(
      seasonId: json['seasonId']?.toString() ?? '',
      seasonName: json['seasonName']?.toString() ?? '',
      seasonTypeName: json['seasonTypeName']?.toString() ??'',
      discountValue: json['discountValue'] as int? ?? 0,
      discountType: json['discountType']?.toString() ??'',
      discountedRenewalFee: (json['discountedRenewalFee'] as num?)?.toDouble() ?? 0.0,
    );
  }

  SeasonalDiscountEntity toEntity() {
    return SeasonalDiscountEntity(
      seasonId: seasonId,
      seasonName: seasonName,
      seasonTypeName: seasonTypeName,
      discountValue: discountValue,
      discountType: discountType,
      discountedRenewalFee: discountedRenewalFee
    );
  }
}