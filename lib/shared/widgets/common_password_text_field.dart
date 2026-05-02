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
  State<CommonPasswordTextField> createState() => _CommonPasswordTextFieldState();
}

class _CommonPasswordTextFieldState extends State<CommonPasswordTextField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 6,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.heading,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
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
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColor.kTextFiledHintColor),
            errorStyle: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColor.kFailedRed),
            contentPadding: EdgeInsets.all(12),

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
