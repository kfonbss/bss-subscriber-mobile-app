import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:flutter/material.dart';

/// Checkbox with a label, the whole row tappable.
///
/// Controlled: [value] comes from the caller and [onChanged] reports taps, so
/// the box stays in step with a form that can be reset or restored.
class CommonCheckBox extends StatelessWidget {
  final bool value;
  final String title;
  final Color? checkColor;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final TextStyle? textStyle;

  /// Gap between the box and the label; 8 unless the design says otherwise.
  final double? spacing;

  /// Unchecked border colour; #BDBDBD unless the design says otherwise.
  final Color? borderColor;

  const CommonCheckBox({
    super.key,
    required this.title,
    required this.onChanged,
    required this.value,
    this.activeColor,
    this.checkColor,
    this.textStyle,
    this.spacing,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            activeColor: activeColor ?? AppColor.kCheckBoxColor,
            checkColor: checkColor ?? Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(
              color: borderColor ?? AppColor.kCheckboxBorderGrey,
              width: 1.5.w,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          ),
          SizedBox(width: spacing ?? 8.w),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  textStyle ??
                  TextStyle(
                    fontSize: 14.sp,
                    color: AppColor.kBlackHeadingColor,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'General Sans',
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
