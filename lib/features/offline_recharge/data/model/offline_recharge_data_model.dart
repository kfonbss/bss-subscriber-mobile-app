// ─── Subscriber Details ───────────────────────────────────────────────────────

import 'package:kfon_subscriber/features/offline_recharge/domain/entity/offline_recharge_data_entity.dart';

class SubscriberDetails {
  final String displayName;
  final String customerName;
  final String fullName;
  final String username;
  final double lastTopUpAmount;
  final double accountBalance;
  final String packageId;

  SubscriberDetails({
    required this.displayName,
    required this.customerName,
    required this.fullName,
    required this.username,
    required this.lastTopUpAmount,
    required this.accountBalance,
    required this.packageId,
  });

  factory SubscriberDetails.fromJson(Map<String, dynamic> json) {
    return SubscriberDetails(
      displayName: json['displayName'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      lastTopUpAmount: (json['lastTopUpAmount'] as num? ?? 0).toDouble(),
      accountBalance: (json['accountBalance'] as num? ?? 0).toDouble(),
      packageId: json['packageId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'customerName': customerName,
    'fullName': fullName,
    'username': username,
    'lastTopUpAmount': lastTopUpAmount,
    'accountBalance': accountBalance,
    'packageId': packageId,
  };

  SubscriberDetailsEntity toEntity() => SubscriberDetailsEntity(
    displayName: displayName,
    customerName: customerName,
    fullName: fullName,
    username: username,
    lastTopUpAmount: lastTopUpAmount,
    accountBalance: accountBalance,
    packageId: packageId,
  );
}

// ─── Recharge Details ─────────────────────────────────────────────────────────

class RechargeDetails {
  final String topupTo;
  final double topUpAmount;
  final double accountBalance;
  final String topUpMessage;
  final String firstName;
  final double lastPaid;
  final int rechargeCount;
  final String lastPlan;
  final String subscriptionStatus;

  RechargeDetails({
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

  factory RechargeDetails.fromJson(Map<String, dynamic> json) {
    return RechargeDetails(
      topupTo: json['topupTo'] as String? ?? '',
      topUpAmount: (json['topUpAmount'] as num? ?? 0).toDouble(),
      accountBalance: (json['accountBalance'] as num? ?? 0).toDouble(),
      topUpMessage: json['topUpMessage'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastPaid: (json['lastPaid'] as num? ?? 0).toDouble(),
      rechargeCount: json['rechargeCount'] as int? ?? 0,
      lastPlan: json['lastPlan'] as String? ?? '',
      subscriptionStatus: json['subscriptionStatus'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'topupTo': topupTo,
    'topUpAmount': topUpAmount,
    'accountBalance': accountBalance,
    'topUpMessage': topUpMessage,
    'firstName': firstName,
    'lastPaid': lastPaid,
    'rechargeCount': rechargeCount,
    'lastPlan': lastPlan,
    'subscriptionStatus': subscriptionStatus,
  };

  RechargeDetailsEntity toEntity() => RechargeDetailsEntity(
    topupTo: topupTo,
    topUpAmount: topUpAmount,
    accountBalance: accountBalance,
    topUpMessage: topUpMessage,
    firstName: firstName,
    lastPaid: lastPaid,
    rechargeCount: rechargeCount,
    lastPlan: lastPlan,
    subscriptionStatus: subscriptionStatus,
  );
}

// ─── Root Data Model ──────────────────────────────────────────────────────────

class OfflineRechargeDataModel {
  final SubscriberDetails subscriberDetails;
  final RechargeDetails rechargeDetails;

  OfflineRechargeDataModel({
    required this.subscriberDetails,
    required this.rechargeDetails,
  });

  factory OfflineRechargeDataModel.fromJson(Map<String, dynamic> json) {
    return OfflineRechargeDataModel(
      subscriberDetails: SubscriberDetails.fromJson(
        json['subscriberDetails'] as Map<String, dynamic>,
      ),
      rechargeDetails: RechargeDetails.fromJson(
        json['rechargeDetails'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'subscriberDetails': subscriberDetails.toJson(),
    'rechargeDetails': rechargeDetails.toJson(),
  };

  OfflineRechargeDataEntity toEntity() => OfflineRechargeDataEntity(
    subscriberDetails: subscriberDetails.toEntity(),
    rechargeDetails: rechargeDetails.toEntity(),
  );
}
