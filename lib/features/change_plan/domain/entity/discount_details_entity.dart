import 'package:equatable/equatable.dart';

class DiscountDetailsEntity extends Equatable {
  final double packageFee;
  final double totalDiscount;
  final double discountedFee;
  final double discountRate;
  final double gstAmount;
  final double baseAmount;
  final double finalAmount;
  final List<AppliedRuleEntity> appliedRules;

  // Package spec fields — populated once BE adds them to the response
  final String? speed;
  final int? validity;
  final String? volume;
  final String? category;
  final String? connectionType;

  // Billing detail fields — populated once BE adds them to the response
  final String? paymentMode;
  final String? location;
  final String? subscriberCategory;
  final String? subPackage;

  final double? walletBalance;
  final double? walletAmount;
  final double? gatewayAmount;
  final bool? walletEligible;

  const DiscountDetailsEntity({
    required this.packageFee,
    required this.totalDiscount,
    required this.discountedFee,
    required this.discountRate,
    required this.gstAmount,
    required this.baseAmount,
    required this.finalAmount,
    required this.appliedRules,
    this.speed,
    this.validity,
    this.volume,
    this.category,
    this.connectionType,
    this.paymentMode,
    this.location,
    this.subscriberCategory,
    this.subPackage,
    this.walletBalance,
    this.walletAmount,
    this.gatewayAmount,
    this.walletEligible,
  });

  @override
  List<Object?> get props => [
    packageFee,
    totalDiscount,
    discountedFee,
    discountRate,
    gstAmount,
    baseAmount,
    finalAmount,
    appliedRules,
    speed,
    validity,
    volume,
    category,
    connectionType,
    paymentMode,
    location,
    subscriberCategory,
    subPackage,
    walletBalance,
    walletAmount,
    gatewayAmount,
    walletEligible,
  ];
}

class AppliedRuleEntity extends Equatable {
  final String ruleId;
  final String ruleName;
  final double discountValue;
  final String discountType;
  final double discountAmount;

  const AppliedRuleEntity({
    required this.ruleId,
    required this.ruleName,
    required this.discountValue,
    required this.discountType,
    required this.discountAmount,
  });

  @override
  List<Object?> get props => [
    ruleId,
    ruleName,
    discountValue,
    discountType,
    discountAmount,
  ];
}
