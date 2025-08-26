import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

import '../../core/constant/constant_dimensions.dart';

class SecondaryButton extends StatelessWidget {
  final Widget? icon;
  final String label;
  final VoidCallback onClicked;

  const SecondaryButton({
    super.key,
    this.icon,
    required this.label,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onClicked,
      icon:
          icon == null
              ? icon
              : SizedBox(
                height: AppDimensions.kButtonIconSize,
                width: AppDimensions.kButtonIconSize,
                child: icon,
              ),
      label: Text(label),
      iconAlignment: IconAlignment.start,
      style: FilledButton.styleFrom(
        elevation: 2,
        minimumSize: Size(double.infinity, 50),
        fixedSize: Size(double.infinity, 50),
        backgroundColor: Colors.white,
        foregroundColor: AppColor.kPrimaryColor,
        side: BorderSide(
          color: AppColor.kPrimaryColor, // Border color
          width: 1, // Border width
        ),
        padding: EdgeInsets.zero,
        textStyle: TextStyle(
          fontSize: AppDimensions.kButtonTextSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
