import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class WhiteButton extends StatelessWidget {
  final String label;
  final VoidCallback? onClicked;
  final double borderRadius;
  final Color? textColor;
  final bool isLoading;

  /// Defaults to white.
  final Color? backgroundColor;

  /// Optional 1px outline.
  final Color? borderColor;

  /// Defaults to 50.
  final double? height;

  const WhiteButton({
    super.key,
    required this.label,
    required this.borderRadius,
    this.onClicked,
    this.textColor,
    required this.isLoading,
    this.backgroundColor,
    this.borderColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? 50;
    return FilledButton(
      onPressed: onClicked,
      style: FilledButton.styleFrom(
        elevation: 0,
        minimumSize: Size(double.infinity, buttonHeight),
        fixedSize: Size(double.infinity, buttonHeight),
        backgroundColor: backgroundColor ?? Colors.white,
        foregroundColor: textColor ?? Colors.black,
        disabledBackgroundColor: AppColor.kMediumGrey,
        disabledForegroundColor: Colors.black,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side:
              borderColor != null
                  ? BorderSide(color: borderColor!)
                  : BorderSide.none,
          borderRadius: BorderRadius.circular(
            borderRadius,
          ), // Adjust the radius for desired curvature
        ),
      ),
      child:
          isLoading
              ? SizedBox(
                height: 30.h,
                width: 30.w,
                child: CircularProgressIndicator(
                  color: AppColor.kPrimaryColor,
                  strokeWidth: 3,
                ),
              )
              : Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'GeneralSans',
                  height: 1.30,
                ),
              ),
    );
  }
}
