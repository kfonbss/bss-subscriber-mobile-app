import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController textEditingController;
  final TextInputType? textInputType;
  final Function(String)? onTextChanged;
  final int? maxLength;
  final TextCapitalization? textCapitalization;
  final String? Function(String?)? validator;

  const LoginTextField({
    super.key,
    required this.hintText,
    required this.textEditingController,
    this.textInputType,
    this.onTextChanged,
    this.maxLength,
    this.textCapitalization,
    this.validator,
  });

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
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColor.kTextFiledPlaceholderColor,
        ),
        errorStyle: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.red),
        contentPadding: EdgeInsets.symmetric(vertical: 4),
        prefixIconConstraints: BoxConstraints(
          minWidth: 32,
          maxWidth: 32,
          minHeight: 20,
          maxHeight: 20,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child:SvgPicture.asset(
            AppAssets.user,
            colorFilter: ColorFilter.mode(
              AppColor.kPrimaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        suffixIcon: SizedBox(),
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
