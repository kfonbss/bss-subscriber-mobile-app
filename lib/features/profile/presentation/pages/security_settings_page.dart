import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/change_password_page.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';


class SecuritySettingsPage extends StatelessWidget {
  const SecuritySettingsPage({super.key});

  Widget _createListItems(String label) {
    return Container(
      margin: EdgeInsets.only(bottom: 17.h),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'General Sans',
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              height: 1.3,
              color: const Color(0xFF0F1121),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: const Color(0xFF67697A),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'Security Settings',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const ChangePasswordPage(isBssRequest: true),
                ),
              ),
              child: _createListItems('Change BSS Portal Password'),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const ChangePasswordPage(isBssRequest: false),
                ),
              ),
              child: _createListItems('Change Internet Password'),
            ),
          ],
        ),
      ),
    );
  }
}
