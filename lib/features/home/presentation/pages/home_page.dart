import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/constant/constant_dimensions.dart';
import 'package:kfon_subscriber/core/helper/bottom_sheet_helper.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/entity/active_packages_details_entity.dart';
import 'package:kfon_subscriber/features/active_package_details/presentation/pages/active_package_page.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/change_plan.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/recharge_page.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/pages/data_usage_view.dart';
import 'package:kfon_subscriber/features/home/domain/entity/home_entity.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_bloc.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_event.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_state.dart';
import 'package:kfon_subscriber/features/home/presentation/components/home_shimmer.dart';
import 'package:kfon_subscriber/features/top_up/presentation/pages/topup_page.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';
import 'package:kfon_subscriber/presentation/ui_component/secondary_button.dart';
import 'package:kfon_subscriber/service_locator.dart';

import '../../../offline_recharge/presentation/pages/offline_recharge_bottom_sheet.dart';

const _kTeal = Color(0xFF00A896);
const _kOrange = Color(0xFFFF6B2C);
const _kRed = Color(0xFFE84040);
const _kYellow = Color(0xFFFFD600);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read<HomeBloc>();
    bloc.add(const GetHomeData());
  }

  void _showRechargeSheet(BuildContext context, String subscriberId) {
    BottomSheetHelper.show(
      context: context,
      title: context.bssSubL10n.recharge,
      child: OfflineRechargeBottomSheet(subscriberUuid: subscriberId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kMainBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.kToolbarBackground,
        toolbarHeight: AppDimensions.kDefaultToolbarHeights,
        actionsPadding: const EdgeInsets.only(right: 15),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notificationPage),
            icon: Image.asset(
              'assets/icons/notification_white.png',
              width: AppDimensions.kActionButtonSize,
              height: AppDimensions.kActionButtonSize,
              fit: BoxFit.cover,
            ),
          ),
        ],
        title: SizedBox(
          height: 45.h,
          child: Image.asset(
            'assets/images/logo_white.png',
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
      body: BlocListener<HomeBloc, HomeState>(
        bloc: bloc,
        listenWhen: (prev, curr) =>
            curr is GetDataFailure || curr is GetDataSuccess,
        listener: (context, state) {
          if (state is GetDataFailure) {
            DialogUtil().showMessage(state.errorMessage, context);
          } else if (state is GetDataSuccess) {
            final pkg = state.homeEntity.packageDetails;
            if (pkg != null) {
              bloc.add(GetPlans(
                packageId: pkg.packageId,
                subscriberUuid: state.homeEntity.subscriberId,
              ));
            }
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          bloc: bloc,
          buildWhen: (prev, curr) =>
              curr is GetDataSuccess || curr is GetDataFailure,
          builder: (context, state) {
            if (state is GetDataFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColor.kFailedRed),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => bloc.add(const GetHomeData()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is GetDataSuccess) {
              final HomeEntity home = state.homeEntity;
              final PackageDetailsEntity? pkg = home.packageDetails;
              final String subscriberId = home.subscriberId;
              final String packageId = pkg?.packageId ?? '';
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 250.h,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0),
                        ),
                        child: SvgPicture.asset(
                          'assets/images/home_background.svg',
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WalletCard(home: home),
                        if (pkg != null)
                          _ComboCard(pkg: pkg, subscriberId: subscriberId),
                        const SizedBox(height: 16),
                        _QuickActions(
                          onRechargeTap: () =>
                              _showRechargeSheet(context, subscriberId),
                          onTransactionsTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.transactionHistoryPage,
                          ),
                          onInvoiceTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.invoiceListPage,
                          ),
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<HomeBloc, HomeState>(
                          bloc: bloc,
                          buildWhen: (prev, curr) => curr is GetPlansSuccess,
                          builder: (BuildContext context, HomeState state) {
                            return state is GetPlansSuccess &&
                                    state.packageEntities.isNotEmpty
                                ? _PlanChangeSection(
                                    subscriberUuid: subscriberId,
                                    currentPackageId: packageId,
                                    plans: state.packageEntities,
                                  )
                                : const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 24),
                        const _ServicesSection(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const HomeShimmer();
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
    decimalDigits: 0,
  );
  static final _dateFmt = DateFormat('dd MMM yyyy');

  // Styles — Sizer values fixed after MaterialApp.builder.
  static final _walletLabelStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
  );
  static final _balanceStyle = TextStyle(
    color: Colors.white,
    fontSize: 30.sp,
    fontWeight: FontWeight.bold,
  );
  static final _updatedStyle = TextStyle(
    color: Colors.white54,
    fontSize: 8.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
  );
  static final _topUpButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: _kYellow,
    foregroundColor: AppColor.kBlackHeadingColor,
    shape: const StadiumBorder(),
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
  static final _topUpTextStyle = TextStyle(
    fontSize: 12.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    final formattedBalance = _balanceFmt.format(home.balance);
    final formattedDate = _dateFmt.format(home.lastUpdated);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.bssSubL10n.walletBalance, style: _walletLabelStyle),
              const SizedBox(height: 4),
              Text(formattedBalance, style: _balanceStyle),
              const SizedBox(height: 4),
              Text(
                context.bssSubL10n.updatedDate(formattedDate),
                style: _updatedStyle,
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const TopupPage()),
            ),
            style: _topUpButtonStyle,
            child: Text(context.bssSubL10n.topUp, style: _topUpTextStyle),
          ),
        ],
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
  static const _avatarBg = Color(0x1A005F73); // kPrimaryColor @ 10% opacity

  // Static decorations — no new object created per build.
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
    ],
  );
  // _kYellow is a file-level const Color → this decoration is also const.
  static const _daysLeftDecoration = BoxDecoration(
    color: _kYellow,
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );

  static final _packageNameStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.3,
    fontSize: 16.sp,
    color: AppColor.kBlackHeadingColor,
  );
  static final _activeUntilStyle = TextStyle(
    color: AppColor.kTextFiledHintColor,
    fontSize: 10.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.6,
  );
  static final _daysLeftTextStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.3,
    fontSize: 12.sp,
    color: AppColor.kBlackHeadingColor,
  );

  @override
  Widget build(BuildContext context) {
    final activeUntilStr = _activeUntilFmt.format(pkg.activeUntil);
    final speedStr = '${pkg.speedMbps.toStringAsFixed(0)} Mbps';
    final amountStr = '₹${pkg.renewalFee.toStringAsFixed(0)}';
    final usageStr = (pkg.availableVolumeGb > 0 || pkg.totalVolumeGb > 0)
        ? '${pkg.availableVolumeGb.toStringAsFixed(0)} GB / ${pkg.totalVolumeGb.toStringAsFixed(0)} GB'
        : 'Unlimited';
    final addOnCount = pkg.activeAddOns.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _cardDecoration,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: _avatarBg,
                        child: const Icon(
                          Icons.language,
                          color: AppColor.kPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(pkg.packageName, style: _packageNameStyle),
                            Text(
                              context.bssSubL10n
                                  .activeUntilDate(activeUntilStr),
                              style: _activeUntilStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: _daysLeftDecoration,
                  child: Text(
                    context.bssSubL10n.daysLeft(pkg.daysLeft.toString()),
                    style: _daysLeftTextStyle,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            height: 60.h,
            decoration: const ShapeDecoration(
              color: AppColor.kSecondaryBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(label: context.bssSubL10n.amount, value: amountStr),
                _Stat(label: context.bssSubL10n.speed, value: speedStr),
                _Stat(label: context.bssSubL10n.fpu, value: pkg.packageType),
                _Stat(label: context.bssSubL10n.usage, value: usageStr),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 32.h,
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: context.bssSubL10n
                          .packsActive(addOnCount.toString()),
                      onClicked: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ActivePackagePage(subscriberUuid: subscriberId),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: context.bssSubL10n.viewUsage,
                      isLoading: false,
                      onClicked: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => DataUsageView(
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
          ),
        ],
      ),
    );
  }
}

