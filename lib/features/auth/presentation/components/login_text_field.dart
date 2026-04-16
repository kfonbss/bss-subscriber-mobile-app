import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class LoginTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController textEditingController;
  final TextInputType? textInputType;
  final Function(String)? onTextChanged;
  final int? maxLength;
  final String iconName;
  final TextCapitalization? textCapitalization;
  final String? Function(String?)? validator;

  const LoginTextField({
    super.key,
    required this.hintText,
    required this.textEditingController,
    required this.iconName,
    this.textInputType,
    this.onTextChanged,
    this.maxLength,
    this.textCapitalization,
    this.validator,
  });

  // Precomputed — pure compile-time values, no Sizer dependency.
  static const _prefixIconConstraints = BoxConstraints(
    minWidth: 28,
    maxWidth: 28,
    minHeight: 18,
    maxHeight: 18,
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      validator: validator,
      onTapOutside: (PointerDownEvent event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      maxLines: 1,
      maxLength: maxLength,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: textInputType ?? TextInputType.text,
      textCapitalization: textCapitalization ?? TextCapitalization.words,
      autofocus: false,
      cursorHeight: 18.0,
      cursorColor: Colors.black87,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        hintStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColor.kTextFiledHintColor),
        errorStyle: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColor.kFailedRed),
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        prefixIconConstraints: _prefixIconConstraints,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Image.asset('assets/icons/$iconName'),
        ),
        suffixIcon: const SizedBox.shrink(),
        border: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
      onChanged: (String newText) {
        if (onTextChanged != null) onTextChanged!(newText);
      },
    );
  }
}
