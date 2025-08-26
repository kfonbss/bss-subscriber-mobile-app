import 'package:flutter/material.dart';

import '../../core/constant/constant_colors.dart';

class CommonTextArea extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController textEditingController;
  final TextCapitalization? textCapitalization;

  const  CommonTextArea({
    super.key,
    required this.label,
    required this.hintText,
    required this.textEditingController,
    this.textCapitalization,
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
        SizedBox(
          height: 150,
          child: TextField(
            controller: textEditingController,
            onTapOutside: (PointerDownEvent event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            keyboardType: TextInputType.multiline,
            textAlign: TextAlign.start,
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
                borderSide: BorderSide(
                  color: AppColor.kTextFiledBorderColor,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
