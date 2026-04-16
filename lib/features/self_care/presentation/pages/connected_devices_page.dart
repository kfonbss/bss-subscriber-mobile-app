import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class ConnectedDevicesPage extends StatelessWidget {
  const ConnectedDevicesPage({super.key});

  static final _titleStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.40,
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
          spacing: 18,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(l10n.connectedDevices, style: _titleStyle),
                Image.asset(
                  'assets/icons/refresh.png',
                  width: 20,
                  height: 20,
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
                      icon: 'tv.png',
                    ),
                    _DeviceCard(
                      heading: 'My Phone',
                      subHeading: '2 mins ago',
                      icon: 'mobile_two.png',
                    ),
                    _DeviceCard(
                      heading: 'IQOO Neo 9 Pro',
                      subHeading: '2 mins ago',
                      icon: 'mobile_two.png',
                    ),
                    _DeviceCard(
                      heading: 'Kfon Laptop',
                      subHeading: '2 mins ago',
                      icon: 'laptop.png',
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
  static const _iconContainerDecoration = ShapeDecoration(
    color: Color(0x0C8D0247),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
    ),
  );

  // 0.70 × 255 = 178.5 → 179 = 0xB3
  static const _subHeadingColor = Color(0xB3000000);

  static final _headingStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.30,
  );
  static final _subHeadingStyle = TextStyle(
    color: _subHeadingColor,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.30,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 16,
              children: [
                Container(
                  width: 53.w,
                  height: 53.h,
                  padding: const EdgeInsets.all(14),
                  decoration: _iconContainerDecoration,
                  child: Image.asset('assets/icons/$icon'),
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
            const Icon(Icons.more_vert, color: AppColor.kMediumGrey, size: 16.0),
          ],
        ),
      ),
    );
  }
}
