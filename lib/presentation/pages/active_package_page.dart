import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/presentation/page_component/package_info_card.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class ActivePackagePage extends StatelessWidget {
  const ActivePackagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      title: 'Active Package',
      onBackPressed: () => Navigator.of(context).pop(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PackageInfoCard(),
            SizedBox(height: 24.h),

            Text(
              'Active Add-ons',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.kTextSecondaryDark,
              ),
            ),
            SizedBox(height: 12.h),
            const _AddOnTile(
              title: '+OTT Package   ₹399',
              subtitle: 'OTT Recharge',
            ),
            SizedBox(height: 10.h),
            const _AddOnTile(
              title: '+100 GB Data   ₹199',
              subtitle: 'For Heavy usage',
            ),
          ],
        ),
      ),
    );
  }
}





class _AddOnTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AddOnTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: const BoxDecoration(
              color: AppColor.kPrimaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.language_rounded,
              size: 24.w,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.kTextSecondaryDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColor.kTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColor.kCompletedGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Active',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.kCompletedGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
