class FutureRechargeItemEntity {
  final String rechargeId;
  final String subscriberName;
  final String rechargeMode;
  final String username;
  final String planName;
  final double amount;
  final String speed;
  final DateTime expiryDate;
  final DateTime orderTime;

  const FutureRechargeItemEntity({
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
}
