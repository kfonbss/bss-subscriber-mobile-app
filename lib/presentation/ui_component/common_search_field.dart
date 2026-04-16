import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class CommonSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterPressed;
  final String? hintText;
  final TextEditingController? controller;
  final Color? backgroundColor;
  final Color? filterIconColor;

  const CommonSearchField({
    super.key,
    required this.onChanged,
    this.onFilterPressed,
    this.hintText,
    this.controller,
    this.backgroundColor,
    this.filterIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hintText ?? 'Select Subscriber',
          hintStyle: TextStyle(
            color: AppColor.kTextSecondaryDark,
            fontWeight: FontWeight.w400,
            fontFamily: 'GeneralSans',
            fontSize: 14,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 24,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SvgPicture.asset(
              'assets/images/search.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColor.kSlateGrey,
                BlendMode.srcIn,
              ),
            ),
          ),
          suffixIcon:
              onFilterPressed != null
                  ? IconButton(
                    onPressed: onFilterPressed,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    icon: SvgPicture.asset(
                      'assets/images/filter.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        filterIconColor ??
                            Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
