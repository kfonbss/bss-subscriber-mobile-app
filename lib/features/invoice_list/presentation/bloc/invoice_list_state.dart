import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/entity/invoice_entity.dart';

abstract class InvoiceListState extends Equatable {
  const InvoiceListState();

  @override
  List<Object?> get props => [];
}

class InvoiceListInitial extends InvoiceListState {
  const InvoiceListInitial();
}

/// State while first page is loading.
class InvoiceListLoading extends InvoiceListState {
  const InvoiceListLoading();
}

/// State when invoices are loaded (supports pagination).
class InvoiceListLoaded extends InvoiceListState {
  final List<InvoiceEntity> invoices;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final int currentPage;

  const InvoiceListLoaded({
    required this.invoices,
    required this.hasReachedMax,
    this.isLoadingMore = false,
    required this.currentPage,
  });

  InvoiceListLoaded copyWith({
    List<InvoiceEntity>? invoices,
    bool? hasReachedMax,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return InvoiceListLoaded(
      invoices: invoices ?? this.invoices,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    invoices,
    hasReachedMax,
    isLoadingMore,
    currentPage,
  ];
}

/// State when an error occurs.
class InvoiceListError extends InvoiceListState {
  final String message;

  const InvoiceListError({required this.message});

  @override
  List<Object?> get props => [message];
}
