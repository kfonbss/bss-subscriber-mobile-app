import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 10),
            blurRadius: 15,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -4,
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
                    color: const Color(0xFF717171),
                    fontFamily: 'General Sans',
                    height: 16.5.h / 12,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  circleName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.kPrimaryColor,
                    fontFamily: 'General Sans',
                    height: 24.h / 16,
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
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.kIconBackground,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppAssets.editPencil,
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(
                  AppColor.kPrimaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
