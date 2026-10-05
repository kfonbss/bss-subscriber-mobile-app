import 'package:flutter/material.dart';

import '../../core/constant/constant_colors.dart';
import '../../core/constant/constant_dimensions.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class FormAppBar extends StatelessWidget {
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final bool? centerTitle;
  final Color? backgroundColor;
  final Widget body;
  FormAppBar({
    super.key,
    this.onBackPressed,
    this.actions,
    this.centerTitle,
    this.backgroundColor,
    required this.showBackButton,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColor.kPrimaryColor,
        toolbarHeight: AppDimensions.kDefaultToolbarHeights,
        actions: actions ?? [],
        title: SizedBox(
          height: 45.0.h,
          child: Image.asset(
            AppAssets.kLogo,
            fit: BoxFit.fitHeight,
          ),
        ),
        titleSpacing: showBackButton ? 0 : 25,
        centerTitle: centerTitle ?? showBackButton ? true : false,
        automaticallyImplyLeading: showBackButton ? true : false,
        leading:
            showBackButton
                ? IconButton.filled(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kTransparentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  onPressed: () => onBackPressed ?? Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                )
                : null,
      ),
      backgroundColor:backgroundColor?? Colors.white,
      body: body,
    );
  }
}
