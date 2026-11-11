import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

/// White website chip shown at the bottom of the auth screens
/// (Login, Forgot Password, Verify OTP).
class WebsitePill extends StatelessWidget {
  const WebsitePill({super.key});

  @override
  Widget build(BuildContext context) {
    // Chip hugs its text (no fixed side margins that squeezed it and forced
    // the URL to wrap).
    return Center(
      child: Container(
        height: 30.h,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(23)),
        ),
        // widthFactor: 1 keeps this Center from expanding to full width;
        // only height is centred.
        child: Center(
          widthFactor: 1,
          child: Text(
            context.bssSubL10n.kerlaInternetWebsite,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              color: AppColor.kPrimaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pins [WebsitePill] to the bottom of a full-screen [Stack], clear of the
/// system navigation bar, with the same 30 bottom gap as the Login screen.
class BottomWebsitePill extends StatelessWidget {
  const BottomWebsitePill({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: 30.h),
          child: const WebsitePill(),
        ),
      ),
    );
  }
}
