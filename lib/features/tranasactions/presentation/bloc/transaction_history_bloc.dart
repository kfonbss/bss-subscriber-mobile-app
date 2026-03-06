import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/repository/transaction_repository.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/bloc/transaction_history_event.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/bloc/transaction_history_state.dart';

class TransactionHistoryBloc
    extends Bloc<TransactionHistoryEvent, TransactionHistoryState> {
  final TransactionRepository repository;

  static const int _pageSize = 10;

  TransactionHistoryBloc({required this.repository})
    : super(const TransactionHistoryInitial()) {
    on<FetchTransactions>(_onFetchTransactions);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
  }

  Future<void> _onFetchTransactions(
    FetchTransactions event,
    Emitter<TransactionHistoryState> emit,
  ) async {
    try {
      emit(const TransactionHistoryLoading());

      final result = await repository.getTransactions(page: 0, size: _pageSize);

      result.fold(
        (failure) => emit(TransactionHistoryError(message: failure.toString())),
        (page) => emit(
          TransactionHistoryLoaded(
            transactions: page.transactions,
            hasReachedMax: page.isLast,
            currentPage: 0,
          ),
        ),
      );
    } catch (e) {
      emit(TransactionHistoryError(message: e.toString()));
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

    try {
      final nextPage = currentState.currentPage + 1;
      emit(currentState.copyWith(isLoadingMore: true));

      final result = await repository.getTransactions(
        page: nextPage,
        size: _pageSize,
      );

      result.fold(
        (failure) => emit(currentState.copyWith(isLoadingMore: false)),
        (page) => emit(
          TransactionHistoryLoaded(
            transactions: [...currentState.transactions, ...page.transactions],
            hasReachedMax: page.isLast,
            isLoadingMore: false,
            currentPage: nextPage,
          ),
        ),
      );
    } catch (_) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}
