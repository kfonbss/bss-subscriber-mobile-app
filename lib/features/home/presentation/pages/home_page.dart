import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/features/autopay/presentation/pages/autopay_page.dart';
import 'package:kfon_subscriber/features/notfication/presentation/widgets/notification_bell_button.dart';
import 'package:kfon_subscriber/shared/widgets/common_text_button.dart';
import 'package:kfon_subscriber/shared/widgets/retry_widget.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/constant/constant_dimensions.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/entity/active_packages_details_entity.dart';
import 'package:kfon_subscriber/features/active_package_details/presentation/pages/active_package_page.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/recharge_page.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/seasonal_plan.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/pages/data_usage_view.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/pages/restart_modem_page.dart';
import 'package:kfon_subscriber/features/home/domain/entity/home_entity.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_bloc.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_event.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_state.dart';
import 'package:kfon_subscriber/features/home/presentation/components/home_shimmer.dart';
import 'package:kfon_subscriber/features/self_care/presentation/pages/speed_test_page.dart';
import 'package:kfon_subscriber/features/ticket/presentation/pages/tickets_page.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';
import 'package:kfon_subscriber/service_locator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc bloc;
  final DialogUtil _dialogUtil = DialogUtil();

  @override
  void initState() {
    super.initState();
    bloc = context.read<HomeBloc>();
    bloc.add(const GetHomeData(loadPackage: true));
  }

  void _showRechargeSheet(
    BuildContext context,
    PackageInfoEntity packageEntity,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (_) => BlocProvider(
              create:
                  (_) => DiscountBloc(repository: sl<ChangePlanRepository>()),
              child: RechargePage(package: packageEntity, isChangePlan: false),
            ),
      ),
    );
  }

  /// Pull-to-refresh: reloads the same data as the initial load and keeps the
  /// spinner until it finishes. The current content stays on screen (the
  /// builder ignores [HomeLoading]).
  Future<void> _onRefresh() {
    final done = bloc.stream.firstWhere(
      (s) => s is GetDataSuccess || s is GetDataFailure,
    );
    bloc.add(const GetHomeData(loadPackage: true));
    return done;
  }

  double get _statusBarHeight => MediaQuery.paddingOf(context).top;

  // Design (44 status bar): blue header is 272 tall; the expanded bar covers
  // the first 198. Measured from the status bar so both header pieces meet
  // exactly on any device.
  double get _headerHeight => _statusBarHeight + 228.h;

  double get _barHeight => _statusBarHeight + 154.h;

  /// Full blue header: brand colour with the two white rings. Both header
  /// pieces (bar and body) draw this and show their own slice of it.
  Widget _headerBackground() {
    // Design: left ring 185×215 at (0, 98); right ring 87×148 at the right
    // edge, y=100 (54 / 56 below the status bar). Sizes use .w so the rings
    // keep their shape.
    return SizedBox(
      width: double.infinity,
      height: _headerHeight,
      child: ColoredBox(
        color: AppColor.kPrimaryColor,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: _statusBarHeight + 54.h,
              child: Image.asset(
                AppAssets.homeLeftEllipse,
                width: 185.w,
                height: 215.w,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              right: 0,
              top: _statusBarHeight + 56.h,
              child: Image.asset(
                AppAssets.homeRightEllipse,
                width: 87.w,
                height: 148.w,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Collapsing toolbar. [flexibleSpace] is the expanded header (background +
  /// wallet card); without it the bar is just the plain pinned toolbar.
  SliverAppBar _buildSliverAppBar(
    BuildContext context, {
    Widget? flexibleSpace,
  }) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColor.kPrimaryColor,
      surfaceTintColor: Colors.transparent,
      // Design: logo and avatar centred at y=82 (38 below the status bar).
      toolbarHeight: 76.h,
      // Design: header content ends at y=198 (card top); status bar is 44.
      expandedHeight: flexibleSpace == null ? null : 154.h,
      // Grow with the iOS pull-down bounce so the bar stays joined to the
      // rest of the header in the body (otherwise a gap opens between them).
      stretch: flexibleSpace != null,
      flexibleSpace: flexibleSpace,
      // Design: logo at x=20; the 48 avatar ends 17 from the right edge.
      titleSpacing: 20.w,
      actionsPadding: EdgeInsets.only(right: 17.w),
      actions: [
        NotificationBellButton(
          iconAsset: AppAssets.notificationWhite,
          iconSize: AppDimensions.kActionButtonSize,
        ),
        SizedBox(width: 8.w),
        const _ProfileAvatar(),
      ],
      title: Image.asset(
        AppAssets.kHomeLogoAsset,
        width: 118.w,
        height: 56.h,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kMainBackgroundColor,
      body: BlocListener<HomeBloc, HomeState>(
        bloc: bloc,
        listenWhen:
            (prev, curr) => curr is GetDataFailure || curr is GetDataSuccess,
        listener: (context, state) {
          if (state is GetDataFailure) {
            _dialogUtil.showCustomSnackbar(
              content: state.errorMessage,
              context: context,
              isError: true,
            );
          } else if (state is GetDataSuccess) {
            final pkg = state.homeEntity.packageDetails;
            if (pkg != null && state.loadPackage) {
              bloc.add(
                GetPlans(
                  packageId: pkg.packageId,
                  subscriberUuid: state.homeEntity.subscriberId,
                ),
              );
            }
          }
        },
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColor.kPrimaryColor,
          // Show the spinner below the pinned toolbar, not behind it.
          edgeOffset: MediaQuery.paddingOf(context).top + 76.h,
          child: BlocBuilder<HomeBloc, HomeState>(
            bloc: bloc,
            buildWhen:
                (prev, curr) => curr is GetDataSuccess || curr is GetDataFailure,
            builder: (context, state) {
              if (state is GetDataFailure) {
                return CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(context),
                    SliverFillRemaining(
                      child: RetryWidget(
                        errorMessage: state.errorMessage,
                        onRetry:
                            () => bloc.add(const GetHomeData(loadPackage: true)),
                      ),
                    ),
                  ],
                );
              }
              if (state is GetDataSuccess) {
                final HomeEntity home = state.homeEntity;
                final PackageDetailsEntity? pkg = home.packageDetails;
                final String subscriberId = home.subscriberId;
                final String packageId = pkg?.packageId ?? '';
                return CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(
                      context,
                      // Laid out from the bar's real height: FlexibleSpaceBar
                      // reports the normal height while stretching, so its
                      // background would stay put and split from the body.
                      flexibleSpace: LayoutBuilder(
                        builder: (context, constraints) {
                          final settings =
                              context
                                  .dependOnInheritedWidgetOfExactType<
                                    FlexibleSpaceBarSettings
                                  >()!;
                          final barHeight = constraints.maxHeight;
                          // 1 when expanded (or stretched), 0 when collapsed.
                          final expanded = ((barHeight - settings.minExtent) /
                                  (settings.maxExtent - settings.minExtent))
                              .clamp(0.0, 1.0);
                          return ClipRect(
                            child: Stack(
                              children: [
                                // Top part of the blue header. Stays still
                                // while collapsing (the bar just clips it);
                                // while stretched it follows the bar's bottom
                                // edge so it stays joined to the body part,
                                // and the bar colour fills above it.
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: math.max(
                                    0.0,
                                    barHeight - settings.maxExtent,
                                  ),
                                  child: _headerBackground(),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: IgnorePointer(
                                    ignoring: expanded < 0.5,
                                    child: Opacity(
                                      opacity: expanded,
                                      child: _WalletCard(home: home),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Stack(
                        children: [
                          // Rest of the blue header (Figma: ends at 272, combo
                          // card starts at 198), so the card overlaps it.
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: _headerHeight - _barHeight,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(30.0),
                                bottomRight: Radius.circular(30.0),
                              ),
                              child: OverflowBox(
                                alignment: Alignment.bottomCenter,
                                minHeight: _headerHeight,
                                maxHeight: _headerHeight,
                                child: _headerBackground(),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (pkg != null)
                                _ComboCard(pkg: pkg, subscriberId: subscriberId),
                              SizedBox(height: 17.h),
                              _QuickActions(
                                onRechargeTap: () {
                                  _showRechargeSheet(
                                    context,
                                    PackageInfoEntity(
                                      id: packageId,
                                      packageName: pkg!.packageName,
                                      freeValidity: 0,
                                      initialFreeValidity: 0,
                                      renewalFee: pkg.renewalFee,
                                      allocatedVolume: pkg.availableVolumeGb,
                                      fallbackSpeed: '0UL',
                                      subPackageCount: 0,
                                      renewPeriod: pkg.validity,
                                      speedInKbps: pkg.speedMbps * 1024.toInt(),
                                      createCorrespondingTermPlan:
                                          pkg
                                              .packageInfoEntity
                                              .createCorrespondingTermPlan,
                                      speedProfile:
                                          pkg.packageInfoEntity.speedProfile,
                                      status: pkg.packageInfoEntity.status,
                                      fbSpeedInKbps:
                                          pkg.packageInfoEntity.fbSpeedInKbps,
                                      editable: pkg.packageInfoEntity.editable,
                                      amount: pkg.packageInfoEntity.amount,
                                      originalAmount:
                                          pkg.packageInfoEntity.originalAmount,
                                      discountAmount:
                                          pkg.packageInfoEntity.discountAmount,
                                      savedAmount:
                                          pkg.packageInfoEntity.savedAmount,
                                      speed: pkg.packageInfoEntity.speed,
                                      validity: pkg.packageInfoEntity.validity,
                                      volumeType:
                                          pkg.packageInfoEntity.volumeType,
                                      volumeValue:
                                          pkg.packageInfoEntity.volumeValue,
                                      planTypeName:
                                          pkg.packageInfoEntity.planTypeName,
                                      packageType:
                                          pkg.packageInfoEntity.packageType,
                                    ),
                                  );
                                },
                                onTransactionsTap:
                                    () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.transactionHistoryPage,
                                    ),
                                onInvoiceTap:
                                    () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.invoiceListPage,
                                    ),
                              ),
                              SizedBox(height: 16.h),
                              const _PromoBanner(),
                              SizedBox(height: 19.h),
                              const _ServicesSection(),
                              SizedBox(height: 20.h),
                              BlocBuilder<HomeBloc, HomeState>(
                                bloc: bloc,
                                buildWhen:
                                    (prev, curr) => curr is GetPlansSuccess,
                                builder: (BuildContext context, HomeState state) {
                                  return state is GetPlansSuccess &&
                                          state.packageEntities.isNotEmpty
                                      ? _PlanChangeSection(
                                        subscriberUuid: subscriberId,
                                        currentPackageId: packageId,
                                        name: home.firstName,
                                        plans: state.packageEntities,
                                      )
                                      : const SizedBox.shrink();
                                },
                              ),
                              SizedBox(height: 17.h),
                              const _ReferBanner(),
                              SizedBox(height: 80.h),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context),
                  const SliverFillRemaining(child: HomeShimmer()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Profile Avatar ──────────────────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  static const _placeholderAvatar = 'assets/images/avatar.jpg';

  static const _decoration = BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
    border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
  );

  @override
  Widget build(BuildContext context) {
    // TODO(BE): show the subscriber's photo once the API provides it.
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: _decoration,
      child: ClipOval(
        child: Image.asset(
          _placeholderAvatar,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Icon(
                Icons.person,
                size: 28.sp,
                color: AppColor.kPrimaryColor,
              ),
        ),
      ),
    );
  }
}

// ─── Wallet Card ─────────────────────────────────────────────────────────────

class _WalletCard extends StatelessWidget {
  final HomeEntity home;

  const _WalletCard({required this.home});

  // TODO(BE): dummy values until the API returns the last transaction amount
  // and the autopay status.
  static const double _dummyLastTransaction = 699;
  static const bool _dummyAutoPayEnabled = true;

  static final _amountFmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 0,
  );
  static final _dateFmt = DateFormat('dd MMM yyyy');

  static const _cardDecoration = BoxDecoration(
    color: Color(0xD9FFFFFF),
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );
  static const _amountDecoration = BoxDecoration(
    color: AppColor.kWhite30,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );
  static const _autoPayDecoration = BoxDecoration(
    color: AppColor.kWhite80,
    borderRadius: BorderRadius.all(Radius.circular(50)),
  );

  // Styles — Sizer values fixed after MaterialApp.builder.
  static final _amountStyle = TextStyle(
    color: Colors.black,
    fontSize: 18.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 0.92,
    letterSpacing: 0,
  );
  static final _labelStyle = TextStyle(
    color: Colors.black,
    fontSize: 13.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1,
    letterSpacing: 0,
  );
  static final _updatedStyle = TextStyle(
    color: Colors.black,
    fontSize: 8.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1,
    letterSpacing: 0,
  );
  static final _autoPayStyle = TextStyle(
    color: const Color(0xFF080808),
    fontSize: 10.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    final formattedDate = _dateFmt.format(home.lastUpdated);

    // Design: 48 tall card at y=134, 16 above the combo card.
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: _cardDecoration,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              decoration: _amountDecoration,
              child: Text(
                _amountFmt.format(_dummyLastTransaction),
                style: _amountStyle,
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.bssSubL10n.lastTransaction,
                    style: _labelStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    context.bssSubL10n.updatedDate(formattedDate),
                    style: _updatedStyle,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AutopayPage(),
                    ),
                  ),
              borderRadius: const BorderRadius.all(Radius.circular(50)),
              child: Container(
                height: 22.h,
                padding: EdgeInsets.only(left: 8.w, right: 2.w),
                decoration: _autoPayDecoration,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.bssSubL10n.autoPay, style: _autoPayStyle),
                    SizedBox(width: 4.w),
                    const _SwitchIndicator(value: _dummyAutoPayEnabled),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Display-only switch; the Auto Pay pill opens the autopay page on tap.
class _SwitchIndicator extends StatelessWidget {
  final bool value;

  const _SwitchIndicator({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 18.h,
      padding: EdgeInsets.all(2.w),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: value ? AppColor.kPrimaryColor : AppColor.kToggleDisabledGrey,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
      ),
      child: Container(
        width: 14.w,
        height: 14.w,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Combo Card ──────────────────────────────────────────────────────────────

class _ComboCard extends StatelessWidget {
  final PackageDetailsEntity pkg;
  final String subscriberId;

  const _ComboCard({required this.pkg, required this.subscriberId});

  static final _activeUntilFmt = DateFormat('MMM dd, yyyy');

  // Static decorations — no new object created per build.
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [BoxShadow(color: AppColor.kCardShadow, blurRadius: 16)],
  );

  static const _daysLeftDecoration = BoxDecoration(
    color: AppColor.kAutopayButtonColor,
    borderRadius: BorderRadius.all(Radius.circular(50)),
  );

  static final _packageNameStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.3,
    fontSize: 16.sp,
    color: AppColor.kTextPrimary,
  );
  static final _activeUntilStyle = TextStyle(
    color: AppColor.kTextPrimary80,
    fontSize: 10.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.6,
  );
  static final _daysLeftTextStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontSize: 12.sp,
    color: AppColor.kTextSecondaryDark,
  );
  static final _packLabelStyle = TextStyle(
    fontSize: 12.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final activeUntilStr = _activeUntilFmt.format(pkg.activeUntil);
    final dataStr =
        pkg.totalVolumeGb > 0
            ? l10n.valueInGb(pkg.totalVolumeGb.toStringAsFixed(0))
            : l10n.unlimited;

    // Design: 16 padding; header row (38) · 18 · usage (36) · 20 · stats (24).
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration,
      child: Column(
        children: [
          // Top-aligned so a plan name that wraps grows downwards and the
          // icon and days-left pill stay at the top.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 19.w,
                      backgroundColor: AppColor.kPrimaryColor,
                      child: Icon(
                        Icons.language,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 9.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(pkg.packageName, style: _packageNameStyle),
                          Text(
                            l10n.activeUntilDate(activeUntilStr),
                            style: _activeUntilStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                height: 28.h,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: _daysLeftDecoration,
                child: Text(
                  l10n.daysLeft(pkg.daysLeft.toString()),
                  style: _daysLeftTextStyle,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          // Opens data usage (previously the "View usage" button).
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder:
                        (_) => DataUsageView(
                          subscriberUuid: subscriberId,
                          entity: ActivePackagesDetailsEntity(
                            packageId: pkg.packageId,
                            activeAddOns: [],
                            activeUntil: pkg.activeUntil,
                            availableVolumeGb: pkg.availableVolumeGb,
                            daysLeft: pkg.daysLeft,
                            packageName: pkg.packageName,
                            packageType: pkg.packageType,
                            renewalFee: pkg.renewalFee,
                            speedMbps: pkg.speedMbps,
                            totalPackageCount: pkg.totalPackageCount,
                            totalVolumeGb: pkg.totalVolumeGb,
                          ),
                        ),
                  ),
                ),
            child: _UsageBar(pkg: pkg),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    spacing: 10.w,
                    children: [
                      _Stat(
                        icon: Icons.bar_chart_rounded,
                        label: l10n.data,
                        value: dataStr,
                      ),
                      _Stat(
                        icon: Icons.speed_rounded,
                        label: l10n.speed,
                        value: l10n.mbps(pkg.speedMbps.round()),
                      ),
                      _Stat(
                        icon: Icons.data_usage_rounded,
                        label: l10n.planLabel,
                        value: pkg.packageType,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              SecondaryButton(
                height: 24.h,
                borderRadius: 8,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                textStyle: _packLabelStyle,
                label: l10n.plusPacks(
                  pkg.packageInfoEntity.subPackageCount.toString(),
                ),
                onClicked:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder:
                            (_) =>
                                ActivePackagePage(subscriberUuid: subscriberId),
                      ),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Usage Bar ───────────────────────────────────────────────────────────────

class _UsageBar extends StatelessWidget {
  final PackageDetailsEntity pkg;

  const _UsageBar({required this.pkg});

  static const _segments = 10;
  static const _segmentRadius = BorderRadius.all(Radius.circular(4));

  static final _usedStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 16.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static final _totalStyle = TextStyle(
    color: AppColor.kHintGrey,
    fontSize: 8.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  static final _leftStyle = TextStyle(
    color: AppColor.kTealAccent,
    fontSize: 8.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final total = pkg.totalVolumeGb;
    final hasLimit = total > 0;
    final used =
        hasLimit ? (total - pkg.availableVolumeGb).clamp(0, total) : 0.0;
    final filled = hasLimit ? (used / total * _segments).round() : 0;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text.rich(
                hasLimit
                    ? TextSpan(
                      children: [
                        TextSpan(
                          text: l10n.valueInGb(used.toStringAsFixed(0)),
                          style: _usedStyle,
                        ),
                        TextSpan(
                          text: ' ${l10n.gbUsedOfTotal(total.toStringAsFixed(0))}',
                          style: _totalStyle,
                        ),
                      ],
                    )
                    : TextSpan(text: l10n.unlimited, style: _usedStyle),
              ),
            ),
            if (hasLimit)
              Text(
                l10n.gbLeft(pkg.availableVolumeGb.toStringAsFixed(0)),
                style: _leftStyle,
              ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          spacing: 3.w,
          children: List.generate(
            _segments,
            (i) => Expanded(
              child: Container(
                height: 8.h,
                decoration: BoxDecoration(
                  color:
                      i < filled
                          ? AppColor.kTealAccent
                          : AppColor.kMainBackgroundColor,
                  borderRadius: _segmentRadius,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Stat ─────────────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label, value;

  const _Stat({required this.icon, required this.label, required this.value});

  static final _labelStyle = TextStyle(
    color: AppColor.kLabelGrey,
    fontSize: 8.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  static final _valueStyle = TextStyle(
    fontSize: 11.sp,
    color: AppColor.kTextSecondaryDark,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    // TODO(assets): swap the Material icons for the Figma icons.
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4.w,
      children: [
        Icon(icon, size: 16.sp, color: AppColor.kPrimaryColor),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: _labelStyle),
            Text(
              value,
              style: _valueStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Quick Actions ───────────────────────────────────────────────────────────

class _ActionItem {
  final String label;
  final Color color;
  final String icon;

  /// The icon's own colours (drawn for a white circle); they become white
  /// on the coloured circle.
  final Set<int> iconColors;
  final VoidCallback onTap;

  const _ActionItem({
    required this.label,
    required this.color,
    required this.icon,
    required this.iconColors,
    required this.onTap,
  });
}

/// Inverts a quick-action icon for its coloured circle: the icon's colours
/// become white and its white details take the circle colour.
class _InvertedIconColorMapper extends ColorMapper {
  const _InvertedIconColorMapper({
    required this.iconColors,
    required this.circleColor,
  });

  final Set<int> iconColors;
  final Color circleColor;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    // Compare RGB only and keep the original alpha.
    final rgb = color.toARGB32() | 0xFF000000;
    final alpha = (color.a * 255).round();
    if (iconColors.contains(rgb)) return Colors.white.withAlpha(alpha);
    if (rgb == 0xFFFFFFFF) return circleColor.withAlpha(alpha);
    return color;
  }

  // flutter_svg caches pictures per loader, so equality must cover colours.
  @override
  bool operator ==(Object other) =>
      other is _InvertedIconColorMapper &&
      other.circleColor == circleColor &&
      setEquals(other.iconColors, iconColors);

  @override
  int get hashCode =>
      Object.hash(circleColor, Object.hashAllUnordered(iconColors));
}

class _QuickActions extends StatefulWidget {
  final VoidCallback onRechargeTap;
  final VoidCallback onTransactionsTap;
  final VoidCallback onInvoiceTap;

  const _QuickActions({
    required this.onRechargeTap,
    required this.onTransactionsTap,
    required this.onInvoiceTap,
  });

  @override
  State<_QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<_QuickActions> {
  late List<_ActionItem> _actions;

  // Precomputed — shared across all action items.
  static const _tileDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [BoxShadow(color: AppColor.kCardShadow, blurRadius: 16)],
  );

  // Design uses Inter for these labels.
  static final _actionLabelStyle = GoogleFonts.inter(
    color: AppColor.kTextSecondaryDark,
    fontWeight: FontWeight.w500,
    fontSize: 12.sp,
    height: 1.5,
  );
  static const _circleShadow = [
    BoxShadow(color: AppColor.kBlack9, blurRadius: 4, offset: Offset(0, 4)),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = context.bssSubL10n;
    // Callbacks read `widget` at tap time: the parent passes new closures
    // (e.g. a new package id after a plan change) without recreating this
    // state, so storing widget.onXxx here would keep the stale ones.
    _actions = [
      _ActionItem(
        label: l10n.recharge,
        color: AppColor.kQuickRecharge,
        icon: AppAssets.rechargeIcon,
        iconColors: const {0xFF14B8A6},
        onTap: () => widget.onRechargeTap(),
      ),
      _ActionItem(
        label: l10n.transactions,
        color: AppColor.kQuickTransactions,
        icon: AppAssets.moneyIcon,
        iconColors: const {0xFFF97316},
        onTap: () => widget.onTransactionsTap(),
      ),
      _ActionItem(
        label: l10n.invoice,
        color: AppColor.kPrimaryColor,
        icon: AppAssets.invoiceIcon,
        // Red page plus its darker back page.
        iconColors: const {0xFFEF4949, 0xFF881F1F, 0xFF8D1B1B},
        onTap: () => widget.onInvoiceTap(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Design: three 100×100 white tiles, 20 from the edges, ~17.6 apart.
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        spacing: 17.6.w,
        children:
            _actions
                .map(
                  (a) => Expanded(
                    child: GestureDetector(
                      onTap: a.onTap,
                      child: Container(
                        height: 100.h,
                        decoration: _tileDecoration,
                        child: Column(
                          // Design: circle starts 16 below the tile top.
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 16.h),
                            Container(
                              width: 46.w,
                              height: 46.w,
                              decoration: BoxDecoration(
                                color: a.color,
                                shape: BoxShape.circle,
                                boxShadow: _circleShadow,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(11.w),
                                child: SvgPicture(
                                  SvgAssetLoader(
                                    a.icon,
                                    colorMapper: _InvertedIconColorMapper(
                                      iconColors: a.iconColors,
                                      circleColor: a.color,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(a.label, style: _actionLabelStyle),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

// ─── Promo Banner ────────────────────────────────────────────────────────────

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  static const _radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    // Design: 335×182, 20 from the edges.
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: AspectRatio(
        aspectRatio: 335 / 182,
        child: ClipRRect(
          borderRadius: _radius,
          child: Image.asset(AppAssets.homePromoBanner, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// ─── Plan Change Section ─────────────────────────────────────────────────────

class _PlanChangeSection extends StatelessWidget {
  final String subscriberUuid;
  final String currentPackageId;
  final String name;
  final List<PackageInfoEntity> plans;

  const _PlanChangeSection({
    required this.subscriberUuid,
    required this.currentPackageId,
    required this.name,
    required this.plans,
  });

  static final _headingStyle = TextStyle(
    fontSize: 16.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    color: AppColor.kHeadingDark,
  );

  static TextStyle get _seeAllStyle => TextStyle(
    color: AppColor.kPrimaryColor,
    fontSize: 14.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.bssSubL10n.planChange, style: _headingStyle),
              Row(
                spacing: 4.w,
                children: [
                  CommonTextButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder:
                                (_) => SeasonalPlanPage(
                                  subscriberUuid: subscriberUuid,
                                  subscriberName: name,
                                  currentPackageId: currentPackageId,
                                ),
                          ),
                        ),
                    label: context.bssSubL10n.seeAll,
                    textStyle: _seeAllStyle,
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 16.sp,
                    color: AppColor.kPrimaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Design: cards start 12 below the title row.
        SizedBox(height: 12.h),
        Column(
          spacing: 10.h,
          children: [
            for (final plan in plans)
              _PlanCard(key: ValueKey(plan.id), plan: plan),
          ],
        ),
      ],
    );
  }
}

// ─── Plan Card ───────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final PackageInfoEntity plan;

  const _PlanCard({super.key, required this.plan});

  static const _decoration = BoxDecoration(
    color: Color(0xFFFAF9F6),
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(BorderSide(color: AppColor.kCardBorderBeige)),
  );
  static const _arrowDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.fromBorderSide(BorderSide(color: AppColor.kCardBorderBeige)),
  );

  static TextStyle get _priceStyle => TextStyle(
    color: AppColor.kPrimaryColor,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w700,
    fontSize: 16.sp,
    height: 1.2,
  );
  static final _daysStyle = TextStyle(
    color: AppColor.kLabelGrey,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w400,
    fontSize: 10.sp,
    height: 1.3,
  );
  static final _packageNameStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontSize: 13.sp,
    color: AppColor.kTextSecondaryDark,
  );
  static final _specsStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w400,
    height: 1.3,
    fontSize: 9.sp,
    color: AppColor.kHintGrey,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final specs = [
      l10n.valueInGb('${plan.allocatedVolume}'),
      l10n.mbps((plan.speedInKbps / 1024).round()),
      '${plan.packageType.name} ${l10n.fpu}',
    ].join(' · ');

    // Design: 60 tall row — price · dashed divider · name/specs · arrow.
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
      decoration: _decoration,
      child: Row(
        children: [
          SizedBox(
            width: 52.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('₹${plan.renewalFee}', style: _priceStyle),
                ),
                Text(
                  l10n.daysLowercase('${plan.renewPeriod}'),
                  style: _daysStyle,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          const _DashedDivider(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  plan.packageName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _packageNameStyle,
                ),
                SizedBox(height: 2.h),
                Text(
                  specs,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _specsStyle,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Previously the "Choose Plan" button.
          InkWell(
            customBorder: const CircleBorder(),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder:
                        (_) => BlocProvider(
                          create:
                              (_) => ChangePlanBloc(
                                repository: sl<ChangePlanRepository>(),
                              ),
                          child: RechargePage(
                            package: plan,
                            isChangePlan: true,
                          ),
                        ),
                  ),
                ),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: _arrowDecoration,
              child: Icon(
                Icons.arrow_forward,
                size: 20.sp,
                color: AppColor.kTextSecondaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 2.h,
      children: List.generate(
        9,
        (_) => Container(
          width: 1,
          height: 2.h,
          color: AppColor.kCardBorderBeige,
        ),
      ),
    );
  }
}

// ─── Services Section ─────────────────────────────────────────────────────────

class _ServiceItem {
  final String title;

  /// SVG icon from the design; [fallbackIcon] is used until one exists.
  final String? iconAsset;
  final IconData? fallbackIcon;
  final List<Color> colors;

  /// Null until the target screen exists.
  final VoidCallback? onTap;

  const _ServiceItem({
    required this.title,
    this.iconAsset,
    this.fallbackIcon,
    required this.colors,
    this.onTap,
  }) : assert(iconAsset != null || fallbackIcon != null);
}

class _ServicesSection extends StatefulWidget {
  const _ServicesSection();

  @override
  State<_ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<_ServicesSection> {
  late List<_ServiceItem> _services;

  static final _headingStyle = TextStyle(
    fontSize: 16.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColor.kTextSecondaryDark,
  );
  static TextStyle get _viewAllStyle => TextStyle(
    color: AppColor.kPrimaryColor,
    fontSize: 14.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
  );
  static const _boxDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(BorderSide(color: AppColor.kTotalDivider)),
  );

  void _push(Widget page) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => page),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = context.bssSubL10n;
    _services = [
      _ServiceItem(
        title: l10n.speedTest,
        iconAsset: AppAssets.serviceSpeedTest,
        colors: const [Color(0xFF0E8FD2), Color(0xFF026DA7)],
        onTap: () => _push(const SpeedTestPage()),
      ),
      _ServiceItem(
        title: l10n.rwPlay,
        iconAsset: AppAssets.serviceRwPlay,
        colors: const [Color(0xFF96638C), Color(0xFF8B5E83)],
      ),
      _ServiceItem(
        title: l10n.secure,
        iconAsset: AppAssets.serviceSecure,
        colors: const [Color(0xFF728B54), Color(0xFF647D45)],
      ),
      _ServiceItem(
        title: l10n.myRouter,
        iconAsset: AppAssets.serviceMyRouter,
        colors: const [Color(0xFFF2660C), Color(0xFFCF4A06)],
        onTap: () => _push(const RestartModemPage()),
      ),
      _ServiceItem(
        title: l10n.addOns,
        // TODO(assets): no Add-ons icon yet.
        fallbackIcon: Icons.add_rounded,
        colors: const [Color(0xFF9474FF), Color(0xFF6A3FF0)],
      ),
      _ServiceItem(
        title: l10n.complaint,
        iconAsset: AppAssets.serviceComplaint,
        colors: const [Color(0xFF9F6B46), Color(0xFFB66A35)],
        onTap: () => _push(const TicketsPage()),
      ),
      _ServiceItem(
        title: l10n.refer,
        iconAsset: AppAssets.serviceRefer,
        colors: const [Color(0xFFE55F9F), Color(0xFFC92A7A)],
      ),
      _ServiceItem(
        title: l10n.more,
        iconAsset: AppAssets.serviceMore,
        colors: const [Color(0xFF66708A), Color(0xFF444C62)],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.bssSubL10n.homeServices, style: _headingStyle),
              // TODO: no "View all" screen yet.
              CommonTextButton(
                onPressed: () {},
                label: context.bssSubL10n.viewAll,
                textStyle: _viewAllStyle,
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.symmetric(vertical: 15.h),
          decoration: _boxDecoration,
          // Design: 4 columns, 50 tiles with 11 labels, rows 87 apart.
          child: GridView.builder(
            // Without an explicit padding the grid adds the status-bar inset
            // on top (the Scaffold no longer has an appBar to consume it).
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 15.h,
              mainAxisExtent: 72.h,
            ),
            itemCount: _services.length,
            itemBuilder: (_, i) => _ServiceTile(item: _services[i]),
          ),
        ),
      ],
    );
  }
}

// ─── Service Tile ─────────────────────────────────────────────────────────────

class _ServiceTile extends StatelessWidget {
  final _ServiceItem item;

  const _ServiceTile({required this.item});

  static const _radius = BorderRadius.all(Radius.circular(16));
  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.3,
    fontSize: 11.sp,
    color: AppColor.kDarkGrey,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.onTap,
      child: Column(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              borderRadius: _radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: item.colors,
              ),
              boxShadow: [
                BoxShadow(
                  color: item.colors.last.withAlpha(0x42),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            alignment: Alignment.center,
            child:
                item.iconAsset != null
                    ? SvgPicture.asset(
                      item.iconAsset!,
                      width: 22.w,
                      height: 22.w,
                    )
                    : Icon(item.fallbackIcon, color: Colors.white, size: 22.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            item.title,
            style: _titleStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Refer Banner ────────────────────────────────────────────────────────────

class _ReferBanner extends StatelessWidget {
  const _ReferBanner();

  // TODO(BE): dummy reward until the referral API exists.
  static const _dummyRewardAmount = '200';

  static const _decoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(BorderSide(color: AppColor.kPeachBorder)),
    gradient: LinearGradient(
      colors: [Color(0xFFFCE7B0), Color(0xFFF8D9C9)],
    ),
  );
  static const _giftDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );
  static const _inviteDecoration = BoxDecoration(
    color: Color(0xFF13233F),
    borderRadius: BorderRadius.all(Radius.circular(50)),
  );

  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontSize: 14.sp,
    color: AppColor.kTextSecondaryDark,
  );
  static final _subtitleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w400,
    height: 1.3,
    fontSize: 10.sp,
    color: AppColor.kLabelGrey,
  );
  static final _inviteStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.3,
    fontSize: 10.sp,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    // Design: 71 tall, 12 padding, 36 gift box.
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(12.w),
      decoration: _decoration,
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: _giftDecoration,
            child: Icon(
              Icons.card_giftcard_outlined,
              size: 20.sp,
              color: AppColor.kQuickTransactions,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.referEarnTitle, style: _titleStyle),
                SizedBox(height: 2.h),
                Text(
                  l10n.referEarnSubtitle(_dummyRewardAmount),
                  style: _subtitleStyle,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // TODO: no referral flow yet.
          InkWell(
            onTap: () {},
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            child: Container(
              height: 24.h,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: _inviteDecoration,
              child: Text(l10n.inviteNow, style: _inviteStyle),
            ),
          ),
        ],
      ),
    );
  }
}
