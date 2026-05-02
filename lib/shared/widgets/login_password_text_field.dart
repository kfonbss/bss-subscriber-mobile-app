import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

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
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        counterText: '',
        hintText: widget.hintText,
        hintStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColor.kTextFiledHintColor),
        errorStyle: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColor.kFailedRed),
        contentPadding: EdgeInsets.symmetric(vertical: 4),

        prefixIconConstraints: BoxConstraints(
          minWidth: 28,
          maxWidth: 28,
          minHeight: 18,
          maxHeight: 18,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Image.asset('assets/icons/lock.png'),
        ),

        suffixIcon: IconButton(
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