// ─── Stat ─────────────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final String label, value;

  const _Stat({required this.label, required this.value});

  static final _labelStyle = TextStyle(
    color: AppColor.kTextFiledHintColor,
    fontSize: 10.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
  );
  static final _valueStyle = TextStyle(
    fontSize: 11.sp,
    color: AppColor.kBlackHeadingColor,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 2),
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
  static final _actionLabelStyle = TextStyle(
    color: Colors.white,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    fontSize: 12.sp,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = context.bssSubL10n;
    _actions = [
      _ActionItem(
        label: l10n.recharge,
        color: _kTeal,
        icon: 'recharge_icon.svg',
        onTap: widget.onRechargeTap,
      ),
      _ActionItem(
        label: l10n.transactions,
        color: _kOrange,
        icon: 'money_icon.svg',
        onTap: widget.onTransactionsTap,
      ),
      _ActionItem(
        label: l10n.invoice,
        color: _kRed,
        icon: 'invoice_icon.svg',
        onTap: widget.onInvoiceTap,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _actions
            .map(
              (a) => Expanded(
                child: GestureDetector(
                  onTap: a.onTap,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 110.h,
                    decoration: BoxDecoration(
                      color: a.color,
                      borderRadius: _actionRadius,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 46.h,
                          height: 46.h,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SvgPicture.asset('assets/icons/${a.icon}'),
                          ),
                        ),
                        const SizedBox(height: 10),
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
  final List<PackageEntity> plans;

  const _PlanChangeSection({
    required this.subscriberUuid,
    required this.currentPackageId,
    required this.plans,
  });

  static final _headingStyle = TextStyle(
    fontSize: 16.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    color: AppColor.kBlackHeadingColor,
  );
  static final _seeAllStyle = TextStyle(
    color: AppColor.kPrimaryColor,
    fontSize: 13.sp,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.bssSubL10n.planChange, style: _headingStyle),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ChangePlanPage(
                      subscriberUuid: subscriberUuid,
                      currentPackageId: currentPackageId,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(context.bssSubL10n.seeAll, style: _seeAllStyle),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColor.kPrimaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            for (final plan in plans)
              _PlanCard(key: ValueKey(plan.packageId), plan: plan),
          ],
        ),
      ],
    );
  }
}

