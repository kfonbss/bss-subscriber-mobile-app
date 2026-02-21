import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/profile/presentation/components/common_toggle_switch.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _paymentReminders = false;
  bool _packageExpiryAlerts = false;
  bool _promotionsOffers = false;
  bool _dataExhaustionWarnings = false;
  bool _vibration = false;
  String? _notificationSound;

  Widget _buildToggleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CommonToggleSwitch(value: value, onChanged: onChanged);
  }

  Widget _buildGeneralItem({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      height: 77.h,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1.w),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
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
                    description,
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
            SizedBox(width: 12.w),
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: _buildToggleSwitch(value: value, onChanged: onChanged),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundVibrationItem({
    required String title,
    required Widget trailing,
  }) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1.w),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: title == 'Notification Sound'
              ? () {
                  // TODO: Show sound selection dialog
                }
              : null,
          borderRadius: BorderRadius.circular(12.w),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
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
                const Spacer(),
                trailing,
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
      title: 'Notification Settings',
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
                  // General Section
                  Text(
                    'General',
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
                  _buildGeneralItem(
                    title: 'Payment Reminders',
                    description: 'Get notified about upcoming payment due dates.',
                    value: _paymentReminders,
                    onChanged: (value) {
                      setState(() {
                        _paymentReminders = value;
                      });
                    },
                  ),
                  _buildGeneralItem(
                    title: 'Package Expiry Alerts',
                    description:
                        'Receive alerts when your package is about to expire.',
                    value: _packageExpiryAlerts,
                    onChanged: (value) {
                      setState(() {
                        _packageExpiryAlerts = value;
                      });
                    },
                  ),
                  _buildGeneralItem(
                    title: 'Promotions & Offers',
                    description: 'Stay updated on the latest deals and discounts.',
                    value: _promotionsOffers,
                    onChanged: (value) {
                      setState(() {
                        _promotionsOffers = value;
                      });
                    },
                  ),
                  _buildGeneralItem(
                    title: 'Data Exhaustion Warnings',
                    description: 'Know when your data is nearing its limit.',
                    value: _dataExhaustionWarnings,
                    onChanged: (value) {
                      setState(() {
                        _dataExhaustionWarnings = value;
                      });
                    },
                  ),
                  SizedBox(height: 20.h),
                  // Sound & Vibration Section
                  Text(
                    'Sound & Vibration',
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
                  Builder(
                    builder: (context) {
                      final notificationSound =
                          _notificationSound ?? 'Default';
                      return _buildSoundVibrationItem(
                        title: 'Notification Sound',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              notificationSound,
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                color: AppColor.kPrimaryColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                height: 1.3,
                                letterSpacing: 0,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16.w,
                              color: AppColor.kPrimaryColor,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _buildSoundVibrationItem(
                    title: 'Vibration',
                    trailing: Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: _buildToggleSwitch(
                        value: _vibration,
                        onChanged: (value) {
                          setState(() {
                            _vibration = value;
                          });
                        },
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
