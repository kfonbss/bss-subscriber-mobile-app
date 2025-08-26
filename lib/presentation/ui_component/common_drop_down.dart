import 'package:flutter/material.dart';

import '../../core/constant/constant_colors.dart';
import '../../core/constant/constant_dimensions.dart';

class CommonDropDown extends StatelessWidget {
  final List<dynamic>? items;
  final String label;
  final String hintText;
  final Function(dynamic) onSelected;
  final TextEditingController textEditingController;

  const CommonDropDown({
    super.key,
    this.items,
    required this.label,
    required this.hintText,
    required this.onSelected,
    required this.textEditingController,
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
        DropdownMenu<dynamic>(
          controller: textEditingController,
          width: double.infinity,
          requestFocusOnTap: false,
          textStyle: TextStyle(color: Colors.black),
          hintText: hintText,
          inputDecorationTheme: InputDecorationTheme(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            constraints: BoxConstraints.tight(
              const Size.fromHeight(AppDimensions.kTextFieldHeight),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.kTextFiledBorderColor, width: 1.0),
              borderRadius: BorderRadius.circular(6.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.kPrimaryColor, width: 1.5),
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
          ),
          menuStyle: const MenuStyle(
            alignment: Alignment.bottomLeft,
            backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
          ),

          trailingIcon:
              items == null
                  ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.kPrimaryColor,
                    ),
                  )
                  : Icon(
                    Icons.arrow_drop_down_outlined,
                    color: Colors.black,
                    size: 24.0,
                  ),
          onSelected: (dynamic value) => onSelected(value),

          dropdownMenuEntries:
              items == null
                  ? []
                  : items!.map((dynamic items) {
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
        ),
      ],
    );
  }
}
