import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_payment_status_entity.dart';

class RechargePaymentStatusModel {
  final String orderId;
  final String gatewayType;
  final String txnId;
  final String referenceNo;
  final String transactionDate;
  final double amount;
  final String paymentStatus;

  const RechargePaymentStatusModel({
    required this.orderId,
    required this.gatewayType,
    required this.txnId,
    required this.referenceNo,
    required this.transactionDate,
    required this.amount,
    required this.paymentStatus,
  });

  factory RechargePaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return RechargePaymentStatusModel(
      orderId: json['orderId']?.toString() ?? '',
      gatewayType: json['gatewayType']?.toString() ?? '',
      txnId: json['txnId']?.toString() ?? '',
      referenceNo: json['referenceNo']?.toString() ?? '',
      transactionDate: json['transactionDate']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus']?.toString() ?? '',
    );
  }

  RechargePaymentStatusEntity toEntity() {
    return RechargePaymentStatusEntity(
      orderId: orderId,
      gatewayType: gatewayType,
      txnId: txnId,
      referenceNo: referenceNo,
      transactionDate: transactionDate,
      amount: amount,
      paymentStatus: paymentStatus,
    );
  }
}
