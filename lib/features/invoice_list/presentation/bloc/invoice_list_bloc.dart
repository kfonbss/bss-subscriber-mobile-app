import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/repository/invoice_repository.dart';
import 'package:kfon_subscriber/features/invoice_list/presentation/bloc/invoice_list_event.dart';
import 'package:kfon_subscriber/features/invoice_list/presentation/bloc/invoice_list_state.dart';

class InvoiceListBloc extends Bloc<InvoiceListEvent, InvoiceListState> {
  final InvoiceRepository repository;

  static const int _pageSize = 10;

  InvoiceListBloc({required this.repository})
    : super(const InvoiceListInitial()) {
    on<FetchInvoices>(_onFetchInvoices);
    on<LoadMoreInvoices>(_onLoadMoreInvoices);
  }

  Future<void> _onFetchInvoices(
    FetchInvoices event,
    Emitter<InvoiceListState> emit,
  ) async {
    try {
      emit(const InvoiceListLoading());

      final result = await repository.getInvoices(page: 0, size: _pageSize);

      result.fold(
        (failure) => emit(InvoiceListError(message: failure.toString())),
        (page) => emit(
          InvoiceListLoaded(
            invoices: page.invoices,
            hasReachedMax: page.isLast,
            currentPage: 0,
          ),
        ),
      );
    } catch (e) {
      emit(InvoiceListError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreInvoices(
    LoadMoreInvoices event,
    Emitter<InvoiceListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! InvoiceListLoaded ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore) {
      return;
    }

    try {
      final nextPage = currentState.currentPage + 1;
      emit(currentState.copyWith(isLoadingMore: true));

      final result = await repository.getInvoices(
        page: nextPage,
        size: _pageSize,
      );

      result.fold(
        (failure) => emit(currentState.copyWith(isLoadingMore: false)),
        (page) => emit(
          InvoiceListLoaded(
            invoices: [...currentState.invoices, ...page.invoices],
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
