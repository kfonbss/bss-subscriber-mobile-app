import 'package:equatable/equatable.dart';

class RechargePaymentStatusEntity extends Equatable {
  final String orderId;
  final String gatewayType;
  final String txnId;
  final String referenceNo;
  final String transactionDate;
  final double amount;
  final String paymentStatus;

  const RechargePaymentStatusEntity({
    required this.orderId,
    required this.gatewayType,
    required this.txnId,
    required this.referenceNo,
    required this.transactionDate,
    required this.amount,
    required this.paymentStatus,
  });

  @override
  List<Object?> get props => [
    orderId,
    gatewayType,
    txnId,
    referenceNo,
    transactionDate,
    amount,
    paymentStatus,
  ];
}
