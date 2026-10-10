import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/entity/transaction_entity.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/entity/transaction_filter.dart';

abstract class TransactionHistoryState extends Equatable {
  /// Filter the state was produced with, so the filter bar stays in sync in
  /// every state (loading / loaded / error).
  final TransactionFilter filter;

  const TransactionHistoryState({this.filter = TransactionFilter.none});

  @override
  List<Object?> get props => [filter];
}

class TransactionHistoryInitial extends TransactionHistoryState {
  const TransactionHistoryInitial();
}

/// State while first page is loading.
class TransactionHistoryLoading extends TransactionHistoryState {
  const TransactionHistoryLoading({super.filter});
}

/// State when transactions are loaded (supports pagination).
class TransactionHistoryLoaded extends TransactionHistoryState {
  final List<TransactionEntity> transactions;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final int currentPage;

  /// Non-null when a load-more request failed. Cleared on the next
  /// successful load-more or full refresh (new state instance).
  final String? paginationError;

  const TransactionHistoryLoaded({
    required this.transactions,
    required this.hasReachedMax,
    this.isLoadingMore = false,
    required this.currentPage,
    this.paginationError,
    super.filter,
  });

  // Sentinel used so copyWith can explicitly clear paginationError to null.
  static const _clear = Object();

  TransactionHistoryLoaded copyWith({
    List<TransactionEntity>? transactions,
    bool? hasReachedMax,
    bool? isLoadingMore,
    int? currentPage,
    Object? paginationError = _clear,
  }) {
    return TransactionHistoryLoaded(
      transactions: transactions ?? this.transactions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      paginationError:
          identical(paginationError, _clear)
              ? this.paginationError
              : paginationError as String?,
      filter: filter,
    );
  }

  @override
  List<Object?> get props => [
    filter,
    transactions,
    hasReachedMax,
    isLoadingMore,
    currentPage,
    paginationError,
  ];
}

/// State when an error occurs.
class TransactionHistoryError extends TransactionHistoryState {
  final String message;

  const TransactionHistoryError({required this.message, super.filter});

  @override
  List<Object?> get props => [filter, message];
}
