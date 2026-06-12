import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:flutter/material.dart';

class SelectedTenantCard extends StatelessWidget {
  final String   circleName;
  final VoidCallback onEdit;

  const SelectedTenantCard({
    super.key,
    required this.circleName,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          // ── Text section ──────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECTED CIRCLE',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 0.5,
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
                  ),
                ),
              ],
            ),
          ),

          // ── Edit button ───────────────────────────
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 16.sp,
                color: AppColor.kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}