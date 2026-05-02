import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        onTapOutside: (_) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        style: const TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hintText ?? context.bssSubL10n.searchSubscriber,
          hintStyle: TextStyle(
            color: AppColor.kTextSecondaryLight,
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
              'assets/icons/search.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Color(0xFF606169),
                BlendMode.srcIn,
              ),
            ),
          ),
          suffixIcon: onFilterPressed != null
              ? IconButton(
                  onPressed: onFilterPressed,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  icon: SvgPicture.asset(
                    'assets/icons/filter.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      filterIconColor ?? AppColor.kSecondaryColor,
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
