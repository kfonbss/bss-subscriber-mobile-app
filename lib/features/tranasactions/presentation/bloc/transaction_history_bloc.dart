import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/entity/transaction_filter.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/repository/transaction_repository.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/bloc/transaction_history_event.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/bloc/transaction_history_state.dart';

class TransactionHistoryBloc
    extends Bloc<TransactionHistoryEvent, TransactionHistoryState> {
  final TransactionRepository repository;

  static const int _pageSize = 10;

  TransactionFilter _filter = TransactionFilter.none;

  /// Incremented whenever a new first-page request starts. Responses that
  /// belong to an older request are dropped so a slow, stale response can
  /// never overwrite the result of a newer filter.
  int _requestId = 0;

  TransactionHistoryBloc({required this.repository})
    : super(const TransactionHistoryInitial()) {
    on<FetchTransactions>(_onFetchTransactions);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<ApplyTransactionFilter>(_onApplyFilter);
  }

  Future<void> _onApplyFilter(
    ApplyTransactionFilter event,
    Emitter<TransactionHistoryState> emit,
  ) async {
    final isLoadedOrLoading =
        state is TransactionHistoryLoaded || state is TransactionHistoryLoading;
    // Same filter and nothing to recover from — skip the redundant call.
    if (event.filter == _filter && isLoadedOrLoading) return;
    _filter = event.filter;
    await _loadFirstPage(emit);
  }

  Future<void> _onFetchTransactions(
    FetchTransactions event,
    Emitter<TransactionHistoryState> emit,
  ) => _loadFirstPage(emit);

  Future<void> _loadFirstPage(Emitter<TransactionHistoryState> emit) async {
    final requestId = ++_requestId;
    final filter = _filter;
    try {
      emit(TransactionHistoryLoading(filter: filter));

      final result = await repository.getTransactions(
        page: 0,
        size: _pageSize,
        filter: filter,
      );
      if (requestId != _requestId) return;

      result.fold(
        (failure) => emit(
          TransactionHistoryError(message: failure.toString(), filter: filter),
        ),
        (page) => emit(
          TransactionHistoryLoaded(
            transactions: page.transactions,
            hasReachedMax: page.isLast,
            currentPage: 0,
            filter: filter,
          ),
        ),
      );
    } catch (e) {
      if (requestId != _requestId) return;
      emit(TransactionHistoryError(message: e.toString(), filter: filter));
    }
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<TransactionHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionHistoryLoaded ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore) {
      return;
    }

    final requestId = _requestId;
    try {
      final nextPage = currentState.currentPage + 1;
      emit(currentState.copyWith(isLoadingMore: true));

      final result = await repository.getTransactions(
        page: nextPage,
        size: _pageSize,
        filter: currentState.filter,
      );
      // A filter change started a new first-page request meanwhile.
      if (requestId != _requestId) return;

      result.fold(
        (failure) => emit(
          currentState.copyWith(
            isLoadingMore: false,
            paginationError: failure.toString(),
          ),
        ),
        (page) => emit(
          TransactionHistoryLoaded(
            transactions: [...currentState.transactions, ...page.transactions],
            hasReachedMax: page.isLast,
            isLoadingMore: false,
            currentPage: nextPage,
            filter: currentState.filter,
          ),
        ),
      );
    } catch (e) {
      if (requestId != _requestId) return;
      emit(
        currentState.copyWith(
          isLoadingMore: false,
          paginationError: e.toString(),
        ),
      );
    }
  }
}
