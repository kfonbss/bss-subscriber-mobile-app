import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';

class LoginPasswordTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final Function(String)? onTextChanged;
  final double? borderRadius;
  final String? Function(String?)? validator;

  const LoginPasswordTextField({
    super.key,
    required this.textEditingController,
    required this.hintText,
    this.onTextChanged,
    this.borderRadius,
    this.validator,
  });

  @override
  State<LoginPasswordTextField> createState() => _LoginPasswordTextFieldState();
}

class _LoginPasswordTextFieldState extends State<LoginPasswordTextField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textEditingController,
      validator: widget.validator,
      onTapOutside: (PointerDownEvent event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      maxLines: 1,
      textAlignVertical: TextAlignVertical.center,
      autofocus: false,
      cursorHeight: 18.0,
      cursorColor: Colors.black87,
      style: const TextStyle(
        fontFamily: 'GeneralSans',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1,
        color: AppColor.kTextSecondaryDark,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: widget.hintText,
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
        contentPadding: EdgeInsets.symmetric(vertical: 4),

        // 20px icon + 12px gap (design).
        prefixIconConstraints: BoxConstraints(
          minWidth: 32,
          maxWidth: 32,
          minHeight: 20,
          maxHeight: 20,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Image.asset(AppAssets.lock, color: AppColor.kPrimaryColor),
        ),

        suffixIcon: IconButton(
          iconSize: 20,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
        ),

        border: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
      obscureText: obscureText,
      onChanged: (String newText) {
        if (widget.onTextChanged != null) widget.onTextChanged!(newText);
      },
    );
  }
}
