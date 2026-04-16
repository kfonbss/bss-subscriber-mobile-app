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

  // ── Static styles ────────────────────────────────────────────────────────────
  // Sizer ratios are fixed after MaterialApp.builder — computed once.
  static final _sectionHeadingStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );
  static final _soundValueStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kPrimaryColor,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    // _notificationSound may change on user action — read once per build.
    final notificationSound = _notificationSound ?? 'Default';

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
                  Text('General', style: _sectionHeadingStyle),
                  SizedBox(height: 16.h),
                  _NotificationItem(
                    title: 'Payment Reminders',
                    description: 'Get notified about upcoming payment due dates.',
                    value: _paymentReminders,
                    onChanged: (v) => setState(() => _paymentReminders = v),
                  ),
                  _NotificationItem(
                    title: 'Package Expiry Alerts',
                    description:
                        'Receive alerts when your package is about to expire.',
                    value: _packageExpiryAlerts,
                    onChanged: (v) => setState(() => _packageExpiryAlerts = v),
                  ),
                  _NotificationItem(
                    title: 'Promotions & Offers',
                    description: 'Stay updated on the latest deals and discounts.',
                    value: _promotionsOffers,
                    onChanged: (v) => setState(() => _promotionsOffers = v),
                  ),
                  _NotificationItem(
                    title: 'Data Exhaustion Warnings',
                    description: 'Know when your data is nearing its limit.',
                    value: _dataExhaustionWarnings,
                    onChanged: (v) =>
                        setState(() => _dataExhaustionWarnings = v),
                  ),
                  SizedBox(height: 20.h),

                  // Sound & Vibration Section
                  Text('Sound & Vibration', style: _sectionHeadingStyle),
                  SizedBox(height: 16.h),

                  // Notification Sound — no Builder needed; notificationSound
                  // is a local variable read at the start of build().
                  _SoundVibrationTile(
                    title: 'Notification Sound',
                    onTap: () {
                      // TODO: Show sound selection dialog
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(notificationSound, style: _soundValueStyle),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16.w,
                          color: AppColor.kPrimaryColor,
                        ),
                      ],
                    ),
                  ),

                  _SoundVibrationTile(
                    title: 'Vibration',
                    trailing: Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: CommonToggleSwitch(
                        value: _vibration,
                        onChanged: (v) => setState(() => _vibration = v),
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

// ── Notification toggle item ──────────────────────────────────────────────────
// Extracted from _buildGeneralItem so Flutter can track each tile's identity.
class _NotificationItem extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationItem({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  static final _decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12.w)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColor.kinputFiledLightBorder, width: 1.w),
    ),
  );
  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );
  // 0xB3 = 179 ≈ 0.7 × 255 → Colors.black @ 70% opacity
  static final _descriptionStyle = TextStyle(
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
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: _decoration,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _titleStyle),
                  SizedBox(height: 6.h),
                  Text(description, style: _descriptionStyle),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: CommonToggleSwitch(value: value, onChanged: onChanged),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sound / vibration tile ────────────────────────────────────────────────────
// Extracted from _buildSoundVibrationItem so Flutter can track identity.
class _SoundVibrationTile extends StatelessWidget {
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SoundVibrationTile({
    required this.title,
    required this.trailing,
    this.onTap,
  });

  static final _decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12.w)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColor.kinputFiledLightBorder, width: 1.w),
    ),
  );
  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );
  static final _inkRadius = BorderRadius.all(Radius.circular(12.w));

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: _decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: _inkRadius,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Text(title, style: _titleStyle),
                const Spacer(),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
