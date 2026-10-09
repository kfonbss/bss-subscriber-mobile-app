import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/entity/future_recharge_group_entity.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/entity/future_recharge_item_entity.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/params/get_future_recharges_list_params.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/repository/future_recharge_repository.dart';
import 'package:kfon_subscriber/features/future_recharge/presentation/bloc/future_recharge_bloc.dart';
import 'package:kfon_subscriber/features/future_recharge/presentation/bloc/future_recharge_event.dart';
import 'package:kfon_subscriber/features/future_recharge/presentation/bloc/future_recharge_state.dart';
import 'package:kfon_subscriber/features/future_recharge/presentation/components/future_recharge_filter_sheet.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/shared/widgets/no_data_found.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';

class FutureRechargePage extends StatefulWidget {
  const FutureRechargePage({super.key});

  @override
  State<FutureRechargePage> createState() => _FutureRechargePageState();
}

class _FutureRechargePageState extends State<FutureRechargePage> {
  static const int _pageSize = 15;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FutureRechargeBloc _rechargeBloc = FutureRechargeBloc(
    rechargeRepository: sl<FutureRechargeRepository>(),
  );
  final DialogUtil _dialogUtil = DialogUtil();

  String? _lastSearchQuery;
  FutureRechargeState? _previousState;

  static const _monthNames = [
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

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _rechargeBloc.add(
      LoadRecharges(
        params: const GetFutureRechargesListParams(period: 'TODAY'),
        isFutureRecharge: true,
      ),
    );
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _rechargeBloc.close();
    super.dispose();
  }

