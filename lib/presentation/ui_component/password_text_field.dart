import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final bool showBorder;
  final bool showIcon;
  final Function(String)? onTextChanged;

  const PasswordTextField({
    super.key,
    required this.textEditingController,
    required this.hintText,
    required this.showBorder,
    required this.showIcon,
    this.onTextChanged,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.textEditingController,
      onTapOutside: (PointerDownEvent event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      maxLines: 1,
      textAlignVertical: TextAlignVertical.center,
      autofocus: false,
      style: TextStyle(color: Colors.black, fontSize: 20.0, letterSpacing: 1.5),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        counterText: '',
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppColor.kTextFiledHintColor,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.0,
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: widget.showIcon ? 25 : 10,
          maxWidth: widget.showIcon ? 25 : 10,
          minHeight: widget.showIcon ? 25 : 10,
          maxHeight: widget.showIcon ? 25 : 10,
        ),
        prefixIcon:
            widget.showIcon
                ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset('assets/icons/lock.png'),
                )
                : Container(),
        suffixIcon: IconButton(
          icon: Image.asset('assets/icons/eye.png', height: 20, width: 20),
          onPressed: () {
            setState(() {
              obscureText = !obscureText; // Toggle visibility
            });
          },
        ),
        focusedBorder:
            widget.showBorder
                ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColor.kPrimaryColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                )
                : InputBorder.none,
        border:
            widget.showBorder
                ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ), // Adjust the radius for desired curvature
                )
                : InputBorder.none,
      ),
      obscureText: obscureText,
      onChanged: (String newText) {
        if (widget.onTextChanged != null) widget.onTextChanged!(newText);
      },
    );
  }
}
