import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/entity/transaction_filter.dart';

abstract class TransactionHistoryEvent extends Equatable {
  const TransactionHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch the first page of transactions using the current filter.
class FetchTransactions extends TransactionHistoryEvent {
  const FetchTransactions();
}

/// Event to load the next page of transactions.
class LoadMoreTransactions extends TransactionHistoryEvent {
  const LoadMoreTransactions();
}

/// Event to change the status / date-range filter and reload from page 0.
/// Ignored when [filter] equals the filter already applied.
class ApplyTransactionFilter extends TransactionHistoryEvent {
  final TransactionFilter filter;

  const ApplyTransactionFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}
