import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/shared/widgets/app_input_style.dart';

/// Labelled single-line text field in the shared ticket input style
/// ([AppInputStyle]): white, radius 12, light-grey border, primary border
/// while focused.
class CommonTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController textEditingController;
  final TextInputType? textInputType;
  final Function(String)? onTextChanged;
  final int? maxLength;
  final TextCapitalization? textCapitalization;
  final bool? obscureText;

  const CommonTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.textEditingController,
    this.textInputType,
    this.onTextChanged,
    this.maxLength,
    this.textCapitalization,
    this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppInputStyle.label),
        TextField(
          controller: textEditingController,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          contextMenuBuilder: AppInputStyle.contextMenuBuilder,
          obscureText: obscureText ?? false,
          maxLines: 1,
          maxLength: maxLength,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: textInputType ?? TextInputType.text,
          textCapitalization: textCapitalization ?? TextCapitalization.words,
          style: AppInputStyle.text,
          decoration: AppInputStyle.decoration(hint: hintText),
          onChanged: onTextChanged,
        ),
      ],
    );
  }
}
