
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/about_app_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/about_kfon_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/app_update_check_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/language_selection_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/notification_settings_page.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: l10n.settings,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 50.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsItem(
                    title: l10n.language,
                    iconPath: 'assets/icons/languages.svg',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageSelectionPage(),
                      ),
                    ),
                  ),
                  _SettingsItem(
                    title: l10n.notificationsSettings,
                    iconPath: 'assets/icons/notification_settings.svg',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationSettingsPage(),
                      ),
                    ),
                  ),
                  _SettingsItem(
                    title: l10n.appUpdateCheck,
                    iconPath: 'assets/icons/app_update_check.svg',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppUpdateCheckPage(),
                      ),
                    ),
                  ),
                  _SettingsItem(
                    title: l10n.aboutApp,
                    iconPath: 'assets/icons/about_app.svg',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutAppPage(),
                      ),
                    ),
                  ),
                  _SettingsItem(
                    title: l10n.aboutKfonTitle,
                    iconPath: 'assets/icons/about_kfon.svg',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutKfonPage(),
                      ),
                    ),
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

// ── Settings list item ────────────────────────────────────────────────────────
// Extracted from the _buildSettingsItem instance helper so Flutter can track
// each tile's identity and skip rebuilds independently.
class _SettingsItem extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  // Sizer ratios and Sizer.isTablet are fixed after MaterialApp.builder —
  // computed once as static final, eliminating the inner Builder entirely.
  static final double _containerSize =
      Sizer.isTablet ? 32.0 * 1.2 : 32.w;
  static final double _iconSize =
      Sizer.isTablet ? 18.0 * 1.2 : 18.w;
  static final BorderRadius _itemRadius =
      BorderRadius.all(Radius.circular(12.w));
  static final BoxDecoration _itemDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: _itemRadius,
    border: Border.fromBorderSide(
      BorderSide(color: AppColor.kinputFiledLightBorder, width: 1.w),
    ),
  );
  // kPrimaryColor(0xFF8D0247) @ 5% opacity: 0x0D8D0247
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 17.h),
      decoration: _itemDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: _itemRadius,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 9.w),
            child: Row(
              children: [
                Container(
                  width: _containerSize,
                  height: _containerSize,
                  decoration: _iconBgDecoration,
                  child: Center(
                    child: SvgPicture.asset(
                      iconPath,
                      width: _iconSize,
                      height: _iconSize,
                      colorFilter: _iconColorFilter,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(child: Text(title, style: _titleStyle)),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.w,
                  color: AppColor.kMediumGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
