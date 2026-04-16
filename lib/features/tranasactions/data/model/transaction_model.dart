import 'package:kfon_subscriber/features/tranasactions/domain/entity/transaction_entity.dart';

/// Model for parsing a single transaction from API JSON.
class TransactionModel {
  final String transactionId;
  final String bssNo;
  final String txnReference;
  final double amount;
  final String packageName;
  final String expiryDate;
  final String status;
  final String paidOn;
  final String paidBy;
  final String paymentGateway;
  final String responseMessage;
  final String invoiceUrl;

  const TransactionModel({
    required this.transactionId,
    required this.bssNo,
    required this.txnReference,
    required this.amount,
    required this.packageName,
    required this.expiryDate,
    required this.status,
    required this.paidOn,
    required this.paidBy,
    required this.paymentGateway,
    required this.responseMessage,
    required this.invoiceUrl,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transactionId']?.toString() ?? '',
      bssNo: json['bssNo']?.toString() ?? '',
      txnReference: json['txnReference']?.toString() ?? '',
      amount:
          (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      packageName: json['packageName']?.toString() ?? '',
      expiryDate: json['expiryDate']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      paidOn: json['paidOn']?.toString() ?? '',
      paidBy: json['paidBy']?.toString() ?? '',
      paymentGateway: json['paymentGateway']?.toString() ?? '',
      responseMessage: json['responseMessage']?.toString() ?? '',
      invoiceUrl: json['invoiceUrl']?.toString() ?? '',
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      transactionId: transactionId,
      bssNo: bssNo,
      txnReference: txnReference,
      amount: amount,
      packageName: packageName,
      expiryDate: expiryDate,
      status: status,
      paidOn: paidOn,
      paidBy: paidBy,
      paymentGateway: paymentGateway,
      responseMessage: responseMessage,
      invoiceUrl: invoiceUrl,
    );
  }
}

/// Model for parsing the paginated transaction response from API JSON.
class TransactionPageModel {
  final List<TransactionModel> content;
  final int totalPages;
  final int totalElements;
  final bool isLast;

  const TransactionPageModel({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
  });

  factory TransactionPageModel.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>? ?? [];
    return TransactionPageModel(
      content:
          contentList
              .map(
                (item) =>
                    TransactionModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      isLast: json['last'] as bool? ?? true,
    );
  }

  TransactionPageEntity toEntity() {
    return TransactionPageEntity(
      transactions: content.map((model) => model.toEntity()).toList(),
      totalPages: totalPages,
      totalElements: totalElements,
      isLast: isLast,
    );
  }
}
