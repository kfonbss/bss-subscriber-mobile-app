import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

/// Reusable widget for help option cards (icon + label)
class HelpOptionCard extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;
  final double containerWidth;

  const HelpOptionCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.containerWidth = 98,
  });

  static const _shadowColor = AppColor.kCardShadow; // black @ 6% opacity
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(color: _shadowColor, blurRadius: 4, offset: Offset(0, 2)),
    ],
  );
  static const _inkRadius = BorderRadius.all(Radius.circular(12));
  static const _labelStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'GeneralSans',
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _inkRadius,
      child: Container(
        width: containerWidth,
        height: containerWidth,
        padding: const EdgeInsets.all(8),
        decoration: _cardDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 32.h,
              width: 32.w,
              child: SvgPicture.asset(
                icon,
                height: 32.h,
                width: 32.w,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(AppColor.kPrimaryColor, BlendMode.srcIn),
              ),
            ),
            SizedBox(height: 11.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: _labelStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
