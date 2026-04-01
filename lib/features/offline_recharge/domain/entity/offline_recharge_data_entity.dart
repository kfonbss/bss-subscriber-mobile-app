// ─── Subscriber Details Entity ────────────────────────────────────────────────
import 'package:equatable/equatable.dart';
class SubscriberDetailsEntity extends Equatable {
  final String displayName;
  final String customerName;
  final String fullName;
  final String username;
  final double lastTopUpAmount;
  final double accountBalance;
  final String packageId;

  const SubscriberDetailsEntity({
    required this.displayName,
    required this.customerName,
    required this.fullName,
    required this.username,
    required this.lastTopUpAmount,
    required this.accountBalance,
    required this.packageId,
  });

  @override
  List<Object?> get props => [
    displayName,
    customerName,
    fullName,
    username,
    lastTopUpAmount,
    accountBalance,
    packageId,
  ];
}


// ─── Recharge Details Entity ──────────────────────────────────────────────────

class RechargeDetailsEntity extends Equatable {
  final String topupTo;
  final double topUpAmount;
  final double accountBalance;
  final String topUpMessage;
  final String firstName;
  final double lastPaid;
  final int rechargeCount;
  final String lastPlan;
  final String subscriptionStatus;

  const RechargeDetailsEntity({
    required this.topupTo,
    required this.topUpAmount,
    required this.accountBalance,
    required this.topUpMessage,
    required this.firstName,
    required this.lastPaid,
    required this.rechargeCount,
    required this.lastPlan,
    required this.subscriptionStatus,
  });

  @override
  List<Object?> get props => [
    topupTo,
    topUpAmount,
    accountBalance,
    topUpMessage,
    firstName,
    lastPaid,
    rechargeCount,
    lastPlan,
    subscriptionStatus,
  ];
}


class OfflineRechargeDataEntity extends Equatable {
  final SubscriberDetailsEntity subscriberDetails;
  final RechargeDetailsEntity rechargeDetails;

  const OfflineRechargeDataEntity({
    required this.subscriberDetails,
    required this.rechargeDetails,
  });

  @override
  List<Object?> get props => [
    subscriberDetails,
    rechargeDetails,
  ];
}