import 'package:kfon_subscriber/features/future_recharge/data/model/future_recharge_group_model.dart';
import 'package:kfon_subscriber/features/future_recharge/data/model/future_recharge_summary_model.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/entity/future_recharges_list_response_entity.dart';

class FutureRechargePageInfoModel {
  final int totalPages;
  final int totalElements;
  final int pageNumber;
  final int pageSize;
  final bool isFirst;
  final bool isLast;
  final bool isEmpty;

  const FutureRechargePageInfoModel({
    required this.totalPages,
    required this.totalElements,
    required this.pageNumber,
    required this.pageSize,
    required this.isFirst,
    required this.isLast,
    required this.isEmpty,
  });

  factory FutureRechargePageInfoModel.fromJson(Map<String, dynamic> json) {
    final pageable = json['pageable'] as Map<String, dynamic>? ?? {};
    final totalPages = json['totalPages'] as int? ?? 0;
    final totalElements = json['totalElements'] as int? ?? 0;
    final pageNumber =
        pageable['pageNumber'] as int? ??
        json['number'] as int? ??
        json['currentPage'] as int? ??
        0;
    final pageSize =
        pageable['pageSize'] as int? ??
        json['size'] as int? ??
        json['pageSize'] as int? ??
        0;
    final isFirst = json['first'] as bool? ?? pageNumber <= 0;
    final isLast =
        json['last'] as bool? ??
        (totalPages <= 0 ? true : pageNumber >= totalPages - 1);
    final contentOrGroups =
        (json['content'] as List<dynamic>?) ??
        (json['groups'] as List<dynamic>?) ??
        const [];
    final isEmpty =
        json['empty'] as bool? ??
        (totalElements == 0 ? true : contentOrGroups.isEmpty);

    return FutureRechargePageInfoModel(
      totalPages: totalPages,
      totalElements: totalElements,
      pageNumber: pageNumber,
      pageSize: pageSize,
      isFirst: isFirst,
      isLast: isLast,
      isEmpty: isEmpty,
    );
  }

  FutureRechargePageInfoEntity toEntity() {
    return FutureRechargePageInfoEntity(
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

class FutureRechargesListResponseModel {
  final FutureRechargeSummaryModel summary;
  final List<FutureRechargeGroupModel> groups;
  final FutureRechargePageInfoModel pageInfo;

  const FutureRechargesListResponseModel({
    required this.summary,
    required this.groups,
    required this.pageInfo,
  });

  factory FutureRechargesListResponseModel.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>? ?? json;
    final pageJson = dataJson['page'] as Map<String, dynamic>? ?? dataJson;
    final groupsJson =
        (pageJson['content'] as List<dynamic>?) ??
        (dataJson['groups'] as List<dynamic>?) ??
        (json['groups'] as List<dynamic>?) ??
        [];
    final summaryJson =
        (dataJson['summary'] as Map<String, dynamic>?) ??
        (json['summary'] as Map<String, dynamic>?) ??
        {};

    return FutureRechargesListResponseModel(
      summary: FutureRechargeSummaryModel.fromJson(summaryJson),
      groups: groupsJson
          .map((e) => FutureRechargeGroupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageInfo: FutureRechargePageInfoModel.fromJson(pageJson),
    );
  }

  FutureRechargesListResponseEntity toEntity() {
    return FutureRechargesListResponseEntity(
      summary: summary.toEntity(),
      groups: groups.map((e) => e.toEntity()).toList(),
      pageInfo: pageInfo.toEntity(),
    );
  }
}
