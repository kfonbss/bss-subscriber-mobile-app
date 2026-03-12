import 'package:equatable/equatable.dart';

abstract class InvoiceListEvent extends Equatable {
  const InvoiceListEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch the first page of invoices.
class FetchInvoices extends InvoiceListEvent {
  const FetchInvoices();
}

/// Event to load the next page of invoices.
class LoadMoreInvoices extends InvoiceListEvent {
  const LoadMoreInvoices();
}
