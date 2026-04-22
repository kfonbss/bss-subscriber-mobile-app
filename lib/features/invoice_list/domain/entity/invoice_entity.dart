/// Entity representing a single invoice.
class InvoiceEntity {
  final String invoiceId;
  final String invoiceNo;
  final double amount;
  final String invoiceDate;

  /// Full URL for downloading the invoice PDF.
  /// Empty string if the API did not return a URL for this invoice.
  final String fileId;

  const InvoiceEntity({
    required this.invoiceId,
    required this.invoiceNo,
    required this.amount,
    required this.invoiceDate,
    required this.fileId,
  });
}

/// Entity wrapping a paginated list of invoices.
class InvoicePageEntity {
  final List<InvoiceEntity> invoices;
  final int totalPages;
  final int totalElements;
  final bool isLast;

  const InvoicePageEntity({
    required this.invoices,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
  });
}
