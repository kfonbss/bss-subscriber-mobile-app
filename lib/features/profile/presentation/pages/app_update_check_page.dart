import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';

class AppUpdateCheckPage extends StatefulWidget {
  const AppUpdateCheckPage({super.key});

  @override
  State<AppUpdateCheckPage> createState() => _AppUpdateCheckPageState();
}

class _AppUpdateCheckPageState extends State<AppUpdateCheckPage> {
  final String _appVersion = '1.23.121';
  bool _isChecking = false;

  // ── Static styles ────────────────────────────────────────────────────────────
  static final _sectionHeadingStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );
  // 0xB3 = 179 ≈ 0.7 × 255 → Colors.black @ 70% opacity
  static final _infoTextStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: const Color(0xB3000000),
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
  );

  Future<void> _checkForUpdate() async {
    setState(() => _isChecking = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: l10n.appUpdateCheck,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.currentVersion, style: _sectionHeadingStyle),
                  SizedBox(height: 16.h),
                  _InfoCard(
                    title: l10n.appVersion,
                    subtitle: l10n.versionLabel(_appVersion),
                  ),
                  SizedBox(height: 5.h),
                  Text(l10n.updateStatus, style: _sectionHeadingStyle),
                  SizedBox(height: 16.h),
                  _InfoCard(
                    title: l10n.upToDate,
                    subtitle: l10n.noNewUpdatesAvailable,
                  ),
                  SizedBox(height: 22.h),
                  Center(
                    child: SizedBox(
                      width: 236.w,
                      child: Text(
                        l10n.appIsUpToDateMessage,
                        textAlign: TextAlign.center,
                        style: _infoTextStyle,
                      ),
                    ),
                  ),
                  SizedBox(height: 22.h),
                  PrimaryButton(
                    label: l10n.checkForUpdate,
                    isLoading: _isChecking,
                    onClicked: _checkForUpdate,
                    borderRadius: 10,
                    height: 52.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────
// Extracted from _buildInfoCard. The inner Builder (for tablet sizing) is
// replaced with static finals — Sizer.isTablet is fixed after MaterialApp.
class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoCard({required this.title, required this.subtitle});

  static final double _containerSize =
      Sizer.isTablet ? 53.0 * 1.2 : 53.w;
  static final double _iconSize =
      Sizer.isTablet ? 18.0 * 1.2 : 18.w;
  static final _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12.w)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColor.kinputFiledLightBorder, width: 1.w),
    ),
  );
  // kPrimaryColor(0xFF8D0247) @ 5%: 0x0D8D0247
  static const _iconBgDecoration = BoxDecoration(
    color: Color(0x0D8D0247),
    shape: BoxShape.circle,
  );
  static const _iconColorFilter =
      ColorFilter.mode(AppColor.kPrimaryColor, BlendMode.srcIn);
  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );
  // 0xB3 = 179 ≈ 0.7 × 255 → Colors.black @ 70% opacity
  static final _subtitleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: const Color(0xB3000000),
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 77.h,
      margin: EdgeInsets.only(bottom: 22.h),
      decoration: _cardDecoration,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: _containerSize,
              height: _containerSize,
              decoration: _iconBgDecoration,
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/app_update_check.svg',
                  width: _iconSize,
                  height: _iconSize,
                  colorFilter: _iconColorFilter,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _titleStyle),
                  SizedBox(height: 6.h),
                  Text(subtitle, style: _subtitleStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
