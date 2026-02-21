
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/extensions.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/about_app_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/about_kfon_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/app_update_check_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/language_selection_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/notification_settings_page.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _buildSettingsItem({
    required String title,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 17.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1.w),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.w),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 9.w),
            child: Row(
              children: [
                Builder(
                  builder: (context) {
                    double containerSize;
                    double iconSize;
                    if (context.isTablet) {
                      containerSize = 32.0 * 1.2; // ~38px on tablets
                      iconSize = 18.0 * 1.2; // ~22px on tablets
                    } else {
                      containerSize = 32.w;
                      iconSize = 18.w;
                    }
                    return Container(
                      width: containerSize,
                      height: containerSize,
                      decoration: BoxDecoration(
                        color: AppColor.kPrimaryColor.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          iconPath,
                          width: iconSize,
                          height: iconSize,
                          colorFilter: const ColorFilter.mode(
                            AppColor.kPrimaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      color: const Color(0xFF0F1121),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.w,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'Settings',
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
                  _buildSettingsItem(
                    title: 'Language',
                    iconPath: 'assets/icons/languages.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageSelectionPage(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    title: 'Notifications Settings',
                    iconPath: 'assets/icons/notification_settings.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationSettingsPage(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    title: 'App Update Check',
                    iconPath: 'assets/icons/app_update_check.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppUpdateCheckPage(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    title: 'About App',
                    iconPath: 'assets/icons/about_app.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutAppPage(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    title: 'About KFON',
                    iconPath: 'assets/icons/about_kfon.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutKfonPage(),
                        ),
                      );
                    },
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
