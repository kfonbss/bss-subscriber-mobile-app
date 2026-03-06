import 'package:equatable/equatable.dart';

abstract class TransactionHistoryEvent extends Equatable {
  const TransactionHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch the first page of transactions.
class FetchTransactions extends TransactionHistoryEvent {
  const FetchTransactions();
}

/// Event to load the next page of transactions.
class LoadMoreTransactions extends TransactionHistoryEvent {
  const LoadMoreTransactions();
}
