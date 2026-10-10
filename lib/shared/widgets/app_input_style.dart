import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

/// Shared input look (ticket / CAF style): white, radius 12, 1px light-grey
/// border; 1px primary when focused, 1px red on error.
///
/// Used by [CommonTextField] and the create-ticket GST/PAN inputs.
abstract final class AppInputStyle {
  static TextStyle get label => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.kTextSecondaryDark,
    height: 1.3,
    fontFamily: 'GeneralSans',
  );

  static TextStyle get text => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColor.kTextSecondaryDark,
    height: 1.6,
    fontFamily: 'GeneralSans',
  );

  static TextStyle get hint => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColor.kMediumGrey,
    height: 1.6,
    fontFamily: 'GeneralSans',
  );

  static OutlineInputBorder border([Color? color]) => OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    borderSide:
        color == null ? BorderSide.none : BorderSide(color: color, width: 1.w),
  );

  /// [hasError] forces the red border for inputs whose error is shown by a
  /// parent FormField (e.g. the GSTIN row).
  static InputDecoration decoration({
    String? hint,
    bool hasError = false,
    Widget? suffixIcon,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  }) {
    final enabled = border(
      hasError ? Colors.red : AppColor.kinputFiledLightBorder,
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: AppInputStyle.hint,
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      isDense: true,
      contentPadding: contentPadding,
      suffixIcon: suffixIcon,
      border: enabled,
      enabledBorder: enabled,
      focusedBorder: border(hasError ? Colors.red : AppColor.kPrimaryColor),
      errorBorder: border(Colors.red),
      focusedErrorBorder: border(Colors.red),
    );
  }

  /// Adaptive toolbar avoids the "system context menu can only be shown for
  /// an active text input connection" assertion on rebuilds.
  static Widget contextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: editableTextState.contextMenuButtonItems,
    );
  }
}
