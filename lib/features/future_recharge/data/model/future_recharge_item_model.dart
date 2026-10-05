import 'package:kfon_subscriber/features/future_recharge/domain/entity/future_recharge_item_entity.dart';

class FutureRechargeItemModel {
  final String rechargeId;
  final String subscriberName;
  final String username;
  final String planName;
  final double amount;
  final String speed;
  final String rechargeMode;
  final DateTime expiryDate;
  final DateTime orderTime;

  const FutureRechargeItemModel({
    required this.rechargeId,
    required this.subscriberName,
    required this.rechargeMode,
    required this.username,
    required this.planName,
    required this.amount,
    required this.speed,
    required this.expiryDate,
    required this.orderTime,
  });

  factory FutureRechargeItemModel.fromJson(Map<String, dynamic> json) {
    return FutureRechargeItemModel(
      rechargeId: json['rechargeId']?.toString() ?? '',
      rechargeMode: json['rechargeMode']?.toString() ?? '',
      subscriberName: json['subscriberName']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      planName: json['planName']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      speed: json['speed']?.toString() ?? '',
      expiryDate: json['expiry'] != null
          ? DateTime.parse(json['expiry'] as String)
          : DateTime.now(),
      orderTime: json['orderTime'] != null
          ? DateTime.parse(json['orderTime'] as String)
          : DateTime.now(),
    );
  }

  FutureRechargeItemEntity toEntity() {
    return FutureRechargeItemEntity(
      rechargeId: rechargeId,
      subscriberName: subscriberName,
      rechargeMode: rechargeMode,
      username: username,
      planName: planName,
      amount: amount,
      speed: speed,
      expiryDate: expiryDate,
      orderTime: orderTime,
    );
  }
}
