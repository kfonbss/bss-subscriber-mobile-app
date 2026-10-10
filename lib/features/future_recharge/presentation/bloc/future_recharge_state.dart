import 'package:kfon_subscriber/features/future_recharge/domain/entity/future_recharges_list_response_entity.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/params/get_future_recharges_list_params.dart';

sealed class FutureRechargeState {
  const FutureRechargeState();
}

class RechargeInitial extends FutureRechargeState {
  const RechargeInitial();
}

class RechargeLoading extends FutureRechargeState {
  final FutureRechargesListResponseEntity? previousData;
  final bool isTabChange;
  final int periodIndex; // 👈 add

  const RechargeLoading({
    this.previousData,
    this.isTabChange = false,
    this.periodIndex = 0, // 👈 add
  });
}

class RechargeLoaded extends FutureRechargeState {
  final FutureRechargesListResponseEntity data;
  final bool isLoadingMore;
  final RechargeTypeFilter rechargeType;
  final DateTime? selectedMonth;
  final int? selectedYear;
  final int periodIndex;

  const RechargeLoaded({
    required this.data,
    this.isLoadingMore = false,
    this.rechargeType = RechargeTypeFilter.all,
    this.selectedMonth,
    this.selectedYear,
    this.periodIndex = 0,
  });

  RechargeLoaded copyWith({
    FutureRechargesListResponseEntity? data,
    bool? isLoadingMore,
    RechargeTypeFilter? rechargeType,
    Object? selectedMonth = _unset,
    Object? selectedYear = _unset,
    int? periodIndex,
  }) => RechargeLoaded(
    data: data ?? this.data,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    rechargeType: rechargeType ?? this.rechargeType,
    selectedMonth:
        selectedMonth == _unset
            ? this.selectedMonth
            : selectedMonth as DateTime?,
    selectedYear:
        selectedYear == _unset ? this.selectedYear : selectedYear as int?,
    periodIndex: periodIndex ?? this.periodIndex,
  );
}

const _unset = Object();

class RechargeRefreshing extends FutureRechargeState {
  final FutureRechargesListResponseEntity currentData;
  const RechargeRefreshing({required this.currentData});
}

class RechargeError extends FutureRechargeState {
  final String errorMessage;
  final FutureRechargesListResponseEntity? previousData;

  const RechargeError({required this.errorMessage, this.previousData});
}
