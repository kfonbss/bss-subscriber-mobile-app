import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/features/profile/domain/entity/profile_entity.dart';
import 'package:kfon_subscriber/shared/widgets/tenant_svg_color_mapper.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:flutter_svg/svg.dart';

class VerificationSuccessSheet extends StatelessWidget {
  const VerificationSuccessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Drag handle area (36) + 20 = illustration at 56 from the sheet top.
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture(
            SvgAssetLoader(
              AppAssets.accountVerified,
              colorMapper: TenantSvgColorMapper(),
            ),
            width: 140.w,
            height: 140.w,
          ),
          SizedBox(height: 24.h),

          // Title
          Text(
            context.bssSubL10n.accountVerified,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.kTextSecondaryDark,
              fontFamily: 'General Sans',
              height: 1.3.h,
            ),
          ),

          SizedBox(height: 4.h),

          // Description
          Text(
            context.bssSubL10n.accountVerifiedMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppColor.kTextFiledPlaceholderColor,
              fontFamily: 'General Sans',
              height: 1.6.h,
            ),
          ),

          SizedBox(height: 32.h),

          // Start Now Button
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: context.bssSubL10n.startNow,
              borderRadius: 10,
              height: 52.h,
              isLoading: false,
              textStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'General Sans',
                height: 1.3.h,
              ),
              onClicked: () {
                Navigator.of(context).pop(); // Close bottom sheet
                Navigator.pushReplacementNamed(context, AppRoutes.mainPage);
              },
            ),
          ),
        ],
      ),
    );
  }
}
