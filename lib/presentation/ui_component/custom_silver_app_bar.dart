import 'package:flutter/material.dart';

import '../../core/constant/constant_colors.dart';
import '../../core/constant/constant_dimensions.dart';

class CustomSilverAppBar extends StatelessWidget {
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final Widget logo = SizedBox(
    height: 45.0,
    child: Image.asset(
      'assets/images/logo_transparent.png',
      fit: BoxFit.fitHeight,
    ),
  );

  CustomSilverAppBar({
    super.key,
    this.onBackPressed,
    this.actions,
    required this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColor.kToolbarBackground,
      toolbarHeight: AppDimensions.kSilverToolbarHeights,
      scrolledUnderElevation: 0,
      forceElevated: true,
      floating: true,
      pinned: true,
      snap: true,
      actions: actions ?? [],
      title: logo,
      titleSpacing: showBackButton ? 0 : 25,
      centerTitle: showBackButton ? true : false,
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
    );
  }
}
