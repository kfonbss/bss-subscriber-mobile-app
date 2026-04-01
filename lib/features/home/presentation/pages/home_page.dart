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
import 'package:kfon_subscriber/features/active_package_details/presentation/pages/active_package_page.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';
import 'package:kfon_subscriber/presentation/ui_component/secondary_button.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_base.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_box.dart';
import 'package:kfon_subscriber/service_locator.dart';

import '../../../offline_recharge/presentation/pages/offline_recharge_bottom_sheet.dart';

const kTeal = Color(0xFF00A896);
const kOrange = Color(0xFFFF6B2C);
const kRed = Color(0xFFE84040);
const kYellow = Color(0xFFFFD600);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read<HomeBloc>();
    bloc.add(GetHomeData());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showRechargeSheet(BuildContext context,String subscriberId) {
    BottomSheetHelper.show(
      context: context,
      title: 'Recharge',
      child:  OfflineRechargeBottomSheet(subscriberUuid: subscriberId,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kMainBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.kToolbarBackground,
        toolbarHeight: AppDimensions.kDefaultToolbarHeights,
        actionsPadding: EdgeInsets.only(right: 15),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.notificationPage),
            child: Image.asset(
              'assets/icons/notification_white.png',
              width: AppDimensions.kActionButtonSize,
              height: AppDimensions.kActionButtonSize,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 15),
          Container(
            width: 42.w,
            height: 42.h,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPrsHSSBc63zNawuN6LUuXgj58de3ciuETGw&s",
                ),
                fit: BoxFit.cover,
              ),
              shape: OvalBorder(
                side: BorderSide(
                  width: 3,
                  strokeAlign: BorderSide.strokeAlignOutside,
                  color: Colors.white,
                ),
              ),
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
        listenWhen: (prev, curr) => curr is GetDataFailure,
        listener: (context, state) {
          if (state is GetDataFailure) {
            DialogUtil().showMessage(state.errorMessage, context);
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          bloc: bloc,
          buildWhen: (prev, curr) => curr is GetDataSuccess,
          builder: (context, state) {
            if (state is GetDataSuccess) {
              final HomeEntity balance = state.homeEntity;
              final PackageDetailsEntity? pkg = balance.packageDetails;
              final String subscriberId = balance.subscriberId;
              bloc.add(GetPlans(packageId: pkg!.packageId, subscriberUuid: subscriberId));
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 250,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
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
                        _WalletCard(balance: balance),
                        if (pkg != null)
                          _ComboCard(pkg: pkg, subscriberId: subscriberId),
                        const SizedBox(height: 16),
                        _QuickActions(
                          onRechargeTap: () => _showRechargeSheet(context,subscriberId),
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
                        const SizedBox(height: 24),
                        BlocBuilder<HomeBloc, HomeState>(
                          bloc: bloc,
                          buildWhen: (prev, curr) => curr is GetPlansSuccess,
                          builder: (BuildContext context, HomeState state) {
                            return state is GetPlansSuccess &&
                                    state.packageEntities.isNotEmpty
                                ? _PlanChangeSection(
                                  subscriberUuid: subscriberId,
                                  currentPackageId: pkg.packageId,
                                  plans: state.packageEntities,
                                )
                                : SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 24),
                        _ServicesSection(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ],
                ),
              );
            }
            return HomeShimmer();
          },
        ),
      ),
    );
  }
}

// ─── Wallet Card ─────────────────────────────────────────────────────────────

class _WalletCard extends StatelessWidget {
  final HomeEntity balance;

