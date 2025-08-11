import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant.dart';

class CommonTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController textEditingController;
  final TextInputType? textInputType;

  const CommonTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.textEditingController,
    this.textInputType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: kTextFiledLabelColor,
          ),
        ),
        TextField(
          controller: textEditingController,
          onTapOutside: (PointerDownEvent event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          minLines: 1,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: textInputType ?? TextInputType.text,
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
            contentPadding: EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 12.0,
            ),
            hintStyle: TextStyle(
              color: kTextFiledHintColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.0,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kPrimaryColor, width: 1.5),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kTextFiledBorderColor, width: 1.0),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
          onChanged: (String newText) {},
        ),
      ],
    );
  }
}
