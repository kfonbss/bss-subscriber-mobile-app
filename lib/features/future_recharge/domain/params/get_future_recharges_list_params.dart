// get_future_recharges_list_params.dart

// 👇 recharge type filter enum
enum RechargeTypeFilter { all, online, offline }

class GetFutureRechargesListParams {
  final String period;
  final String? search;
  final int page;
  final int size;
  final RechargeTypeFilter rechargeType;
  final int? month;
  final int? year;

  const GetFutureRechargesListParams({
    required this.period,
    this.search,
    this.page = 0,
    this.size = 15,
    this.rechargeType = RechargeTypeFilter.all,
    this.month,
    this.year,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {
      'period': period,
      'page': page,
      'size': size,
    };
    if (search != null && search!.isNotEmpty) {
      params['search'] = search;
    }
    if (rechargeType != RechargeTypeFilter.all) {
      params['rechargeMode'] = rechargeType.name.toUpperCase();
    }
    if (month != null) params['month'] = month;
    if (year != null) params['year'] = year;
    return params;
  }

  GetFutureRechargesListParams copyWith({
    String? period,
    Object? search = _unset,
    int? page,
    int? size,
    RechargeTypeFilter? rechargeType,
    Object? month = _unset,
    Object? year = _unset,
  }) {
    return GetFutureRechargesListParams(
      period: period ?? this.period,
      search: search == _unset ? this.search : search as String?,
      page: page ?? this.page,
      size: size ?? this.size,
      rechargeType: rechargeType ?? this.rechargeType,
      month: month == _unset ? this.month : month as int?,
      year: year == _unset ? this.year : year as int?,
    );
  }
}

const _unset = Object();
