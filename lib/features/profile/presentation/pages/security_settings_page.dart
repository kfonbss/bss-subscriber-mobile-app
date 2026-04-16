import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/change_password_page.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

enum PasswordChangeEnum { bss, internet, ssid, wifi }

class SecuritySettingsPage extends StatelessWidget {
  final List<PasswordChangeEnum> types;

  const SecuritySettingsPage({super.key, required this.types});

  static String _getLabel(PasswordChangeEnum type) {
    return switch (type) {
      PasswordChangeEnum.bss      => 'Change BSS Portal Password',
      PasswordChangeEnum.internet => 'Change Internet Password',
      PasswordChangeEnum.ssid     => 'Change SSID Password',
      PasswordChangeEnum.wifi     => 'Change WiFi Password',
    };
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'Security Settings',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: types
              .map(
                (type) => _SecurityItem(
                  label: _getLabel(type),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangePasswordPage(type: type),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ── Security settings tile ────────────────────────────────────────────────────
// Extracted from _getCreateItem instance helper so Flutter can track identity.
class _SecurityItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecurityItem({required this.label, required this.onTap});

  // All values are literal doubles — no Sizer — so this can be static const.
  static const _decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColor.kinputFiledLightBorder, width: 1),
    ),
  );
  static const _contentPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  // fontSize: 14.sp uses Sizer — static final, computed once.
  static final _labelStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    fontSize: 14.sp,
    height: 1.3,
    color: AppColor.kTextSecondaryDark,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 17.h),
        padding: _contentPadding,
        decoration: _decoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label, style: _labelStyle),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: AppColor.kSlateGrey,
            ),
          ],
        ),
      ),
    );
  }
}
