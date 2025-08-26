import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

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
      spacing: 6,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.kTextFiledLabelColor,
          ),
        ),
        TextField(
          controller: textEditingController,
          onTapOutside: (PointerDownEvent event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          obscureText: obscureText??false,
          maxLines: 1,
          maxLength: maxLength,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: textInputType ?? TextInputType.text,
          textCapitalization:textCapitalization?? TextCapitalization.words,
          autofocus: false,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            letterSpacing: 1.5,
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            counterText: '',
            hintText: hintText,
            contentPadding: EdgeInsets.all(12),
            hintStyle: TextStyle(
              color: AppColor.kTextFiledHintColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.0,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.kPrimaryColor, width: 1.5),
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.kTextFiledBorderColor, width: 1.0),
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
          ),
          onChanged: (String newText) {
            if (onTextChanged != null) onTextChanged!(newText);
          },
        ),
      ],
    );
  }
}
