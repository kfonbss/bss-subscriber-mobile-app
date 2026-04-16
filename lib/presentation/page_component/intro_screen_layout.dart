import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/white_button.dart';

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
            child: SvgPicture.asset('assets/images/$imageName'),
          ),
          SizedBox(height: 120.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 32.h,
                width: 146.w,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.2),
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    spacing: 4,
                    children: [
                      Image.asset(
                        'assets/images/logo_round.png',
                        height: 24.h,
                        width: 24.w,
                      ),
                      Text(
                        l10n.introducingKfonApp,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w400,
                          fontSize: 10.sp,
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
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 32.h),
              Row(
                spacing: 15,
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.login,
                      ),
                      style: FilledButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 50),
                        fixedSize: const Size(double.infinity, 50),
                        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.2),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        l10n.signIn,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: WhiteButton(
                      label: index == 2 ? l10n.getStarted : l10n.next,
                      borderRadius: 50,
                      isLoading: false,
                      onClicked: nextButtonCallback,
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