  const _WalletCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    // Format: ₹ 38,200
    final formattedBalance =
        '₹ ${balance.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    // Format: Updated 09 Mar 2026
    final formattedDate = DateFormat('dd MMM yyyy').format(balance.lastUpdated);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallet Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedBalance,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Updated $formattedDate',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 8.sp,
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const TopupPage()),
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kYellow,
              foregroundColor: AppColor.kBlackHeadingColor,
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Top up',
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    final activeUntilStr = DateFormat('MMM dd, yyyy').format(pkg.activeUntil);
    final speedStr = '${pkg.speedMbps.toStringAsFixed(0)} Mbps';
    final amountStr = '₹${pkg.renewalFee.toStringAsFixed(0)}';
    final usageStr =
        (pkg.availableVolumeGb > 0 || pkg.totalVolumeGb > 0)
            ? '${pkg.availableVolumeGb.toStringAsFixed(0)} GB / ${pkg.totalVolumeGb.toStringAsFixed(0)} GB'
            : 'Unlimited';
    final addOnCount = pkg.activeAddOns.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
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
                        backgroundColor: AppColor.kPrimaryColor.withOpacity(
                          0.1,
                        ),
                        child: Icon(
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
                            Text(
                              pkg.packageName, // ← entity
                              style: TextStyle(
                                fontFamily: 'General Sans',
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                                fontSize: 16.sp,
                                color: AppColor.kBlackHeadingColor,
                              ),
                            ),
                            Text(
                              'Active until $activeUntilStr', // ← entity
                              style: TextStyle(
                                color: AppColor.kTextFiledHintColor,
                                fontSize: 10.sp,
                                fontFamily: 'General Sans',
                                fontWeight: FontWeight.w500,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${pkg.daysLeft} Days left', // ← entity
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      fontSize: 12.sp,
                      color: AppColor.kBlackHeadingColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            height: 60.h,
            decoration: ShapeDecoration(
              color: const Color(0xFFF5F5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(label: 'Amount', value: amountStr), // ← renewalFee
                _Stat(label: 'Speed', value: speedStr), // ← speedMbps
                _Stat(label: 'FPU', value: pkg.packageType), // ← packageType
                _Stat(label: 'Usage', value: usageStr), // ← volume fields
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
                      label: '+$addOnCount Pack Active',
                      // ← activeAddOns.length
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'View Usage',
                      isLoading: false,
                      onClicked:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder:
                                  (_) => DataUsageView(
                                    subscriberUuid: pkg.packageId,
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
                                      totalVolumeGb: pkg.totalPackageCount,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColor.kTextFiledHintColor,
            fontSize: 10.sp,
            fontFamily: 'General Sans',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColor.kBlackHeadingColor,
            fontFamily: 'General Sans',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Quick Actions ───────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final VoidCallback onRechargeTap;
  final VoidCallback onTransactionsTap;
  final VoidCallback onInvoiceTap;

  const _QuickActions({
    super.key,
    required this.onRechargeTap,
    required this.onTransactionsTap,
    required this.onInvoiceTap,
  });

  List<Map<String, dynamic>> get _actions => [
    {
      'label': 'Recharge',
      'color': kTeal,
      'icon': 'recharge_icon.svg',
      'onTap': onRechargeTap,
    },
    {
      'label': 'Transactions',
      'color': kOrange,
      'icon': 'money_icon.svg',
      'onTap': onTransactionsTap,
    },
    {
      'label': 'Invoice',
      'color': kRed,
      'icon': 'invoice_icon.svg',
      'onTap': onInvoiceTap,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children:
            _actions
                .map(
                  (a) => Expanded(
                    child: GestureDetector(
                      onTap: a['onTap'] as VoidCallback,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        height: 110.h,
                        decoration: BoxDecoration(
                          color: a['color'] as Color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 46.h,
                              height: 46.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SvgPicture.asset(
                                  'assets/icons/${a['icon']}',
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              a['label'] as String,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'General Sans',
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                              ),
                            ),
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
              Text(
                'Plan Change',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w600,
                  color: AppColor.kBlackHeadingColor,
                ),
              ),
              TextButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder:
                            (_) => ChangePlanPage(
                              subscriberUuid: subscriberUuid,
                              currentPackageId: currentPackageId,
                            ),
                      ),
                    ),
                child: Row(
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        color: AppColor.kPrimaryColor,
                        fontSize: 13.sp,
                      ),
                    ),
                    Icon(
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
        if (plans.isNotEmpty)
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: plans.length,
            itemBuilder: (context, index) {
              return _PlanCard(
                plan: plans[index],
                subscriberUuid: subscriberUuid,
                currentPackageId: currentPackageId,
              );
            },
          ),
      ],
    );
  }
}

// ─── Plan Card ───────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final PackageEntity plan;
  final String subscriberUuid;
  final String currentPackageId;

  const _PlanCard({
    required this.plan,
    required this.subscriberUuid,
    required this.currentPackageId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColor.kPrimaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.language,
                  color: AppColor.kPrimaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                plan.packageName,
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  fontSize: 14.sp,
                  color: AppColor.kBlackHeadingColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 55.h,
            padding: EdgeInsets.all(8),
            decoration: ShapeDecoration(
              color: const Color(0xFFF5F5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(label: 'Data', value: '${plan.data} GB'),
                _Stat(label: 'Speed', value: plan.speed),
                _Stat(label: 'FPU', value: plan.planType),
                _Stat(label: 'Validity', value: '${plan.validity} Days'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.kPrimaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₹ ${plan.price}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(
                height: 32.h,
                width: 145.w,
                child: SecondaryButton(
                  label: 'Choose Plan',
                  onClicked: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder:
                            (_) => BlocProvider.value(
                              value: ChangePlanBloc(
                                repository: sl<ChangePlanRepository>(),
                              ),
                              child: RechargePage(
                                package: PackageEntity(
                                  packageId: plan.packageId,
                                  packageName: plan.packageName,
                                  price: plan.price,
                                  speed: plan.speed,
                                  data: plan.data,
                                  validity: plan.validity,
                                  planType: plan.planType,
                                ),
                              ),
                            ),
                      ),
                    );
                  },
                  // () => Navigator.push(
                  //   context,
                  //   MaterialPageRoute<void>(
                  //     builder:
                  //         (_) => ChangePlanPage(
                  //           subscriberUuid: subscriberUuid,
                  //           currentPackageId: currentPackageId,
                  //         ),
                  //   ),
                  // ),
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

class _ServicesSection extends StatelessWidget {
  final _services = const [
    {'title': 'Fiber to Home\n(FTTH)', 'icon': 'thunder.svg'},
    {
      'title': 'Internet Leased\nline (IIL)',
      'icon': 'internet_leased_line.svg',
    },
    {'title': 'Dark Fiber for\nLeased (DFL)', 'icon': 'dark_fiber.svg'},
    {'title': 'Co-Location', 'icon': 'ip_location.svg'},
    {'title': 'WiFi Services', 'icon': 'wifi.svg'},
    {'title': 'Over-the-Top\n(OTT)', 'icon': 'ott.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Services Offered',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'General Sans',
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: AppColor.kBlackHeadingColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: _services.length,
            itemBuilder:
                (_, i) => _ServiceCard(
                  title: _services[i]['title'] as String,
                  icon: _services[i]['icon'] as String,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'General Sans',
              fontWeight: FontWeight.w500,
              height: 1.5,
              fontSize: 14.sp,
              color: AppColor.kBlackHeadingColor,
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset('assets/icons/$icon', height: 34.h, width: 34.w),
              Icon(
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
