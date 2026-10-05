import 'package:kfon_subscriber/features/future_recharge/domain/params/get_future_recharges_list_params.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/future_recharge/presentation/components/month_and_year_filter_sheet.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';

class FutureRechargeFilterSheet extends StatefulWidget {
  final RechargeTypeFilter selectedType;
  final DateTime? selectedMonth;
  final int? selectedYear;
  final void Function({
    required RechargeTypeFilter type,
    DateTime? month,
    int? year,
  })
  onApply;
  final void Function() onClear;

  const FutureRechargeFilterSheet({
    super.key,
    required this.onApply,
    required this.onClear,
    this.selectedType = RechargeTypeFilter.all,
    this.selectedMonth,
    this.selectedYear,
  });

  static Future<void> show(
    BuildContext context, {
    RechargeTypeFilter selectedType = RechargeTypeFilter.all,
    DateTime? selectedMonth,
    int? selectedYear,
    required void Function({
      required RechargeTypeFilter type,
      DateTime? month,
      int? year,
    })
    onApply,
    required void Function() onClear,
  }) {
    // The sheet scrolls itself, so the common wrapper's scroll view is off;
    // that keeps the content's height bounded by the sheet.
    return showAppModalBottomSheet<void>(
      context: context,
      useSafeAreaScroll: false,
      builder:
          (_) => FutureRechargeFilterSheet(
            selectedType: selectedType,
            selectedMonth: selectedMonth,
            selectedYear: selectedYear,
            onApply: onApply,
            onClear: onClear,
          ),
    );
  }

  @override
  State<FutureRechargeFilterSheet> createState() =>
      _FutureRechargeFilterSheetState();
}

class _FutureRechargeFilterSheetState extends State<FutureRechargeFilterSheet> {
  late RechargeTypeFilter _selectedType;
  DateTime? _selectedMonth;
  int? _selectedYear;

