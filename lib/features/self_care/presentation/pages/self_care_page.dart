import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/pages/restart_modem_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/security_settings_page.dart';
import 'package:kfon_subscriber/features/self_care/presentation/pages/connected_devices_page.dart';
import 'package:kfon_subscriber/features/self_care/presentation/pages/speed_test_page.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';

class SelfCarePage extends StatelessWidget {
  const SelfCarePage({super.key});

  // black @ 70% opacity

  // Sizer ratios are fixed after MaterialApp.builder — compute once.
  // Using static final (not const) because fontSize uses Sizer extension (.sp).

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
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const RestartModemPage(),
                    ),
                  ),
              borderRadius: _inkWellRadius,
              child: _SelfCareCard(
                heading: l10n.restartModemRefreshConnection,
                icon: AppAssets.restartModem,
              ),
            ),
            InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const SpeedTestPage(),
                    ),
                  ),
              borderRadius: _inkWellRadius,
              child: _SelfCareCard(
                heading: l10n.networkHealthCheck,
                subHeading: l10n.pingSpeedTest,
                icon: AppAssets.networkHealth,
              ),
            ),
            InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const ConnectedDevicesPage(),
                    ),
                  ),
              borderRadius: _inkWellRadius,
              child: _SelfCareCard(
                heading: l10n.deviceManagement,
                subHeading: l10n.manageYourConnectedDevices,
                icon: AppAssets.deviceManagement,
              ),
            ),
            InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder:
                          (context) => SecuritySettingsPage(
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
                icon: AppAssets.changeSsid,
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
  final String? subHeading;
  final String icon;

  const _SelfCareCard({
    required this.heading,
    this.subHeading,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Design: 1px #EAEAEA border, radius 12, no shadow; 19 gap between cards.
    return Card(
      margin: const EdgeInsets.only(bottom: 19),
      color: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColor.kinputFiledLightBorder),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
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
                    // Design: 53 circle, 10 padding → 24 icon.
                    width: 53.w,
                    height: 53.w,
                    padding: EdgeInsets.all(10.w),
                    decoration: ShapeDecoration(
                      color: AppColor.kPrimaryTint,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        icon,
                        colorFilter: ColorFilter.mode(
                          AppColor.kPrimaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          heading,
                          style: TextStyle(
                            color: AppColor.kTextSecondaryDark,
                            fontSize: 14.sp,
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w600,
                            height: 1.50,
                          ),
                        ),
                        if (subHeading != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            subHeading!,
                            style: TextStyle(
                              color: AppColor.kBlack70,
                              fontSize: 12.sp,
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w400,
                              height: 1.30,
                            ),
                          ),
                        ],
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