// ─── Plan Card ───────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final PackageEntity plan;

  const _PlanCard({super.key, required this.plan});

  static const _avatarBg = Color(0x1A005F73); // kPrimaryColor @ 10% opacity
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
    ],
  );
  // kPrimaryColor is const → this decoration is also const.
  static const _priceDecoration = BoxDecoration(
    color: AppColor.kPrimaryColor,
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  static final _packageNameStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontSize: 14.sp,
    color: AppColor.kBlackHeadingColor,
  );
  static final _priceStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 14.sp,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _avatarBg,
                child: const Icon(
                  Icons.language,
                  color: AppColor.kPrimaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(plan.packageName, style: _packageNameStyle),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 55.h,
            padding: const EdgeInsets.all(8),
            decoration: const ShapeDecoration(
              color: AppColor.kSecondaryBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(11)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(
                    label: context.bssSubL10n.data,
                    value: '${plan.data} GB'),
                _Stat(label: context.bssSubL10n.speed, value: plan.speed),
                _Stat(label: context.bssSubL10n.fpu, value: plan.planType),
                _Stat(
                    label: context.bssSubL10n.validity,
                    value: '${plan.validity} Days'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: _priceDecoration,
                child: Text('₹ ${plan.price}', style: _priceStyle),
              ),
              SizedBox(
                height: 32.h,
                width: 145.w,
                child: SecondaryButton(
                  label: context.bssSubL10n.choosePlan,
                  onClicked: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider(
                        create: (_) => ChangePlanBloc(
                          repository: sl<ChangePlanRepository>(),
                        ),
                        child: RechargePage(package: plan),
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
    color: AppColor.kBlackHeadingColor,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = context.bssSubL10n;
    _services = [
      _ServiceItem(title: l10n.fiberToHome, icon: 'thunder.svg'),
      _ServiceItem(title: l10n.internetLeasedLine, icon: 'internet_leased_line.svg'),
      _ServiceItem(title: l10n.darkFiber, icon: 'dark_fiber.svg'),
      _ServiceItem(title: l10n.coLocation, icon: 'ip_location.svg'),
      _ServiceItem(title: l10n.wifiServices, icon: 'wifi.svg'),
      _ServiceItem(title: l10n.ott, icon: 'ott.svg'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.bssSubL10n.servicesOffered,
            style: _headingStyle,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: _services.length,
            itemBuilder: (_, i) => _ServiceCard(
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
    borderRadius: BorderRadius.all(Radius.circular(14)),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
    ],
  );
  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.5,
    fontSize: 14.sp,
    color: AppColor.kBlackHeadingColor,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _titleStyle),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset('assets/icons/$icon', height: 34.h, width: 34.w),
              const Icon(
                Icons.arrow_forward,
                color: AppColor.kTextFiledHintColor,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
