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

  /// Leave null to fill the parent; set it for a button that sits beside
  /// others in a Row and should hug its own width.
  final double? width;

  /// Overrides the tenant primary fill, for a filled button that carries a
  /// different meaning (a destructive red, say).
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final IconAlignment iconAlignment;

  /// When set, uses this size for the loading indicator (e.g. 16 for compact buttons). Defaults to 30.
  final double? loaderSize;

  /// If provided, this text will be shown next to the loading indicator when isLoading is true.
  final String? loadingLabel;

  const PrimaryButton({
    super.key,
    this.icon,
    required this.label,
    required this.isLoading,
    this.onClicked,
    this.borderRadius,
    this.height,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.padding,
    this.loaderSize,
    this.loadingLabel,
    this.iconAlignment = IconAlignment.end,
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
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: loaderSize ?? (loadingLabel != null ? 20 : 30),
            width: loaderSize ?? (loadingLabel != null ? 20 : 30),
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: loaderSize != null || loadingLabel != null
                  ? 2
                  : 3,
            ),
          ),
          if (loadingLabel != null) ...[
            SizedBox(width: 8.w),
            Text(
              loadingLabel!,
              style:
              textStyle ??
                  TextStyle(
                    fontSize: AppDimensions.kButtonTextSize.sp,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ],
      )
          : Text(label),
      iconAlignment: iconAlignment,
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius??10),
        ),
        elevation: 0,
        minimumSize: Size(width ?? double.infinity, height ?? 50.h),
        fixedSize: Size(width ?? double.infinity, height ?? 50.h),
        disabledBackgroundColor: Colors.grey,
        backgroundColor: backgroundColor ?? AppColor.kPrimaryColor,
        foregroundColor: foregroundColor ?? Colors.white,
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
