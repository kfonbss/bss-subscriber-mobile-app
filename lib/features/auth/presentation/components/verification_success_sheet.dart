import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/shared/widgets/tenant_svg_color_mapper.dart';

class VerificationSuccessSheet extends StatelessWidget {
  const VerificationSuccessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Design (375 wide sheet): illustration at 56 from the sheet top (the
    // common sheet's drag handle takes ~36), button 20px from the sides,
    // text 28px from the sides.
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Icon
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
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              height: 1.30,
              color: AppColor.kTextSecondaryDark,
            ),
          ),

          SizedBox(height: 4.h),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              context.bssSubL10n.accountVerifiedMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppColor.kTextFiledPlaceholderColor,
                height: 1.60,
              ),
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
              textStyle: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                height: 1.30,
              ),
              isLoading: false,
              onClicked: () {
                // Clear login / OTP from the stack so the main page has
                // no back button and Android back doesn't return to login.
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.mainPage, (route) => false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
