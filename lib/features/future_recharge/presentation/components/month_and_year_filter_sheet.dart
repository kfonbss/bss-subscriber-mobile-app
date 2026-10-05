import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

enum FilterType { month, year }

class MonthAndYearFilterSheet extends StatefulWidget {
  final DateTime?                                 selectedMonth;
  final int?                                      selectedYear;
  final void Function(DateTime? month, int? year) onApply;
  final void Function() onClear;

  const MonthAndYearFilterSheet({
    super.key,
    required this.onApply,
    required this.onClear,
    this.selectedMonth,
    this.selectedYear,
  });

  static Future<void> show(
      BuildContext context, {
        DateTime?                                       selectedMonth,
        int?                                            selectedYear,
        required void Function(DateTime? month, int? year) onApply,
        required void Function() onClear,
      }) {
    return showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => MonthAndYearFilterSheet(
        selectedMonth: selectedMonth,
        selectedYear:  selectedYear,
        onApply:       onApply,
        onClear:       onClear,
      ),
    );
  }

  @override
  State<MonthAndYearFilterSheet> createState() => _MonthAndYearFilterSheetState();
}

class _MonthAndYearFilterSheetState extends State<MonthAndYearFilterSheet> {
  FilterType _tab         = FilterType.month;
  int        _curYear     = DateTime.now().year;
  int        _decadeStart = (DateTime.now().year ~/ 10) * 10;
  DateTime?  _selectedMonth;
  int?       _selectedYear;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.selectedMonth;
    _selectedYear  = widget.selectedYear;
    // set initial tab based on which is active
    if (_selectedYear != null && _selectedMonth == null) {
      _tab = FilterType.year;
    }
    if (_selectedMonth != null) _curYear = _selectedMonth!.year;
  }

  String get _selectionLabel {
    if (_tab == FilterType.month && _selectedMonth != null) {
      return '${_months[_selectedMonth!.month - 1]} ${_selectedMonth!.year}';
    } else if (_tab == FilterType.year && _selectedYear != null) {
      return '$_selectedYear';
    }
    return '—';
  }

  void _switchTab(FilterType t) {
    setState(() {
      _tab = t;
      if (t == FilterType.month) {
        _selectedYear = null;
      } else {
        _selectedMonth = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, bottomPad + 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ───────────────────────────────────────────────────
          Container(
            width:  42.w,
            height: 4.h,
            decoration: BoxDecoration(
              color:        AppColor.kDividerGrey,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Title ─────────────────────────────────────────────────────────
          Text(
            context.bssSubL10n.filterByDate,
            style: TextStyle(
              fontSize:   18.sp,
              fontWeight: FontWeight.w600,
              color:      AppColor.kBottomSheetTitle,
              fontFamily: 'GeneralSans',
            ),
          ),
          SizedBox(height: 20.h),

          // ── Tabs ──────────────────────────────────────────────────────────
          Container(
            padding:    EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color:        AppColor.kSecondaryBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: FilterType.values.map((t) {
                final active = _tab == t;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _switchTab(t),
                    child: Container(
                      height: 36.h,
                      decoration: BoxDecoration(
                        color:        active ? AppColor.kDaysLeftYellow : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: active
                            ? Border.all(color: AppColor.kShimmerBase)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          t == FilterType.month ? context.bssSubL10n.monthly : context.bssSubL10n.yearly,
                          style: TextStyle(
                            fontSize:   14.sp,
                            fontWeight: active
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: active
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
          SizedBox(height: 20.h),

          // ── Content ───────────────────────────────────────────────────────
          if (_tab == FilterType.month)
            _buildMonthView()
          else
            _buildYearView(),

          SizedBox(height: 20.h),

          // ── Footer ────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // selected label
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.bssSubL10n.selected,
                    style: TextStyle(
                      fontSize:   12.sp,
                      color:      AppColor.kTextSecondary,
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                  Text(
                    _selectionLabel,
                    style: TextStyle(
                      fontSize:   14.sp,
                      fontWeight: FontWeight.w600,
                      color:      AppColor.kPrimaryColor,
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                ],
              ),

              // buttons
              Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side:  BorderSide(color: AppColor.kPrimaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => setState(() {
                      _selectedMonth = null;
                      _selectedYear  = null;
                      widget.onClear();
                    }),
                    child: Text(
                      context.bssSubL10n.clear,
                      style: TextStyle(
                        fontSize:   13.sp,
                        color:      AppColor.kPrimaryColor,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.kPrimaryColor,
                      foregroundColor: Colors.white,
                      elevation:       0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // 👇 only pass active tab's value — never both
                      widget.onApply(
                        _tab == FilterType.month ? _selectedMonth : null,
                        _tab == FilterType.year  ? _selectedYear  : null,
                      );
                    },
                    child: Text(
                      context.bssSubL10n.apply,
                      style: TextStyle(
                        fontSize:   13.sp,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ),
                ],
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
        // year navigator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon:      const Icon(Icons.chevron_left),
              onPressed: _curYear > 2000
                  ? () => setState(() => _curYear--)
                  : null,
            ),
            Text(
              '$_curYear',
              style: TextStyle(
                fontSize:   16.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'GeneralSans',
                color:      AppColor.kTextSecondaryDark,
              ),
            ),
            IconButton(
              icon:      const Icon(Icons.chevron_right),
              onPressed: _curYear < DateTime.now().year
                  ? () => setState(() => _curYear++)
                  : null,
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // month grid
        GridView.builder(
          shrinkWrap: true,
          physics:    const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:   4,
            mainAxisSpacing:  8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: 12,
          itemBuilder: (_, i) {
            final now      = DateTime.now();
            final isFuture = _curYear == now.year && i >= now.month;
            final isSelected = _selectedMonth != null &&
                _selectedMonth!.year  == _curYear &&
                _selectedMonth!.month == i + 1;
            return GestureDetector(
              onTap: isFuture
                  ? null
                  : () => setState(
                    () => _selectedMonth = DateTime(_curYear, i + 1),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColor.kSecondaryColor.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColor.kSecondaryColor
                        : AppColor.kShimmerBase,
                  ),
                ),
                child: Center(
                  child: Text(
                    _months[i],
                    style: TextStyle(
                      fontSize:   13.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isFuture
                          ? AppColor.kDisabledGrey
                          : isSelected
                          ? AppColor.kSecondaryColor
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
        // decade navigator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon:      const Icon(Icons.chevron_left),
              onPressed: _decadeStart > 2000
                  ? () => setState(() => _decadeStart -= 10)
                  : null,
            ),
            Text(
              '$_decadeStart – ${_decadeStart + 9}',
              style: TextStyle(
                fontSize:   16.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'GeneralSans',
                color:      AppColor.kTextSecondaryDark,
              ),
            ),
            IconButton(
              icon:      const Icon(Icons.chevron_right),
              onPressed: _decadeStart < maxDecade
                  ? () => setState(() => _decadeStart += 10)
                  : null,
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // year grid
        GridView.builder(
          shrinkWrap: true,
          physics:    const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:   4,
            mainAxisSpacing:  8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: 10,
          itemBuilder: (_, i) {
            final y          = _decadeStart + i;
            final isFuture   = y > DateTime.now().year;
            final isSelected = _selectedYear == y;
            return GestureDetector(
              onTap: isFuture
                  ? null
                  : () => setState(() => _selectedYear = y),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColor.kSecondaryColor.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColor.kSecondaryColor
                        : AppColor.kShimmerBase,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$y',
                    style: TextStyle(
                      fontSize:   13.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isFuture
                          ? AppColor.kDisabledGrey
                          : isSelected
                          ? AppColor.kSecondaryColor
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