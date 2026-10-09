import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

class SubscriberSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterPressed;
  final String? hintText;
  final TextEditingController? controller;
  final Color? backgroundColor;
  final Color? filterIconColor;

  const SubscriberSearchField({
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTapOutside: (_) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        style: TextStyle(
          fontFamily: 'General Sans',
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hintText ?? '',
          hintStyle: TextStyle(
            color: AppColor.kTextSecondaryLight,
            fontWeight: FontWeight.w400,
            fontFamily: 'General Sans',
            fontSize: 14.sp,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 44.w,
            minHeight: 24.h,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 14.w, right: 6.w),
            child: SvgPicture.asset(
              AppAssets.search,
              width: 24.w,
              height: 24.h,
              colorFilter: const ColorFilter.mode(
                AppColor.kSearchIconGrey,
                BlendMode.srcIn,
              ),
            ),
          ),
          suffixIcon:
              onFilterPressed != null
                  ? IconButton(
                    onPressed: onFilterPressed,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    icon: SvgPicture.asset(
                      AppAssets.filter,
                      width: 24.h,
                      height: 24.w,
                      colorFilter: ColorFilter.mode(
                        filterIconColor ?? AppColor.kSecondaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
    );
  }
}
