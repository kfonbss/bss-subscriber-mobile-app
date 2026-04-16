import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/pages/restart_modem_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/security_settings_page.dart';
import 'package:kfon_subscriber/features/self_care/presentation/pages/connected_devices_page.dart';
import 'package:kfon_subscriber/features/self_care/presentation/pages/speed_test_page.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class SelfCarePage extends StatelessWidget {
  const SelfCarePage({super.key});

  static const _subHeadingColor = Color(0xB3000000); // black @ 70% opacity
  static const _iconContainerDecoration = ShapeDecoration(
    color: Color(0x0C8D0247),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
    ),
  );

  // Sizer ratios are fixed after MaterialApp.builder — compute once.
  // Using static final (not const) because fontSize uses Sizer extension (.sp).
  static final _headingStyle = TextStyle(
    color: Colors.black,
    fontSize: 14.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 1.50,
  );
  static final _subHeadingStyle = TextStyle(
    color: _subHeadingColor,
    fontSize: 12.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w400,
    height: 1.30,
  );

  // One const BorderRadius shared across all four InkWells.
  static const _inkWellRadius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return CommonAppBar(
      title: l10n.selfCareTools,
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20,
          top: 0,
          bottom: 20,
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const RestartModemPage(),
                ),
              ),
              borderRadius: _inkWellRadius,
              child: _SelfCareCard(
                heading: l10n.restartModemRefreshConnection,
                subHeading: '',
                icon: 'connected_devices.png',
                iconContainerDecoration: _iconContainerDecoration,
                headingStyle: _headingStyle,
                subHeadingStyle: _subHeadingStyle,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const SpeedTestPage(),
                ),
              ),
              borderRadius: _inkWellRadius,
              child: _SelfCareCard(
                heading: l10n.networkHealthCheck,
                subHeading: l10n.pingSpeedTest,
                icon: 'speed_test.png',
                iconContainerDecoration: _iconContainerDecoration,
                headingStyle: _headingStyle,
                subHeadingStyle: _subHeadingStyle,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const ConnectedDevicesPage(),
                ),
              ),
              borderRadius: _inkWellRadius,
              child: _SelfCareCard(
                heading: l10n.deviceManagement,
                subHeading: l10n.manageYourConnectedDevices,
                icon: 'ping.png',
                iconContainerDecoration: _iconContainerDecoration,
                headingStyle: _headingStyle,
                subHeadingStyle: _subHeadingStyle,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => SecuritySettingsPage(
                    types: [
                      PasswordChangeEnum.ssid,
                      PasswordChangeEnum.wifi,
                    ],
                  ),
                ),
              ),
              borderRadius: _inkWellRadius,
              child: _SelfCareCard(
                heading: l10n.changeSsidWifiPassword,
                subHeading: '',
                icon: 'traceroute.png',
                iconContainerDecoration: _iconContainerDecoration,
                headingStyle: _headingStyle,
                subHeadingStyle: _subHeadingStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extracted from the old static `_createOptionLayout` helper.
/// As a StatelessWidget, Flutter's reconciliation engine can track its identity
/// across rebuilds and avoid unnecessary subtree work.
class _SelfCareCard extends StatelessWidget {
  final String heading;
  final String subHeading;
  final String icon;
  final ShapeDecoration iconContainerDecoration;
  final TextStyle headingStyle;
  final TextStyle subHeadingStyle;

  const _SelfCareCard({
    required this.heading,
    required this.subHeading,
    required this.icon,
    required this.iconContainerDecoration,
    required this.headingStyle,
    required this.subHeadingStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 19),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                spacing: 16,
                children: [
                  Container(
                    width: 53.w,
                    height: 53.h,
                    padding: const EdgeInsets.all(14),
                    decoration: iconContainerDecoration,
                    child: Image.asset('assets/icons/$icon'),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(heading, style: headingStyle),
                        if (subHeading.isNotEmpty)
                          Text(subHeading, style: subHeadingStyle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColor.kMediumGrey,
              size: 16.0,
            ),
          ],
        ),
      ),
    );
  }
}
