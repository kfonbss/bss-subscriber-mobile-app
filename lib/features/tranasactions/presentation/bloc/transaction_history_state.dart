import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/entity/transaction_entity.dart';

abstract class TransactionHistoryState extends Equatable {
  const TransactionHistoryState();

  @override
  List<Object?> get props => [];
}

class TransactionHistoryInitial extends TransactionHistoryState {
  const TransactionHistoryInitial();
}

/// State while first page is loading.
class TransactionHistoryLoading extends TransactionHistoryState {
  const TransactionHistoryLoading();
}

/// State when transactions are loaded (supports pagination).
class TransactionHistoryLoaded extends TransactionHistoryState {
  final List<TransactionEntity> transactions;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final int currentPage;

  const TransactionHistoryLoaded({
    required this.transactions,
    required this.hasReachedMax,
    this.isLoadingMore = false,
    required this.currentPage,
  });

  TransactionHistoryLoaded copyWith({
    List<TransactionEntity>? transactions,
    bool? hasReachedMax,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return TransactionHistoryLoaded(
      transactions: transactions ?? this.transactions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    hasReachedMax,
    isLoadingMore,
    currentPage,
  ];
}

/// State when an error occurs.
class TransactionHistoryError extends TransactionHistoryState {
  final String message;

  const TransactionHistoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
