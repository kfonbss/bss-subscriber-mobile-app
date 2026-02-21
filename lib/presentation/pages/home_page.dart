import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/constant/constant_dimensions.dart';
import 'package:kfon_subscriber/core/helper/bottom_sheet_helper.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/change_plan.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/pages/data_usage_view.dart';
import 'package:kfon_subscriber/features/top_up/presentation/pages/topup_page.dart';
import 'package:kfon_subscriber/presentation/pages/active_package_page.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';
import 'package:kfon_subscriber/presentation/ui_component/secondary_button.dart';

import '../page_component/recharge_bottom_sheet.dart';

const kTeal = Color(0xFF00A896);
const kOrange = Color(0xFFFF6B2C);
const kRed = Color(0xFFE84040);
const kYellow = Color(0xFFFFD600);

class HomePage extends StatelessWidget {
  HomePage({super.key});

  void _showRechargeSheet(BuildContext context) {
    BottomSheetHelper.show(
      context: context,
      title: 'Recharge',
      child: const RechargeBottomSheet(),
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
            onTap: () => Navigator.pushNamed(context, '/notification_page'),
            child: Image.asset(
              'assets/icons/notification_white.png',
              width: AppDimensions.kActionButtonSize,
              height: AppDimensions.kActionButtonSize,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 15),
          Container(
            width: 42,
            height: 42,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: NetworkImage("https://placehold.co/42x42"),
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
          height: 45.0,
          child: Image.asset(
            'assets/images/logo_white.png',
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                _WalletCard(),
                _ComboCard(),
                const SizedBox(height: 16),
                _QuickActions(
                  onRechargeTap: () => _showRechargeSheet(context),
                  onTransactionsTap:
                      () => Navigator.pushNamed(
                        context,
                        '/transaction_history_page',
                      ),
                  onInvoiceTap:
                      () => Navigator.pushNamed(context, '/invoice_page'),
                ),
                const SizedBox(height: 24),
                _PlanChangeSection(),
                const SizedBox(height: 24),
                _ServicesSection(),
                const SizedBox(height: 80),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                '₹ 38,200',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Updated 03 Nov 2025',
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
                  MaterialPageRoute<void>(
                    builder: (context) => const TopupPage(),
                  ),
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

class _ComboCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColor.kPrimaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.language,
                        color: AppColor.kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Combo Plan',
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                            fontSize: 16.sp,
                            color: AppColor.kBlackHeadingColor,
                          ),
                        ),
                        Text(
                          'Active until Aug 25, 2025',
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
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '20 Days left',
                    style: TextStyle(
                      fontFamily: 'General Sans',
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
                _Stat(label: 'Amount', value: '₹499'),
                _Stat(label: 'Speed', value: '100 Mbps'),
                _Stat(label: 'FPU', value: 'Unlimited'),
                _Stat(label: 'Usage', value: '21 GB / 100 GB'),
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
                      label: '+2 Pack Active',
                      onClicked:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const ActivePackagePage(),
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
                                  (context) => DataUsageView(
                                    subscriberUuid: 'subscriberUuid',
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

class _PlanChangeSection extends StatelessWidget {
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
                            (context) => const ChangePlanPage(
                              subscriberUuid: 'subscriberUuid',
                              currentPackageId: 'currentPackageId',
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
        _PlanCard(name: 'Internet Extra Combo Plus', price: '₹ 182'),
        const SizedBox(height: 12),
        _PlanCard(name: 'Mega Extra Plus', price: '₹ 182'),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name, price;

  const _PlanCard({required this.name, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                name,
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
                _Stat(label: 'Data', value: '100 GB'),
                _Stat(label: 'Speed', value: '100 Mbps'),
                _Stat(label: 'FPU', value: 'Unlimited'),
                _Stat(label: 'validity', value: '30 Days'),
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
                  price,
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
                child: SecondaryButton(label: 'Choose Plan', onClicked: () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
