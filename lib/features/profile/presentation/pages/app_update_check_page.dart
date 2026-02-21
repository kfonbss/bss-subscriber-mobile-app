import 'package:kfon_subscriber/core/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';

class AppUpdateCheckPage extends StatefulWidget {
  const AppUpdateCheckPage({super.key});

  @override
  State<AppUpdateCheckPage> createState() => _AppUpdateCheckPageState();
}

class _AppUpdateCheckPageState extends State<AppUpdateCheckPage> {
  String _appVersion = '1.23.121'; // Current app version
  bool _isChecking = false;

  // TODO: Load actual app version from package_info_plus or pubspec.yaml
  // For now using hardcoded version

  Future<void> _checkForUpdate() async {
    setState(() {
      _isChecking = true;
    });

    // Simulate API call to check for updates
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isChecking = false;
      // TODO: Update _isUpToDate based on API response
      // If update is available, show different message in the UI
    });

    // TODO: Implement actual update check logic
    // This would typically call an API to check for new versions
  }

  Widget _buildInfoCard({required String title, required String subtitle}) {
    return Container(
      height: 77.h,
      margin: EdgeInsets.only(bottom: 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1.w),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Builder(
              builder: (context) {
                double containerSize;
                double iconSize;
                if (context.isTablet) {
                  containerSize = 53.0 * 1.2; // ~64px on tablets
                  iconSize = 18.0 * 1.2; // ~22px on tablets
                } else {
                  containerSize = 53.w;
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
                      'assets/icons/app_update_check.svg',
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
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                      letterSpacing: 0,
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

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'App Update Check',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Version Section
                  Text(
                    'Current Version',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      color: const Color(0xFF0F1121),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildInfoCard(
                    title: 'App Version',
                    subtitle: 'Version ${_appVersion}',
                  ),
                  SizedBox(height: 5.h),
                  // Update Status Section
                  Text(
                    'Update Status',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      color: const Color(0xFF0F1121),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildInfoCard(
                    title: 'Up to Date',
                    subtitle: 'No new updates available',
                  ),
                  SizedBox(height: 22.h),
                  // Informational text
                  Center(
                    child: SizedBox(
                      width: 236.w,
                      child: Text(
                        'Your app is up to date. We will notify you when a new version is avaliable.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 22.h),
                  // Check For Update Button
                  PrimaryButton(
                    label: 'Check For Update',
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
