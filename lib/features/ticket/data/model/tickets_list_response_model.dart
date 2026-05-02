import 'package:kfon_subscriber/features/ticket/data/model/ticket.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/tickets_list_response_entity.dart';

/// Page info model for pagination
class PageInfoModel {
  final int totalPages;
  final int totalElements;
  final int pageNumber;
  final int pageSize;
  final bool isFirst;
  final bool isLast;
  final bool isEmpty;

  PageInfoModel({
    required this.totalPages,
    required this.totalElements,
    required this.pageNumber,
    required this.pageSize,
    required this.isFirst,
    required this.isLast,
    required this.isEmpty,
  });

  factory PageInfoModel.fromJson(Map<String, dynamic> json) {
    final pageable = json['pageable'] as Map<String, dynamic>? ?? {};
    return PageInfoModel(
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      pageNumber: pageable['pageNumber'] as int? ?? json['number'] as int? ?? 0,
      pageSize: pageable['pageSize'] as int? ?? json['size'] as int? ?? 0,
      isFirst: json['first'] as bool? ?? true,
      isLast: json['last'] as bool? ?? true,
      isEmpty: json['empty'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPages': totalPages,
      'totalElements': totalElements,
      'number': pageNumber,
      'size': pageSize,
      'first': isFirst,
      'last': isLast,
      'empty': isEmpty,
    };
  }

  PageInfoEntity toEntity() {
    return PageInfoEntity(
      totalPages: totalPages,
      totalElements: totalElements,
      pageNumber: pageNumber,
      pageSize: pageSize,
      isFirst: isFirst,
      isLast: isLast,
      isEmpty: isEmpty,
    );
  }
}

/// Main response model for tickets list
class TicketsListResponseModel {
  final PageInfoModel pageInfo;
  final List<Ticket> tickets;

  TicketsListResponseModel({
    required this.pageInfo,
    required this.tickets,
  });

  factory TicketsListResponseModel.fromJson(Map<String, dynamic> json) {
    // json is already the 'data' object from APIResponse
    final contentList = (json['content'] as List<dynamic>?) ?? [];

    return TicketsListResponseModel(
      pageInfo: PageInfoModel.fromJson(json),
      tickets: contentList
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        ...pageInfo.toJson(),
        'content': tickets.map((e) => e.toJson()).toList(),
      },
    };
  }

  TicketsListResponseEntity toEntity() {
    return TicketsListResponseEntity(
      pageInfo: pageInfo.toEntity(),
      tickets: tickets.map((e) => e.toEntity()).toList(),
    );
  }
}