  // ── Scroll ────────────────────────────────────────────────────────────────
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _rechargeBloc.add(const LoadMoreRecharges(isFutureRecharge: true));
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────
  void _onSearchChanged() {
    final q = _searchController.text.trim();
    if (q == _lastSearchQuery) return;
    _lastSearchQuery = q;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || _searchController.text.trim() != q) return;
      final loaded =
          _rechargeBloc.state is RechargeLoaded
              ? _rechargeBloc.state as RechargeLoaded
              : null;
      _rechargeBloc.add(
        LoadRecharges(
          params: GetFutureRechargesListParams(
            period: _periodFromIndex(loaded?.periodIndex ?? 0),
            page: 0,
            size: _pageSize,
            search: q.isEmpty ? null : q,
            rechargeType: loaded?.rechargeType ?? RechargeTypeFilter.all,
            month: loaded?.selectedMonth?.month,
            year: loaded?.selectedMonth?.year ?? loaded?.selectedYear,
          ),
          isFutureRecharge: true,
        ),
      );
    });
  }

  // ── Tab ───────────────────────────────────────────────────────────────────
  void _onTabChanged(int index) {
    _rechargeBloc.add(ChangePeriodTab(index: index, isFutureRecharge: true));
  }

  // ── Filter ────────────────────────────────────────────────────────────────
  void _showFilter(FutureRechargeState state) {
    final loaded = state is RechargeLoaded ? state : null;
    FutureRechargeFilterSheet.show(
      context,
      selectedType: loaded?.rechargeType ?? RechargeTypeFilter.all,
      selectedMonth: loaded?.selectedMonth,
      selectedYear: loaded?.selectedYear,
      onApply: ({required type, month, year}) {
        _rechargeBloc.add(
          ApplyRechargeFilter(
            rechargeType: type,
            selectedMonth: month,
            selectedYear: year,
            isFutureRecharge: true,
          ),
        );
      },
      onClear: () {
        _rechargeBloc.add(const ClearRechargeFilter(isFutureRecharge: true));
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static String _periodFromIndex(int index) {
    switch (index) {
      case 0:
        return 'TODAY';
      case 1:
        return 'THIS_WEEK';
      case 2:
        return 'THIS_MONTH';
      default:
        return 'TODAY';
    }
  }

  bool _hasActiveFilter(FutureRechargeState state) {
    if (state is! RechargeLoaded) return false;
    return state.rechargeType != RechargeTypeFilter.all ||
        state.selectedMonth != null ||
        state.selectedYear != null;
  }

  String _formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  String _formatCurrency(double amount) => '₹${amount.toStringAsFixed(0)}';

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return BlocListener<FutureRechargeBloc, FutureRechargeState>(
      bloc: _rechargeBloc,
      listenWhen: (previous, current) {
        _previousState = previous;
        return true;
      },
      listener: (context, state) {
        if (state is RechargeError) {
          _dialogUtil.showCustomSnackbar(
            context: context,
            content: state.errorMessage,
            isError: true,
          );
        }
      },
      child: BlocBuilder<FutureRechargeBloc, FutureRechargeState>(
        bloc: _rechargeBloc,
        builder: (context, state) {
          // ── Extract data from state ──────────────────
          int total = 0;
          int wallet = 0;
          int direct = 0;
          List<FutureRechargeGroupEntity> groups = [];
          bool isLoadingMore = false;
          int totalElements = 0;
          RechargeTypeFilter rechargeType = RechargeTypeFilter.all;
          DateTime? selectedMonth;
          int? selectedYear;
          int periodIndex = 0;

          if (state is RechargeLoaded) {
            total = state.data.summary.total;
            wallet = state.data.summary.wallet;
            direct = state.data.summary.direct;
            groups = state.data.groups;
            isLoadingMore = state.isLoadingMore;
            totalElements = state.data.pageInfo.totalElements;
            rechargeType = state.rechargeType;
            selectedMonth = state.selectedMonth;
            selectedYear = state.selectedYear;
            periodIndex = state.periodIndex;
          } else if (state is RechargeLoading) {
            // 👇 read periodIndex immediately so tab highlights at once
            periodIndex = state.periodIndex;
            if (state.previousData != null) {
              total = state.previousData!.summary.total;
              wallet = state.previousData!.summary.wallet;
              direct = state.previousData!.summary.direct;
              groups = state.previousData!.groups;
              totalElements = state.previousData!.pageInfo.totalElements;
            }
          } else if (state is RechargeRefreshing) {
            final data = state.currentData;
            total = data.summary.total;
            wallet = data.summary.wallet;
            direct = data.summary.direct;
            groups = data.groups;
            totalElements = data.pageInfo.totalElements;
          } else if (state is RechargeError && state.previousData != null) {
            total = state.previousData!.summary.total;
            wallet = state.previousData!.summary.wallet;
            direct = state.previousData!.summary.direct;
            groups = state.previousData!.groups;
            totalElements = state.previousData!.pageInfo.totalElements;
          }

          final hasFilter = _hasActiveFilter(state);

          // 👇 shimmer conditions
          final isInitialLoading =
              state is RechargeLoading && state.previousData == null;
          final isTabChangeLoading =
              state is RechargeLoading && state.isTabChange;
          final showShimmer = isInitialLoading || isTabChangeLoading;

          return CommonAppBar(
            onBackPressed: () => Navigator.pop(context),
            title: l10n.futureRecharges,
            actions: [
              // ── Filter icon ─────────────────────────
              Stack(
                children: [
                  InkWell(
                    onTap: () => _showFilter(state),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            hasFilter
                                ? AppColor.kSecondaryColor.withValues(
                                  alpha: 0.1,
                                )
                                : Colors.transparent,
                        border: Border.all(
                          color:
                              hasFilter
                                  ? AppColor.kSecondaryColor
                                  : AppColor.kShimmerBase,
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 20.sp,
                        color:
                            hasFilter
                                ? AppColor.kSecondaryColor
                                : AppColor.kTextSecondary,
                      ),
                    ),
                  ),
                  if (hasFilter)
                    Positioned(
                      top: 2.h,
                      right: 2.w,
                      child: Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.kSecondaryColor,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 16.w),
            ],
            body: RefreshIndicator(
              onRefresh: () async {
                final loaded = state is RechargeLoaded ? state : null;
                _rechargeBloc.add(
                  RefreshRecharges(
                    params: GetFutureRechargesListParams(
                      period: _periodFromIndex(loaded?.periodIndex ?? 0),
                      page: 0,
                      size: _pageSize,
                      search:
                          _searchController.text.trim().isEmpty
                              ? null
                              : _searchController.text.trim(),
                      rechargeType:
                          loaded?.rechargeType ?? RechargeTypeFilter.all,
                      month: loaded?.selectedMonth?.month,
                      year: loaded?.selectedMonth?.year ?? loaded?.selectedYear,
                    ),
                    isFutureRecharge: true,
                  ),
                );
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Summary cards ────────────────
                          Container(
                            height: 122.h,
                            padding: EdgeInsets.all(16.w),
                            decoration: const ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildSummaryCard(
                                  AppColor.kSecondaryColor,
                                  l10n.total,
                                  total,
                                ),
                                SizedBox(width: 17.w),
                                _buildSummaryCard(
                                  AppColor.kCoralRed,
                                  context.bssSubL10n.offline,
                                  wallet,
                                ),
                                SizedBox(width: 17.w),
                                _buildSummaryCard(
                                  AppColor.kTealAccent,
                                  context.bssSubL10n.online,
                                  direct,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // ── Active filter chips ──────────
                          if (hasFilter) ...[
                            _buildActiveFilterChips(
                              rechargeType: rechargeType,
                              selectedMonth: selectedMonth,
                              selectedYear: selectedYear,
                            ),
                            SizedBox(height: 12.h),
                          ],

                          // ── Search bar ───────────────────
                          Container(
                            height: 51.h,
                            decoration: const ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: l10n.search,
                                hintStyle: TextStyle(
                                  color: AppColor.kTextSecondaryLight,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: AppColor.kTextSecondaryLight,
                                  size: 24,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 16.h,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // ── Period tabs ──────────────────
                          if (!hasFilter)
                            Container(
                              height: 48.h,
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  _buildTab(l10n.today, 0, periodIndex),
                                  _buildTab(l10n.thisWeek, 1, periodIndex),
                                  _buildTab(l10n.thisMonth, 2, periodIndex),
                                ],
                              ),
                            ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),

                  // ── Content ──────────────────────────────
                  if (showShimmer)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: ListShimmer(itemCount: 4, itemHeight: 140),
                      ),
                    )
                  else if (groups.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.only(
                        left: 20.w,
                        right: 20.w,
                        bottom: 100.h,
                      ),
                      sliver:
                          periodIndex == 1 && !hasFilter
                              ? _buildGroupedSliver(
                                groups,
                                isLoadingMore: isLoadingMore,
                              )
                              : _buildFlatSliver(
                                groups,
                                isLoadingMore: isLoadingMore,
                                totalElements: totalElements,
                              ),
                    )
                  else if (!showShimmer)
                    SliverToBoxAdapter(
                      child: NoDataFound(
                        errorMessage: context.bssSubL10n.noDataFound,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Active filter chips ───────────────────────────────────────────────────
  Widget _buildActiveFilterChips({
    required RechargeTypeFilter rechargeType,
    required DateTime? selectedMonth,
    required int? selectedYear,
  }) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 6.h,
      children: [
        if (rechargeType != RechargeTypeFilter.all)
          _filterChip(
            label:
                rechargeType == RechargeTypeFilter.online
                    ? context.bssSubL10n.online
                    : context.bssSubL10n.offline,
            onRemove:
                () => _rechargeBloc.add(
                  ApplyRechargeFilter(
                    rechargeType: RechargeTypeFilter.all,
                    selectedMonth: selectedMonth,
                    selectedYear: selectedYear,
                    isFutureRecharge: true,
                  ),
                ),
          ),
        if (selectedMonth != null)
          _filterChip(
            label:
                '${_monthNames[selectedMonth.month - 1]} ${selectedMonth.year}',
            onRemove:
                () => _rechargeBloc.add(
                  ApplyRechargeFilter(
                    rechargeType: rechargeType,
                    selectedMonth: null,
                    selectedYear: null,
                    isFutureRecharge: true,
                  ),
                ),
          ),
        if (selectedYear != null)
          _filterChip(
            label: '$selectedYear',
            onRemove:
                () => _rechargeBloc.add(
                  ApplyRechargeFilter(
                    rechargeType: rechargeType,
                    selectedMonth: null,
                    selectedYear: null,
                    isFutureRecharge: true,
                  ),
                ),
          ),
      ],
    );
  }

  Widget _filterChip({required String label, required VoidCallback onRemove}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColor.kSecondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColor.kSecondaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.kSecondaryColor,
              fontFamily: 'GeneralSans',
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14.sp,
              color: AppColor.kSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Period tab ────────────────────────────────────────────────────────────
  Widget _buildTab(String label, int index, int selectedIndex) {
    final selected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color:
                    selected
                        ? AppColor.kNearBlack
                        : AppColor.kTabBarUnselectedText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Summary card ──────────────────────────────────────────────────────────
  Widget _buildSummaryCard(Color color, String label, int data) {
    return Expanded(
      child: Container(
        height: 90.h,
        padding: EdgeInsets.all(16.w),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$data',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Grouped sliver ────────────────────────────────────────────────────────
  Widget _buildGroupedSliver(
    List<FutureRechargeGroupEntity> groups, {
    required bool isLoadingMore,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, groupIndex) {
        if (groupIndex == groups.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Center(
              child: SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final group = groups[groupIndex];
        final l10n = context.bssSubL10n;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(group.date),
                    style: TextStyle(
                      color: AppColor.kTextSecondaryDark,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.30,
                    ),
                  ),
                  Text(
                    l10n.rechargeCount(group.count),
                    style: TextStyle(
                      color: AppColor.kTextSecondaryDark,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.30,
                    ),
                  ),
                ],
              ),
            ),
            ...group.recharges.map((r) => _buildRechargeCard(r)),
            if (groupIndex < groups.length - 1) SizedBox(height: 24.h),
          ],
        );
      }, childCount: groups.length + (isLoadingMore ? 1 : 0)),
    );
  }

  // ── Flat sliver ───────────────────────────────────────────────────────────
  Widget _buildFlatSliver(
    List<FutureRechargeGroupEntity> groups, {
    required bool isLoadingMore,
    required int totalElements,
  }) {
    if (groups.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final allRecharges = groups.expand((g) => g.recharges).toList();
    final loadedCount = groups.fold<int>(0, (s, g) => s + g.count);
    final displayCount = totalElements > 0 ? totalElements : loadedCount;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          final l10n = context.bssSubL10n;
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                l10n.rechargeCount(displayCount),
                style: TextStyle(
                  color: AppColor.kTextSecondaryDark,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.30,
                ),
              ),
            ),
          );
        }
        if (isLoadingMore && index == allRecharges.length + 1) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Center(
              child: SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return _buildRechargeCard(allRecharges[index - 1]);
      }, childCount: allRecharges.length + 1 + (isLoadingMore ? 1 : 0)),
    );
  }

  // ── Recharge card ─────────────────────────────────────────────────────────
  Widget _buildRechargeCard(FutureRechargeItemEntity recharge) {
    final rechargeTypeColor =
        recharge.rechargeMode.toLowerCase() == 'online'
            ? AppColor.kTealAccent
            : AppColor.kCoralRed;

    return Builder(
      builder: (context) {
        final l10n = context.bssSubL10n;
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // ── Top row ────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipOval(
                          child: Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: const BoxDecoration(
                              color: AppColor.kSecondaryBackgroundColor,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppColor.kHintGrey,
                              size: 24,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recharge.subscriberName,
                              style: TextStyle(
                                color: AppColor.kTextSecondaryDark,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                height: 1.30,
                              ),
                            ),
                            Text(
                              recharge.username,
                              style: TextStyle(
                                color: AppColor.kHintGrey,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                height: 1.30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 20.h,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: rechargeTypeColor,
                            borderRadius: BorderRadius.circular(24.5),
                          ),
                          child: Center(
                            child: Text(
                              recharge.rechargeMode,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                height: 1.30,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          recharge.planName,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppColor.kTextSecondaryDark,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.30,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // ── Plan details ───────────────────────
                Container(
                  decoration: const ShapeDecoration(
                    color: AppColor.kSecondaryBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPlanDetail(
                          l10n.amount,
                          _formatCurrency(recharge.amount),
                        ),
                        _buildPlanDetail(l10n.speed, recharge.speed),
                        _buildPlanDetail(
                          l10n.date,
                          _formatDate(recharge.orderTime),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Plan detail ───────────────────────────────────────────────────────────
  Widget _buildPlanDetail(String heading, String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(
            color: AppColor.kTextSecondary,
            fontSize: 8.sp,
            fontWeight: FontWeight.w400,
            height: 1.30,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          data,
          style: TextStyle(
            color: AppColor.kTextSecondaryDark,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            height: 1.30,
          ),
        ),
      ],
    );
  }
}
