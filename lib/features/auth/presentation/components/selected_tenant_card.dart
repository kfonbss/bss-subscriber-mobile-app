import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

class SelectedTenantCard extends StatelessWidget {
  final String circleName;
  final VoidCallback onEdit;

  const SelectedTenantCard({
    super.key,
    required this.circleName,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.kLightBorderGrey),
        boxShadow: const [
          BoxShadow(
            color: AppColor.kBlack10,
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColor.kBlack10,
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Text section ──────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.bssSubL10n.selectedCircle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.kLabelGrey,
                    fontFamily: 'GeneralSans',
                    height: 1.38,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  circleName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.kPrimaryColor,
                    fontFamily: 'GeneralSans',
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),

          // ── Edit button ───────────────────────────
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColor.kIconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 20.sp,
                color: AppColor.kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