  // month/year tab
  FilterType _dateTab = FilterType.month;
  int _curYear = DateTime.now().year;
  int _decadeStart = (DateTime.now().year ~/ 10) * 10;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedMonth = widget.selectedMonth;
    _selectedYear = widget.selectedYear;
    if (_selectedYear != null && _selectedMonth == null) {
      _dateTab = FilterType.year;
    }
    if (_selectedMonth != null) _curYear = _selectedMonth!.year;
  }

  String get _dateLabel {
    if (_dateTab == FilterType.month && _selectedMonth != null) {
      return '${_months[_selectedMonth!.month - 1]} ${_selectedMonth!.year}';
    } else if (_dateTab == FilterType.year && _selectedYear != null) {
      return '$_selectedYear';
    }
    return '—';
  }

  void _switchDateTab(FilterType t) {
    setState(() {
      _dateTab = t;
      if (t == FilterType.month) {
        _selectedYear = null;
      } else {
        _selectedMonth = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Background, top radius, drag handle and bottom safe area come from
    // showAppModalBottomSheet.
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + clear ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.bssSubL10n.filter,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.kBottomSheetTitle,
                  fontFamily: 'GeneralSans',
                ),
              ),
              TextButton(
                onPressed:
                    () => setState(() {
                      _selectedType = RechargeTypeFilter.all;
                      _selectedMonth = null;
                      _selectedYear = null;
                      widget.onClear();
                    }),
                child: Text(
                  context.bssSubL10n.clearAll,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColor.kClearAllColor,
                    fontFamily: 'GeneralSans',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // ── Recharge type ────────────────────────────────────────────────
          Text(
            context.bssSubL10n.rechargeType,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.kTextSecondaryDark,
              fontFamily: 'GeneralSans',
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children:
                RechargeTypeFilter.values.map((type) {
                  final isSelected = _selectedType == type;
                  final label =
                      type == RechargeTypeFilter.all
                          ? context.bssSubL10n.all
                          : type == RechargeTypeFilter.online
                          ? context.bssSubL10n.online
                          : context.bssSubL10n.offline;
                  return Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColor.kIconBackground
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColor.kPrimaryColor
                                    : AppColor.kShimmerBase,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color:
                                isSelected
                                    ? AppColor.kPrimaryColor
                                    : AppColor.kTextSecondary,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          SizedBox(height: 24.h),

          // ── Date filter ──────────────────────────────────────────────────
          Text(
            context.bssSubL10n.filterByDate,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.kTextSecondaryDark,
              fontFamily: 'GeneralSans',
            ),
          ),
          SizedBox(height: 12.h),

          // date tabs
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColor.kSecondaryBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children:
                  FilterType.values.map((t) {
                    final active = _dateTab == t;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _switchDateTab(t),
                        child: Container(
                          height: 34.h,
                          decoration: BoxDecoration(
                            color:
                                active
                                    ? AppColor.kTabActiveBackground
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                active
                                    ? Border.all(
                                      color: AppColor.kTabActiveBackground,
                                    )
                                    : null,
                          ),
                          child: Center(
                            child: Text(
                              t == FilterType.month
                                  ? context.bssSubL10n.monthly
                                  : context.bssSubL10n.yearly,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight:
                                    active ? FontWeight.w500 : FontWeight.w400,
                                color:
                                    active
                                        ? AppColor.kTextSecondaryDark
                                        : AppColor.kTextSecondary,
                                fontFamily: 'GeneralSans',
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          SizedBox(height: 16.h),

          // date content
          if (_dateTab == FilterType.month)
            _buildMonthView()
          else
            _buildYearView(),

          SizedBox(height: 24.h),

          // ── Footer ───────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.bssSubL10n.dateSelected,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColor.kTextSecondary,
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                  Text(
                    _dateLabel,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.kPrimaryColor,
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.kPrimaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: Size(120.w, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onApply(
                    type: _selectedType,
                    month: _dateTab == FilterType.month ? _selectedMonth : null,
                    year: _dateTab == FilterType.year ? _selectedYear : null,
                  );
                },
                child: Text(
                  context.bssSubL10n.apply,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'GeneralSans',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Month view ─────────────────────────────────────────────────────────────
  Widget _buildMonthView() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  _curYear > 2000 ? () => setState(() => _curYear--) : null,
            ),
            Text(
              '$_curYear',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'GeneralSans',
                color: AppColor.kTextSecondaryDark,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed:
                  _curYear < DateTime.now().year
                      ? () => setState(() => _curYear++)
                      : null,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: 12,
          itemBuilder: (_, i) {
            final now = DateTime.now();
            final isFuture = _curYear == now.year && i >= now.month;
            final isSelected =
                _selectedMonth != null &&
                _selectedMonth!.year == _curYear &&
                _selectedMonth!.month == i + 1;
            return GestureDetector(
              onTap:
                  isFuture
                      ? null
                      : () => setState(
                        () => _selectedMonth = DateTime(_curYear, i + 1),
                      ),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.kIconBackground : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColor.kPrimaryColor
                            : AppColor.kShimmerBase,
                  ),
                ),
                child: Center(
                  child: Text(
                    _months[i],
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isFuture
                              ? AppColor.kDisabledGrey
                              : isSelected
                              ? AppColor.kPrimaryColor
                              : AppColor.kTextSecondaryDark,
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Year view ──────────────────────────────────────────────────────────────
  Widget _buildYearView() {
    final maxDecade = (DateTime.now().year ~/ 10) * 10;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  _decadeStart > 2000
                      ? () => setState(() => _decadeStart -= 10)
                      : null,
            ),
            Text(
              '$_decadeStart – ${_decadeStart + 9}',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'GeneralSans',
                color: AppColor.kTextSecondaryDark,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed:
                  _decadeStart < maxDecade
                      ? () => setState(() => _decadeStart += 10)
                      : null,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: 10,
          itemBuilder: (_, i) {
            final y = _decadeStart + i;
            final isFuture = y > DateTime.now().year;
            final isSelected = _selectedYear == y;
            return GestureDetector(
              onTap: isFuture ? null : () => setState(() => _selectedYear = y),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.kIconBackground : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColor.kPrimaryColor
                            : AppColor.kShimmerBase,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$y',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isFuture
                              ? AppColor.kDisabledGrey
                              : isSelected
                              ? AppColor.kPrimaryColor
                              : AppColor.kTextSecondaryDark,
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
