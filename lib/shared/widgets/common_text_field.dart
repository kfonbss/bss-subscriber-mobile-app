import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/shared/widgets/field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The app's text input: an optional label over a rounded box.
///
/// Borderless on a white fill by default — the form look used across the app.
/// Give it [borderColor] for an outlined variant, [fillColor] for a different
/// surface, and [readOnly] with [onTap] for a field that opens a picker.
///
/// It is a `TextFormField`, so inside a `Form` it validates for free; errors
/// are drawn as a red outline plus the usual message.
class CommonTextField extends StatelessWidget {
  final String? label;
  final String hintText;
  final TextEditingController? textEditingController;

  /// Appends a red asterisk to [label]. Validation is still [validator]'s job.
  final bool isMandatory;

  final String? Function(String?)? validator;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onTextChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final int? maxLength;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final String? initialValue;
  final TextAlign textAlign;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  /// Shrink the icon slots; without them the theme reserves a 48x48 target.
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;

  /// Keeps a read-only field from taking focus, so tapping it only fires
  /// [onTap] and no caret appears.
  final bool canRequestFocus;

  final AutovalidateMode autovalidateMode;

  /// Tighter vertical extent, for fields packed into a dense form.
  final bool isDense;

  /// Drops the default min-height and padding entirely, so the field is
  /// exactly text-height — for a character or quantity box whose parent
  /// sizes and centres it.
  final bool isCollapsed;

  /// Null leaves the box borderless; a colour draws an outline in it.
  final Color? borderColor;

  /// Outline colour while focused; falls back to [borderColor].
  final Color? focusedBorderColor;

  final Color? fillColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  const CommonTextField({
    super.key,
    this.label,
    required this.hintText,
    this.textEditingController,
    this.isMandatory = false,
    this.validator,
    this.textInputType,
    this.inputFormatters,
    this.onTextChanged,
    this.onTap,
    this.onSubmitted,
    this.maxLength,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.initialValue,
    this.textAlign = TextAlign.start,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.canRequestFocus = true,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.isDense = false,
    this.isCollapsed = false,
    this.borderColor,
    this.focusedBorderColor,
    this.fillColor,
    this.borderRadius = 12,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
  }) : assert(
         textEditingController == null || initialValue == null,
         'Pass a controller or an initialValue, not both',
       );

  OutlineInputBorder _border([Color? color]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius),
    borderSide: color == null
        ? BorderSide.none
        : BorderSide(color: color, width: 1.w),
  );

  OutlineInputBorder _errorBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius),
    borderSide: BorderSide(color: Colors.red, width: 1.w),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      // Hug the field so a parent that centres it (e.g. a fixed-height
      // search bar row) actually centres the text.
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          FieldLabel(label: label!, isMandatory: isMandatory),
          SizedBox(height: 12.h),
        ],
        TextFormField(
          controller: textEditingController,
          initialValue: initialValue,
          focusNode: focusNode,
          validator: validator,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          keyboardType: textInputType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          textAlign: textAlign,
          autovalidateMode: autovalidateMode,
          canRequestFocus: canRequestFocus,
          textAlignVertical: TextAlignVertical.center,
          // Flutter's own toolbar, not the system one: the system menu
          // asserts when the input connection drops during a rebuild.
          contextMenuBuilder: (context, editableTextState) =>
              AdaptiveTextSelectionToolbar.buttonItems(
                anchors: editableTextState.contextMenuAnchors,
                buttonItems: editableTextState.contextMenuButtonItems,
              ),
          onChanged: onTextChanged,
          onTap: onTap,
          onFieldSubmitted: onSubmitted,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          style:
              textStyle ??
              TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF0F1121),
                fontFamily: 'General Sans',
              ),
          decoration: InputDecoration(
            hintText: hintText,
            counterText: '',
            hintStyle:
                hintStyle ??
                TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFA5A5A5),
                  fontFamily: 'General Sans',
                ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            prefixIconConstraints: prefixIconConstraints,
            suffixIconConstraints: suffixIconConstraints,
            isDense: isDense,
            isCollapsed: isCollapsed,
            filled: true,
            fillColor: fillColor ?? Colors.white,
            contentPadding:
                contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: _border(borderColor),
            enabledBorder: _border(borderColor),
            disabledBorder: _border(borderColor),
            focusedBorder: _border(focusedBorderColor ?? borderColor),
            errorBorder: _errorBorder(),
            focusedErrorBorder: _errorBorder(),
          ),
        ),
      ],
    );
  }
}
