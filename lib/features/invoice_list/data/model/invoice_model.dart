import 'package:kfon_subscriber/features/invoice_list/domain/entity/invoice_entity.dart';

/// Model for parsing a single invoice from API JSON.
class InvoiceModel {
  final String invoiceId;
  final String invoiceNo;
  final double amount;
  final String invoiceDate;

  const InvoiceModel({
    required this.invoiceId,
    required this.invoiceNo,
    required this.amount,
    required this.invoiceDate,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceId: json['invoiceId']?.toString() ?? '',
      invoiceNo: json['invoiceNo']?.toString() ?? '',
      amount:
          (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      invoiceDate: json['invoiceDate']?.toString() ?? '',
    );
  }

  InvoiceEntity toEntity() {
    return InvoiceEntity(
      invoiceId: invoiceId,
      invoiceNo: invoiceNo,
      amount: amount,
      invoiceDate: invoiceDate,
    );
  }
}

/// Model for parsing the paginated invoice response from API JSON.
class InvoicePageModel {
  final List<InvoiceModel> content;
  final int totalPages;
  final int totalElements;
  final bool isLast;

  const InvoicePageModel({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
  });

  factory InvoicePageModel.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>? ?? [];
    return InvoicePageModel(
      content:
          contentList
              .map(
                (item) => InvoiceModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      isLast: json['last'] as bool? ?? true,
    );
  }

  InvoicePageEntity toEntity() {
    return InvoicePageEntity(
      invoices: content.map((model) => model.toEntity()).toList(),
      totalPages: totalPages,
      totalElements: totalElements,
      isLast: isLast,
    );
  }
}
