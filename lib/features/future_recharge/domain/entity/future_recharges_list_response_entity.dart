import 'package:kfon_subscriber/features/future_recharge/domain/entity/future_recharge_group_entity.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/entity/future_recharge_summary_entity.dart';

class FutureRechargePageInfoEntity {
  final int totalPages;
  final int totalElements;
  final int pageNumber;
  final int pageSize;
  final bool isFirst;
  final bool isLast;
  final bool isEmpty;

  const FutureRechargePageInfoEntity({
    required this.totalPages,
    required this.totalElements,
    required this.pageNumber,
    required this.pageSize,
    required this.isFirst,
    required this.isLast,
    required this.isEmpty,
  });

  const FutureRechargePageInfoEntity.initial()
    : totalPages = 0,
      totalElements = 0,
      pageNumber = 0,
      pageSize = 0,
      isFirst = true,
      isLast = true,
      isEmpty = true;
}

class FutureRechargesListResponseEntity {
  final FutureRechargeSummaryEntity summary;
  final List<FutureRechargeGroupEntity> groups;
  final FutureRechargePageInfoEntity pageInfo;

  const FutureRechargesListResponseEntity({
    required this.summary,
    required this.groups,
    required this.pageInfo,
  });
}
