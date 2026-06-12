
import 'package:kfon_subscriber/features/change_plan/domain/entity/discount_details_entity.dart';

class SubscriberDiscountResponseModel {
  final List<SubscriberDiscountModel> discounts;

  const SubscriberDiscountResponseModel({required this.discounts});

  factory SubscriberDiscountResponseModel.fromDynamic(dynamic raw) {
    if (raw is List) {
      return SubscriberDiscountResponseModel(
        discounts: raw
            .map(
              (e) => SubscriberDiscountModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
    }
    if (raw is Map<String, dynamic>) {
      return SubscriberDiscountResponseModel.fromJson(raw);
    }
    return const SubscriberDiscountResponseModel(discounts: []);
  }

  factory SubscriberDiscountResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final list = data is List ? data : const [];
    return SubscriberDiscountResponseModel(
      discounts: list
          .map(
            (e) => SubscriberDiscountModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  List<DiscountDetailsEntity> toEntity() =>
      discounts.map((e) => e.toEntity()).toList();
}

class SubscriberDiscountModel {
  final double packageFee;
  final double totalDiscount;
  final double discountedFee;
  final double discountRate;
  final double gstAmount;
  final double baseAmount;
  final double finalAmount;
  final List<AppliedRuleModel> appliedRules;

  // Optional fields — will be non-null once BE adds them
  final String? speed;
  final int? validity;
  final String? volume;
  final String? category;
  final String? connectionType;
  final String? paymentMode;
  final String? location;
  final String? subscriberCategory;
  final String? subPackage;
  final double? walletBalance;
  final double? walletAmount;
  final double? gatewayAmount;
  final bool? walletEligible;

  const SubscriberDiscountModel({
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

  factory SubscriberDiscountModel.fromJson(Map<String, dynamic> json) {
    final rules = json['appliedRules'] as List<dynamic>? ?? const [];
    return SubscriberDiscountModel(
      packageFee: (json['packageFee'] as num?)?.toDouble() ?? 0,
      totalDiscount: (json['totalDiscount'] as num?)?.toDouble() ?? 0,
      discountedFee: (json['discountedFee'] as num?)?.toDouble() ?? 0,
      discountRate: (json['discountRate'] as num?)?.toDouble() ?? 0,
      gstAmount: (json['gstAmount'] as num?)?.toDouble() ?? 0,
      baseAmount: (json['baseAmount'] as num?)?.toDouble() ?? 0,
      finalAmount: (json['finalAmount'] as num?)?.toDouble() ?? 0,
      appliedRules: rules
          .map((e) => AppliedRuleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      speed: json['speed'] as String?,
      validity: json['validity'] as int?,
      volume: json['volume'] as String?,
      category: json['category'] as String?,
      connectionType: json['connectionType'] as String?,
      paymentMode: json['paymentMode'] as String?,
      location: json['location'] as String?,
      subscriberCategory: json['subscriberCategory'] as String?,
      subPackage: json['subPackage'] as String?,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0,
      walletAmount: (json['walletAmount'] as num?)?.toDouble() ?? 0,
      gatewayAmount: (json['gatewayAmount'] as num?)?.toDouble() ?? 0,
      walletEligible: json['walletEligible'] as bool? ?? false,
    );
  }

  DiscountDetailsEntity toEntity() {
    return DiscountDetailsEntity(
      packageFee: packageFee,
      totalDiscount: totalDiscount,
      discountedFee: discountedFee,
      discountRate: discountRate,
      gstAmount: gstAmount,
      baseAmount: baseAmount,
      finalAmount: finalAmount,
      appliedRules: appliedRules.map((e) => e.toEntity()).toList(),
      speed: speed,
      validity: validity,
      volume: volume,
      category: category,
      connectionType: connectionType,
      paymentMode: paymentMode,
      location: location,
      subscriberCategory: subscriberCategory,
      subPackage: subPackage,
      walletBalance: walletBalance,
      walletAmount: walletAmount,
      gatewayAmount: gatewayAmount,
      walletEligible: walletEligible,
    );
  }
}

class AppliedRuleModel {
  final String ruleId;
  final String ruleName;
  final double discountValue;
  final String discountType;
  final double discountAmount;

  const AppliedRuleModel({
    required this.ruleId,
    required this.ruleName,
    required this.discountValue,
    required this.discountType,
    required this.discountAmount,
  });

  factory AppliedRuleModel.fromJson(Map<String, dynamic> json) {
    return AppliedRuleModel(
      ruleId: json['ruleId']?.toString() ?? '',
      ruleName: json['ruleName'] as String? ?? '',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
      discountType: json['discountType'] as String? ?? '',
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  AppliedRuleEntity toEntity() {
    return AppliedRuleEntity(
      ruleId: ruleId,
      ruleName: ruleName,
      discountValue: discountValue,
      discountType: discountType,
      discountAmount: discountAmount,
    );
  }
}
