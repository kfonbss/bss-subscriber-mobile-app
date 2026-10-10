import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class CommonPasswordTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final String heading;
  final Function(String)? onTextChanged;
  final double? borderRadius;
  final String? Function(String?)? validator;

  const CommonPasswordTextField({
    super.key,
    required this.textEditingController,
    required this.hintText,
    required this.heading,
    this.onTextChanged,
    this.borderRadius,
    this.validator,
  });

  @override
  State<CommonPasswordTextField> createState() =>
      _CommonPasswordTextFieldState();
}

class _CommonPasswordTextFieldState extends State<CommonPasswordTextField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    // Design: heading 14 w600 #0F1121, 8 above a 48-tall field
    // (1px #EAEAEA border, radius 12, 16 side padding, 24 eye icon).
    return Column(
      spacing: 8.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.heading,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            height: 1.30,
            color: AppColor.kTextSecondaryDark,
          ),
        ),
        TextFormField(
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
            fillColor: Colors.white,
            filled: true,
            counterText: '',

            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              height: 1.60,
              color: AppColor.kTextFiledPlaceholderColor,
            ),
            errorStyle: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColor.kFailedRed),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12,
            ),

            // 40-wide tap target + 8 right padding puts the 24 icon 16 from
            // the edge; the 48 min height sets the field height.
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 48),
                iconSize: 24,
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
            ),

            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.kPrimaryColor, width: 1.5),
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColor.kinputFiledLightBorder,
                width: 1.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
          ),
          obscureText: obscureText,
          onChanged: (String newText) {
            if (widget.onTextChanged != null) widget.onTextChanged!(newText);
          },
        ),
      ],
    );
  }
}
