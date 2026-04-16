/// Entity representing a single recharge transaction.
class TransactionEntity {
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

  /// Full URL for downloading the transaction invoice PDF.
  /// Empty string if the API did not return a URL for this transaction.
  final String invoiceUrl;

  const TransactionEntity({
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
}

/// Entity wrapping a paginated list of transactions.
class TransactionPageEntity {
  final List<TransactionEntity> transactions;
  final int totalPages;
  final int totalElements;
  final bool isLast;

  const TransactionPageEntity({
    required this.transactions,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
  });
}
