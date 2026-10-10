import 'package:equatable/equatable.dart';

class SubscriberDiscountEntity extends Equatable {
  final double packageFee;
  final double totalDiscount;
  final double discountedFee;
  final double discountRate;
  final double gstAmount;
  final double baseAmount;
  final double finalAmount;
  final List<AppliedRuleEntity> appliedRules;

  final double walletBalance;
  final double walletAmount;
  final double gatewayAmount;
  final bool walletEligible;

  // Package spec fields — populated once BE adds them to the response
  final String? speed;
  final String? validity;
  final String? volume;
  final String? volumeType;
  final String? category;
  final String? connectionType;
  final String? subscriptionType;

  // Billing detail fields — populated once BE adds them to the response
  final String? paymentMode;
  final String? location;
  final String? subscriberCategory;
  final String? subPackage;

  const SubscriberDiscountEntity({
    required this.packageFee,
    required this.totalDiscount,
    required this.discountedFee,
    required this.discountRate,
    required this.gstAmount,
    required this.baseAmount,
    required this.finalAmount,
    required this.appliedRules,
    this.walletBalance = 0,
    this.walletAmount = 0,
    this.gatewayAmount = 0,
    this.walletEligible = false,
    this.speed,
    this.validity,
    this.volume,
    this.volumeType,
    this.category,
    this.connectionType,
    this.subscriptionType,
    this.paymentMode,
    this.location,
    this.subscriberCategory,
    this.subPackage,
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
    walletBalance,
    walletAmount,
    gatewayAmount,
    walletEligible,
    speed,
    validity,
    volume,
    volumeType,
    category,
    connectionType,
    subscriptionType,
    paymentMode,
    location,
    subscriberCategory,
    subPackage,
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
