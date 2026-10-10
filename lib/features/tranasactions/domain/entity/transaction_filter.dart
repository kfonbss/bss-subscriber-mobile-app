import 'package:equatable/equatable.dart';

/// Optional filters for the recharge-transactions list.
///
/// [status] is one of [statuses] (null = all). The date range is only
/// meaningful when both [fromDate] and [toDate] are set.
class TransactionFilter extends Equatable {
  final String? status;
  final DateTime? fromDate;
  final DateTime? toDate;

  const TransactionFilter({this.status, this.fromDate, this.toDate});

  static const none = TransactionFilter();

  /// Status values accepted by the API `status` query parameter.
  static const statuses = [
    'SUCCESS',
    'FAILED',
    'PENDING',
    'INITIATED',
    'CANCELLED',
    'REFUNDED',
  ];

  bool get hasDateRange =>
      fromDate != null && toDate != null && !fromDate!.isAfter(toDate!);

  bool get isActive => status != null || hasDateRange;

  TransactionFilter withStatus(String? value) =>
      TransactionFilter(status: value, fromDate: fromDate, toDate: toDate);

  TransactionFilter withDateRange(DateTime? from, DateTime? to) =>
      TransactionFilter(status: status, fromDate: from, toDate: to);

  @override
  List<Object?> get props => [status, fromDate, toDate];
}
