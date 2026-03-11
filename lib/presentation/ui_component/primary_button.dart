import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

import '../../core/constant/constant_dimensions.dart';

class PrimaryButton extends StatelessWidget {
  final Widget? icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onClicked;
  final double? borderRadius;
  final double? height;
  final TextStyle? textStyle;

  /// When set, uses this size for the loading indicator (e.g. 16 for compact buttons). Defaults to 30.
  final double? loaderSize;

  const PrimaryButton({
    super.key,
    this.icon,
    required this.label,
    required this.isLoading,
    this.onClicked,
    this.borderRadius,
    this.height,
    this.textStyle,
    this.loaderSize,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onClicked,
      icon:
          isLoading || icon == null
              ? null
              : SizedBox(
                height: AppDimensions.kButtonIconSize,
                width: AppDimensions.kButtonIconSize,
                child: icon,
              ),
      label:
          isLoading
              ? SizedBox(
                height: loaderSize ?? 30,
                width: loaderSize ?? 30,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: loaderSize != null ? 2 : 3,
                ),
              )
              : Text(label),
      iconAlignment: IconAlignment.end,
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
        ),
        elevation: 0,
        minimumSize: Size(double.infinity, height ?? 50),
        fixedSize: Size(double.infinity, height ?? 50),
        disabledBackgroundColor: Colors.grey,
        backgroundColor: AppColor.kPrimaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle:
            textStyle ??
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
