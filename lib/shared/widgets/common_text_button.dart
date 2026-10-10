import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class CommonTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TextStyle? textStyle;

  /// Hugs the label by default; set it when the button sits in a row of
  /// buttons that should keep a comfortable tap target.
  final EdgeInsetsGeometry? padding;

  const CommonTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textStyle?.color ?? AppColor.kPrimaryColor,
        padding: padding ?? EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style:
        textStyle ??
            TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'General Sans',
            ),
      ),
    );
  }
}
