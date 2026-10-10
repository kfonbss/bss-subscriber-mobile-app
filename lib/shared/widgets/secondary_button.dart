import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

import '../../core/constant/constant_dimensions.dart';

class SecondaryButton extends StatelessWidget {
  final Widget? icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onClicked;
  final double borderRadius;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;

  /// Text and icon colour; defaults to [borderColor] so an outlined button
  /// reads as one colour unless the caller says otherwise.
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final double? loaderSize;
  final EdgeInsetsGeometry? padding;

  const SecondaryButton({
    super.key,
    this.icon,
    required this.label,
    this.isLoading = false,
    this.onClicked,
    required this.borderRadius,
    this.height,
    this.width,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
    this.textStyle,
    this.loaderSize,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onClicked,
      icon: isLoading || icon == null
          ? null
          : SizedBox(
              height: AppDimensions.kButtonIconSize,
              width: AppDimensions.kButtonIconSize,
              child: icon,
            ),
      label: isLoading
          ? SizedBox(
              height: loaderSize ?? 20,
              width: loaderSize ?? 20,
              child: CircularProgressIndicator(
                color: borderColor ?? AppColor.kPrimaryColor,
                strokeWidth: 2,
              ),
            )
          : Text(label),
      iconAlignment: IconAlignment.start,
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 0,
        minimumSize: Size(width ?? double.infinity, height ?? 52.h),
        fixedSize: Size(width ?? double.infinity, height ?? 52.h),
        backgroundColor: backgroundColor ?? Colors.white,
        foregroundColor:
            foregroundColor ?? borderColor ?? AppColor.kPrimaryColor,
        side: BorderSide(
          color: borderColor ?? AppColor.kPrimaryColor, // Border color
          width: 1.w, // Border width
        ),
        padding: padding ?? EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle:
            textStyle ??
            TextStyle(
              fontSize: AppDimensions.kButtonTextSize.sp,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
