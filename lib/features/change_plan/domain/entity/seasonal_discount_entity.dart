import 'package:equatable/equatable.dart';

class SeasonalDiscountEntity extends Equatable {
  final String? seasonId;
  final String? seasonName;
  final String? seasonTypeName;
  final int? discountValue;
  final String? discountType;
  final double? discountedRenewalFee;

  const SeasonalDiscountEntity({
     this.seasonId,
     this.seasonName,
     this.seasonTypeName,
     this.discountValue,
     this.discountType,
     this.discountedRenewalFee
  });

  @override
  List<Object?> get props => [
    seasonId,
    seasonName,
    seasonTypeName,
    discountValue,
    discountType,
    discountedRenewalFee
  ];
}
