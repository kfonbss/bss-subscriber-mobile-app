import 'package:flutter/material.dart';

import '../../core/constant/constant_colors.dart';
import '../../core/constant/constant_dimensions.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'app_input_style.dart';

class CommonDropDown extends StatelessWidget {
  final List<dynamic>? items;
  final String label;
  final String hintText;
  final Function(dynamic) onSelected;
  final TextEditingController textEditingController;

  /// Opt-in: render with the shared [AppInputStyle] (same look as
  /// CommonTextField) instead of the legacy dropdown style.
  final bool useInputStyle;

  const CommonDropDown({
    super.key,
    this.items,
    required this.label,
    required this.hintText,
    required this.onSelected,
    required this.textEditingController,
    this.useInputStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: useInputStyle ? 8.h : 6,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              useInputStyle
                  ? AppInputStyle.label
                  : TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColor.kTextFiledLabelColor,
                  ),
        ),
        useInputStyle
            ? ListenableBuilder(
              // Rebuild so the selected entry is highlighted in the popup.
              listenable: textEditingController,
              builder:
                  (context, _) => IconButtonTheme(
                    // Shrinks the trailing arrow's 48px tap target so the
                    // field is exactly as tall as CommonTextField.
                    data: IconButtonThemeData(
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(40, 0),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    // Explicit width so the popup is exactly as wide as the field.
                    child: LayoutBuilder(
                      builder:
                          (context, constraints) =>
                              _buildMenu(width: constraints.maxWidth),
                    ),
                  ),
            )
            : _buildMenu(),
      ],
    );
  }

  Widget _buildMenu({double? width}) {
    return DropdownMenu<dynamic>(
      controller: textEditingController,
      width: width ?? double.infinity,
      requestFocusOnTap: false,
      textStyle:
          useInputStyle ? AppInputStyle.text : TextStyle(color: Colors.black),
      hintText: hintText,
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        // Drops the 48px trailing-button padding so height == text field.
        isCollapsed: useInputStyle,
        filled: useInputStyle,
        suffixIconConstraints:
            useInputStyle
                ? const BoxConstraints(minWidth: 40, minHeight: 0)
                : null,
        fillColor: useInputStyle ? Colors.white : null,
        hintStyle: useInputStyle ? AppInputStyle.hint : null,
        // Input style sizes from its padding, exactly like CommonTextField.
        contentPadding:
            useInputStyle
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                : const EdgeInsets.symmetric(horizontal: 16),
        constraints:
            useInputStyle
                ? null
                : BoxConstraints.tight(
                  const Size.fromHeight(AppDimensions.kTextFieldHeight),
                ),
        enabledBorder:
            useInputStyle
                ? AppInputStyle.border(AppColor.kinputFiledLightBorder)
                : OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColor.kTextFiledBorderColor,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(6.0),
                ),
        focusedBorder:
            useInputStyle
                ? AppInputStyle.border(AppColor.kPrimaryColor)
                : OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColor.kPrimaryColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                ),
      ),
      menuHeight: useInputStyle ? 260.h : null,
      menuStyle:
          useInputStyle
              ? MenuStyle(
                alignment: Alignment.bottomLeft,
                backgroundColor: const WidgetStatePropertyAll<Color>(
                  Colors.white,
                ),
                surfaceTintColor: const WidgetStatePropertyAll<Color>(
                  Colors.transparent,
                ),
                elevation: const WidgetStatePropertyAll<double>(6),
                shadowColor: WidgetStatePropertyAll<Color>(AppColor.kGrey15),
                padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(vertical: 6),
                ),
                shape: WidgetStatePropertyAll<OutlinedBorder>(
                  RoundedRectangleBorder(
                    // Square top edge so the popup sits flush under the field.
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    side: BorderSide(color: AppColor.kinputFiledLightBorder),
                  ),
                ),
              )
              : const MenuStyle(
                alignment: Alignment.bottomLeft,
                backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
              ),

      trailingIcon:
          items == null
              ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.kPrimaryColor,
                ),
              )
              : Icon(
                useInputStyle
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.arrow_drop_down_outlined,
                color:
                    useInputStyle ? AppColor.kTextSecondaryDark : Colors.black,
                size: useInputStyle ? 22.0 : 24.0,
              ),
      selectedTrailingIcon:
          useInputStyle
              ? Icon(
                Icons.keyboard_arrow_up_rounded,
                color: AppColor.kPrimaryColor,
                size: 22.0,
              )
              : null,
      onSelected: (dynamic value) => onSelected(value),

      dropdownMenuEntries:
          items == null
              ? []
              : items!.map((dynamic items) {
                if (useInputStyle) return _styledEntry(items);
                return DropdownMenuEntry(
                  labelWidget: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 7.5,
                    ),
                    child: Text(
                      items,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  value: items,
                  label: items,
                );
              }).toList(),
    );
  }

  /// Popup row in the shared input style: comfortable tap height, primary
  /// tint + check mark on the selected entry.
  DropdownMenuEntry<dynamic> _styledEntry(dynamic item) {
    final text = item.toString();
    final selected = textEditingController.text == text;
    return DropdownMenuEntry<dynamic>(
      value: item,
      label: text,
      labelWidget: Text(
        text,
        style:
            selected
                ? AppInputStyle.text.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColor.kPrimaryColor,
                )
                : AppInputStyle.text,
      ),
      trailingIcon:
          selected
              ? Icon(
                Icons.check_rounded,
                size: 20,
                color: AppColor.kPrimaryColor,
              )
              : null,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll<Size>(Size.fromHeight(48)),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        backgroundColor: WidgetStatePropertyAll<Color>(
          selected ? AppColor.kPrimary10 : Colors.transparent,
        ),
        overlayColor: WidgetStatePropertyAll<Color>(AppColor.kPrimary5),
      ),
    );
  }
}
