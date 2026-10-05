import 'package:kfon_subscriber/features/future_recharge/domain/params/get_future_recharges_list_params.dart';

sealed class FutureRechargeEvent {
  const FutureRechargeEvent();
}

class LoadRecharges extends FutureRechargeEvent {
  final GetFutureRechargesListParams params;
  final bool isFutureRecharge;

  const LoadRecharges({required this.params, required this.isFutureRecharge});
}

class RefreshRecharges extends FutureRechargeEvent {
  final GetFutureRechargesListParams params;
  final bool isFutureRecharge;

  const RefreshRecharges({
    required this.params,
    required this.isFutureRecharge,
  });
}

class LoadMoreRecharges extends FutureRechargeEvent {
  final bool isFutureRecharge;

  const LoadMoreRecharges({required this.isFutureRecharge});
}

// future_recharge_event.dart — add
class ApplyRechargeFilter extends FutureRechargeEvent {
  final RechargeTypeFilter rechargeType;
  final DateTime? selectedMonth;
  final int? selectedYear;
  final bool isFutureRecharge;

  const ApplyRechargeFilter({
    required this.rechargeType,
    this.selectedMonth,
    this.selectedYear,
    required this.isFutureRecharge,
  });
}

class ClearRechargeFilter extends FutureRechargeEvent {
  final bool isFutureRecharge;

  const ClearRechargeFilter({required this.isFutureRecharge});
}

class ChangePeriodTab extends FutureRechargeEvent {
  final int index;
  final bool isFutureRecharge;

  const ChangePeriodTab({required this.index, required this.isFutureRecharge});
}
