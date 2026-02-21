import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

import '../../core/constant/constant_dimensions.dart';

class SecondaryButton extends StatelessWidget {
  final Widget? icon;
  final String label;
  final bool isLoading;
  final VoidCallback onClicked;
  final double? borderRadius;
  final double? height;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double? loaderSize;

  const SecondaryButton({
    super.key,
    this.icon,
    required this.label,
    this.isLoading = false,
    required this.onClicked,
    this.borderRadius,
    this.height,
    this.backgroundColor,
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
          color: AppColor.kPrimaryColor,
          strokeWidth: 2,
        ),
      )
          : Text(label),
      iconAlignment: IconAlignment.start,
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius??10),
        ),
        elevation: 0,
        minimumSize: Size(double.infinity, height??50),
        fixedSize: Size(double.infinity, height??50),
        backgroundColor: backgroundColor ?? Colors.white,
        foregroundColor: AppColor.kPrimaryColor,
        side: BorderSide(
          color: AppColor.kPrimaryColor, // Border color
          width: 1, // Border width
        ),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: textStyle ??
             TextStyle(
              fontSize: 12.sp,
              fontFamily: 'General Sans',
              fontWeight: FontWeight.w500,
              height: 1.3,

            ),
      ),
    );
  }
}

