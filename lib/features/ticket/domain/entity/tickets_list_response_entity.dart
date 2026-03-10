import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_entity.dart';

/// Page info entity for pagination
class PageInfoEntity {
  final int totalPages;
  final int totalElements;
  final int pageNumber;
  final int pageSize;
  final bool isFirst;
  final bool isLast;
  final bool isEmpty;

  const PageInfoEntity({
    required this.totalPages,
    required this.totalElements,
    required this.pageNumber,
    required this.pageSize,
    required this.isFirst,
    required this.isLast,
    required this.isEmpty,
  });
}

/// Main response entity for tickets list
class TicketsListResponseEntity {
  final PageInfoEntity pageInfo;
  final List<TicketEntity> tickets;

  const TicketsListResponseEntity({
    required this.pageInfo,
    required this.tickets,
  });
}
