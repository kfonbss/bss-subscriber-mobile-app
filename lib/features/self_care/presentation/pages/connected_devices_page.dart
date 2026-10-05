import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';

class ConnectedDevicesPage extends StatelessWidget {
  const ConnectedDevicesPage({super.key});

  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.30,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: l10n.deviceManagement,
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20,
          top: 0,
          bottom: 20,
        ),
        child: Column(
          spacing: 20, // Design: 20 from section title to first card.
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(l10n.connectedDevices, style: _titleStyle),
                Image.asset(
                  AppAssets.refresh,
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            // ListView.builder(itemCount: 1) was pointless overhead — a single
            // static list of cards doesn't benefit from virtualization.
            // SingleChildScrollView + Column gives the same scroll behaviour
            // without the builder indirection.
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _DeviceCard(
                      heading: 'Living Room TV',
                      subHeading: '2 mins ago',
                      icon: AppAssets.tv,
                    ),
                    _DeviceCard(
                      heading: 'My Phone',
                      subHeading: '2 mins ago',
                      icon: AppAssets.mobileTwo,
                    ),
                    _DeviceCard(
                      heading: 'IQOO Neo 9 Pro',
                      subHeading: '2 mins ago',
                      icon: AppAssets.mobileTwo,
                    ),
                    _DeviceCard(
                      heading: 'Kfon Laptop',
                      subHeading: '2 mins ago',
                      icon: AppAssets.laptop,
                    ),
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

/// Extracted from the old `_createOptionLayout` helper method.
/// As a StatelessWidget, Flutter's reconciliation engine can track its identity
/// and skip rebuilds when [heading], [subHeading], and [icon] haven't changed.
/// Helper methods returning Widget always force a full subtree rebuild.
class _DeviceCard extends StatelessWidget {
  final String heading;
  final String subHeading;
  final String icon;

  const _DeviceCard({
    required this.heading,
    required this.subHeading,
    required this.icon,
  });

  // Hoisted — ShapeDecoration was being allocated on every build() call per
  // visible card. const eliminates the heap allocation entirely.
  static get _iconContainerDecoration => ShapeDecoration(
    color: AppColor.kPrimaryTint,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
    ),
  );

  // 0.70 × 255 = 178.5 → 179 = 0xB3
  static const _subHeadingColor = AppColor.kBlack70;

  static final _headingStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.30,
  );
  static final _subHeadingStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: _subHeadingColor,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.30,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    // Design: white, radius 12, no shadow; 13 gap between cards.
    return Card(
      margin: EdgeInsets.only(bottom: 13.h),
      color: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 12.w,
              children: [
                // Design: 53 circle with a 22 icon.
                Container(
                  width: 53.w,
                  height: 53.w,
                  alignment: Alignment.center,
                  decoration: _iconContainerDecoration,
                  child: SvgPicture.asset(
                    icon,
                    width: 22.w,
                    height: 22.w,
                    colorFilter: ColorFilter.mode(
                      AppColor.kPrimaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(heading, style: _headingStyle),
                    Text(l10n.lastSync(subHeading), style: _subHeadingStyle),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
