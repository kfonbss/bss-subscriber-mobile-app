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
  // 20px icon + 12px gap (design).
  static const _prefixIconConstraints = BoxConstraints(
    minWidth: 32,
    maxWidth: 32,
    minHeight: 20,
    maxHeight: 20,
  );

  static const _textStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1,
    color: AppColor.kTextSecondaryDark,
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
      style: _textStyle,
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.60,
          color: AppColor.kTextFiledPlaceholderColor,
        ),
        errorStyle: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColor.kFailedRed),
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        prefixIconConstraints: _prefixIconConstraints,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Image.asset(iconName,color: AppColor.kPrimaryColor,),
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
