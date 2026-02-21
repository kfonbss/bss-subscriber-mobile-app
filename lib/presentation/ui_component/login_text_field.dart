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
  final bool showBorder;

  const LoginTextField({
    super.key,
    required this.hintText,
    required this.textEditingController,
    required this.iconName,
    this.textInputType,
    this.onTextChanged,
    this.maxLength,
    this.textCapitalization,
    required this.showBorder,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      onTapOutside: (PointerDownEvent event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      maxLines: 1,
      maxLength: maxLength,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: textInputType ?? TextInputType.text,
      textCapitalization: textCapitalization ?? TextCapitalization.words,
      autofocus: false,
      style: TextStyle(color: Colors.black, fontSize: 20.0, letterSpacing: 1.5),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        counterText: '',
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColor.kTextFiledHintColor,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.0,
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: showBorder ? 40 : 25,
          maxWidth: showBorder ? 40 : 25,
          minHeight: showBorder ? 40 : 25,
          maxHeight: showBorder ? 40 : 25,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(right: 8.0, left: showBorder ? 15 : 0),
          child: Image.asset('assets/icons/$iconName'),
        ),
        border:
            showBorder
                ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ), // Adjust the radius for desired curvature
                )
                : InputBorder.none,
      ),
      onChanged: (String newText) {
        if (onTextChanged != null) onTextChanged!(newText);
      },
    );
  }
}
