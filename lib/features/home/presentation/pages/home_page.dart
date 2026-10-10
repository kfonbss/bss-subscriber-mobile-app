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
import 'package:kfon_subscriber/shared/widgets/tenant_svg_color_mapper.dart';
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
import 'package:kfon_subscriber/features/home/domain/entity/home_entity.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_bloc.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_event.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_state.dart';
import 'package:kfon_subscriber/features/home/presentation/components/home_shimmer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
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

  // Design: blue header is 276 tall; the expanded bar covers the first 220.
  double get _headerHeight => 276.h;
  double get _barHeight => 220.h;

  Widget _headerBackground() {
    return SvgPicture(
      SvgAssetLoader(
        AppAssets.homeBackground,
        colorMapper: TenantSvgColorMapper(),
      ),
      width: double.infinity,
      height: _headerHeight,
      fit: BoxFit.fitWidth,
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
      // Design: logo 20 below the status bar, wallet label 14 below it.
      toolbarHeight: 82.h,
      // Design: header content ends at y=220 (card top); status bar is 44.
      expandedHeight: flexibleSpace == null ? null : 176.h,
      flexibleSpace: flexibleSpace,
      // Design: logo at x=21; icons centred on the logo (y=88), the last one
      // centred 40 from the right edge.
      titleSpacing: 21.w,
      actionsPadding: EdgeInsets.only(right: 21.w, top: 6.h),
      actions: [
        NotificationBellButton(
          iconAsset: AppAssets.notificationWhite,
          iconSize: AppDimensions.kActionButtonSize,
        ),
        InkWell(
          onTap: () => _dialogUtil.showLogoutDialog(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: SvgPicture.asset(
              AppAssets.logout,
              width: Sizer.isTablet ? 24.0.w : 22.0,
              height: Sizer.isTablet ? 24.0.h : 22.0,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
      title: Padding(
        padding: EdgeInsets.only(top: 6.h),
        child: Image.asset(
          AppAssets.kLogo,
          width: 77.w,
          height: 48.h,
          fit: BoxFit.contain,
        ),
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
            _dialogUtil.showMessage(state.errorMessage, context);
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
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Stack(
                        children: [
                          // Top part of the 276-tall blue header; the rest is
                          // drawn behind the combo card below.
                          Positioned.fill(
                            child: ClipRect(
                              child: OverflowBox(
                                alignment: Alignment.topCenter,
                                minHeight: _headerHeight,
                                maxHeight: _headerHeight,
                                child: _headerBackground(),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _WalletCard(home: home),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        // Rest of the blue header (Figma: ends at 276, combo
                        // card starts at 220), so the card overlaps it.
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
                            SizedBox(height: 20.h),
                            _QuickActions(
                              onRechargeTap:
                                  () => _showRechargeSheet(
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
                                  ),
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
                            SizedBox(height: 32.h),
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
                            SizedBox(height: 32.h),
                            const _ServicesSection(),
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
    );
  }
}

// ─── Wallet Card ─────────────────────────────────────────────────────────────

class _WalletCard extends StatelessWidget {
  final HomeEntity home;

  const _WalletCard({required this.home});

  static final _balanceFmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );
  static final _dateFmt = DateFormat('dd MMM yyyy');

  // Styles — Sizer values fixed after MaterialApp.builder.
  static final _walletLabelStyle = TextStyle(
    color: AppColor.kWhite80,
    fontSize: 14.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1,
  );
  static final _balanceStyle = TextStyle(
    color: Colors.white,
    fontSize: 30.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 0.92,
  );
  static final _updatedStyle = TextStyle(
    color: AppColor.kWhite80,
    fontSize: 8.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1,
  );

  @override
  Widget build(BuildContext context) {
    final formattedBalance = _balanceFmt.format(home.balance);
    final formattedDate = _dateFmt.format(home.lastUpdated);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // Design: Auto Pay button top (152) lines up with the balance row.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.bssSubL10n.walletBalance, style: _walletLabelStyle),
              SizedBox(height: 12.h),
              Text(formattedBalance, style: _balanceStyle),
              SizedBox(height: 12.h),
              Text(
                context.bssSubL10n.updatedDate(formattedDate),
                style: _updatedStyle,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 26.h),
            child: InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AutopayPage(),
                    ),
                  ),
              child: Container(
                height: 28.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: AppColor.kAutopayButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  context.bssSubL10n.autoPay,
                  style: TextStyle(
                    color: AppColor.kTextSecondaryDark,
                    fontSize: 12.sp,
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w600,
                    height: 1.30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Design: outlined button labels are GeneralSans Medium 12 / 1.3 (the shared
// SecondaryButton defaults to 16).
final _buttonLabelStyle = TextStyle(
  fontSize: 12.sp,
  fontFamily: 'GeneralSans',
  fontWeight: FontWeight.w500,
  height: 1.3,
);

// ─── Combo Card ──────────────────────────────────────────────────────────────

class _ComboCard extends StatelessWidget {
  final PackageDetailsEntity pkg;
  final String subscriberId;

  const _ComboCard({required this.pkg, required this.subscriberId});

  static final _activeUntilFmt = DateFormat('MMM dd, yyyy');

  // Static decorations — no new object created per build.
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
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

  @override
  Widget build(BuildContext context) {
    final activeUntilStr = _activeUntilFmt.format(pkg.activeUntil);
    final speedStr = context.bssSubL10n.mbps(pkg.speedMbps.round());
    final amountStr = '₹${pkg.renewalFee.toStringAsFixed(0)}';
    final usageStr =
        (pkg.availableVolumeGb > 0 || pkg.totalVolumeGb > 0)
            ? context.bssSubL10n.usageOfTotalGb(
              pkg.availableVolumeGb.toStringAsFixed(0),
              pkg.totalVolumeGb.toStringAsFixed(0),
            )
            : context.bssSubL10n.unlimited;

    // Design: 16 padding; header row (38) · 16 · stats (50) · 16 · buttons (32).
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(pkg.packageName, style: _packageNameStyle),
                          Text(
                            context.bssSubL10n.activeUntilDate(activeUntilStr),
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
                  context.bssSubL10n.daysLeft(pkg.daysLeft.toString()),
                  style: _daysLeftTextStyle,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            height: 50.h,
            decoration: const ShapeDecoration(
              color: AppColor.kSecondaryBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            // Design: stats left-aligned, 22 apart.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 22.w,
              children: [
                _Stat(label: context.bssSubL10n.amount, value: amountStr),
                _Stat(label: context.bssSubL10n.speed, value: speedStr),
                _Stat(label: context.bssSubL10n.fpu, value: pkg.packageType),
                _Stat(label: context.bssSubL10n.usage, value: usageStr),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 32.h,
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    borderRadius: 10,
                    textStyle: _buttonLabelStyle,
                    label: context.bssSubL10n.packsActive(
                      pkg.packageInfoEntity.subPackageCount.toString(),
                    ),
                    onClicked:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder:
                                (_) => ActivePackagePage(
                                  subscriberUuid: subscriberId,
                                ),
                          ),
                        ),
                  ),
                ),
                SizedBox(width: 13.w),
                Expanded(
                  child: PrimaryButton(
                    label: context.bssSubL10n.viewUsage,
                    isLoading: false,
                    onClicked:
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat ─────────────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final String label, value;

  /// Label font size: 10 on the combo card, 8 on the plan cards (design).
  final double labelSize;

  const _Stat({required this.label, required this.value, this.labelSize = 10});

  static final _valueStyle = TextStyle(
    fontSize: 11.sp,
    color: AppColor.kTextSecondaryDark,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    // Centred vertically inside the grey box (not stuck to its top edge).
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColor.kLabelGrey,
            fontSize: labelSize.sp,
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
        SizedBox(height: 2.h),
        Text(value, style: _valueStyle),
      ],
    );
  }
}

// ─── Quick Actions ───────────────────────────────────────────────────────────

class _ActionItem {
  final String label;
  final Color color;
  final String icon;
  final VoidCallback onTap;

  const _ActionItem({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });
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
  static const _actionRadius = BorderRadius.all(Radius.circular(16));
  // Design uses Inter for these labels.
  static final _actionLabelStyle = GoogleFonts.inter(
    color: Colors.white,
    fontWeight: FontWeight.w500,
    fontSize: 12.sp,
    height: 1.5,
  );
  static const _actionShadow = [
    BoxShadow(color: AppColor.kBlack12, blurRadius: 16),
  ];
  static const _circleShadow = [
    BoxShadow(color: AppColor.kBlack9, blurRadius: 4, offset: Offset(0, 4)),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = context.bssSubL10n;
    _actions = [
      _ActionItem(
        label: l10n.recharge,
        color: AppColor.kQuickRecharge,
        icon: AppAssets.rechargeIcon,
        onTap: widget.onRechargeTap,
      ),
      _ActionItem(
        label: l10n.transactions,
        color: AppColor.kQuickTransactions,
        icon: AppAssets.moneyIcon,
        onTap: widget.onTransactionsTap,
      ),
      _ActionItem(
        label: l10n.invoice,
        color: AppColor.kQuickInvoice,
        icon: AppAssets.invoiceIcon,
        onTap: widget.onInvoiceTap,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Design: three 100×100 tiles, 20 from the edges, ~17.6 apart.
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
                        decoration: BoxDecoration(
                          color: a.color,
                          borderRadius: _actionRadius,
                          boxShadow: _actionShadow,
                        ),
                        child: Column(
                          // Design: circle starts 13 below the tile top.
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 13.h),
                            Container(
                              width: 46.w,
                              height: 46.w,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: _circleShadow,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(11.w),
                                child: SvgPicture.asset(a.icon),
                              ),
                            ),
                            SizedBox(height: 13.h),
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
                child: Row(
                  spacing: 4.w,
                  children: [
                    Text(context.bssSubL10n.seeAll, style: _seeAllStyle),
                    Icon(
                      Icons.arrow_forward,
                      size: 16.sp,
                      color: AppColor.kPrimaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Design: cards start 40 below the title top (title row is 22 tall).
        SizedBox(height: 18.h),
        Column(
          spacing: 16.h,
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

  static BoxDecoration get _priceDecoration => BoxDecoration(
    color: AppColor.kPrimaryColor,
    borderRadius: const BorderRadius.all(Radius.circular(9)),
  );
  static final _packageNameStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontSize: 14.sp,
    color: AppColor.kTextSecondaryDark,
  );
  static final _priceStyle = TextStyle(
    color: Colors.white,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    fontSize: 18.sp,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [BoxShadow(color: AppColor.kCardShadow, blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.w,
                backgroundColor: AppColor.kIconBackground,
                child: Icon(
                  Icons.language,
                  color: AppColor.kPrimaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  plan.packageName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _packageNameStyle,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            height: 41.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: const ShapeDecoration(
              color: AppColor.kSecondaryBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(11)),
              ),
            ),
            // Design: stats left-aligned, 32 apart.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 32.w,
              children: [
                _Stat(
                  label: context.bssSubL10n.data,
                  value: context.bssSubL10n.valueInGb(
                    '${plan.allocatedVolume}',
                  ),
                  labelSize: 8,
                ),
                _Stat(
                  label: context.bssSubL10n.speed,
                  value: context.bssSubL10n.mbps(
                    (plan.speedInKbps / 1024).round(),
                  ),
                  labelSize: 8,
                ),
                _Stat(
                  label: context.bssSubL10n.fpu,
                  value: plan.packageType.name,
                  labelSize: 8,
                ),
                _Stat(
                  label: context.bssSubL10n.validity,
                  value: context.bssSubL10n.daysValue('${plan.renewPeriod}'),
                  labelSize: 8,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: _priceDecoration,
                child: Text('₹ ${plan.renewalFee}', style: _priceStyle),
              ),
              SizedBox(
                height: 32.h,
                width: 145.w,
                child: SecondaryButton(
                  borderRadius: 10,
                  textStyle: _buttonLabelStyle,
                  label: context.bssSubL10n.choosePlan,
                  onClicked:
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Services Section ─────────────────────────────────────────────────────────

class _ServiceItem {
  final String title;
  final String icon;

  const _ServiceItem({required this.title, required this.icon});
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = context.bssSubL10n;
    _services = [
      _ServiceItem(title: l10n.fiberToHome, icon: AppAssets.thunder),
      _ServiceItem(
        title: l10n.internetLeasedLine,
        icon: AppAssets.internetLeasedLine,
      ),
      _ServiceItem(title: l10n.darkFiber, icon: AppAssets.darkFiber),
      _ServiceItem(title: l10n.coLocation, icon: AppAssets.ipLocation),
      _ServiceItem(title: l10n.wifiServices, icon: AppAssets.wifi),
      _ServiceItem(title: l10n.ott, icon: AppAssets.ott),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(context.bssSubL10n.servicesOffered, style: _headingStyle),
        ),
        SizedBox(height: 17.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          // Design: 158×116 cards, 19 apart horizontally, 16 vertically.
          child: GridView.builder(
            // Without an explicit padding the grid adds the status-bar inset
            // on top (the Scaffold no longer has an appBar to consume it).
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 19.w,
              mainAxisSpacing: 16.h,
              mainAxisExtent: 116.h,
            ),
            itemCount: _services.length,
            itemBuilder:
                (_, i) => _ServiceCard(
                  title: _services[i].title,
                  icon: _services[i].icon,
                ),
          ),
        ),
      ],
    );
  }
}

// ─── Service Card ─────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final String title;
  final String icon;

  const _ServiceCard({required this.title, required this.icon});

  static const _decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.5,
    fontSize: 14.sp,
    color: AppColor.kServiceTitle,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: _decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _titleStyle),
          const Spacer(),
          // Design: icon 32 at the row top, arrow 24 sits 10 lower.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture(
                SvgAssetLoader(icon, colorMapper: TenantSvgColorMapper()),
                height: 32.w,
                width: 32.w,
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Icon(
                  Icons.arrow_forward,
                  color: AppColor.kTextFiledHintColor,
                  size: 24.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
