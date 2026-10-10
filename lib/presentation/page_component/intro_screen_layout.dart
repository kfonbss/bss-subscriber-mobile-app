import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/app_brand.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/white_button.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';

class IntroScreenLayout extends StatelessWidget {
  final int index;
  final String imageName;
  final String heading;
  final String description;
  final VoidCallback nextButtonCallback;

  const IntroScreenLayout({
    super.key,
    required this.index,
    required this.imageName,
    required this.heading,
    required this.description,
    required this.nextButtonCallback,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 75.0),
            child: SvgPicture.asset(imageName),
          ),
          SizedBox(height: 120.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColor.kIntroAccent,
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 4.h, 12.w, 4.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6.w,
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Image.asset(
                          AppAssets.introRoundLogo,
                          width: 9.w,
                          height: 16.h,
                        ),
                      ),
                      Text(
                        l10n.introducingApp(AppBrand.appName),
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w400,
                          fontSize: 10.sp,
                          height: 1.60,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                heading,
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 24.sp,
                  height: 1.30,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  height: 1.60,
                  color: AppColor.kWhite80,
                ),
              ),
              SizedBox(height: 32.h),
              Row(
                spacing: 15.w,
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: l10n.signIn,
                      isLoading: false,
                      borderRadius: 50,
                      height: 52.h,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      textStyle: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.30,
                      ),
                      onClicked: () {
                        PreferenceUtils.setIntroScreenStatus(false);
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    // Tight height overrides WhiteButton's default 50.
                    child: SizedBox(
                      height: 52.h,
                      child: WhiteButton(
                        label: index == 2 ? l10n.getStarted : l10n.next,
                        borderRadius: 50,
                        textColor: AppColor.kTextSecondaryDark,
                        isLoading: false,
                        onClicked: nextButtonCallback,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ],
      ),
    );
  }
}
