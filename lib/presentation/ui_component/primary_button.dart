import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

import '../../core/constant/constant_dimensions.dart';

class PrimaryButton extends StatelessWidget {
  final Widget? icon;
  final String label;
  final bool isLoading;
  final VoidCallback onClicked;

  const PrimaryButton({
    super.key,
    this.icon,
    required this.label,
    required this.isLoading,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onClicked,
      icon:
          isLoading
              ? null
              : SizedBox(
                height: AppDimensions.kButtonIconSize,
                width: AppDimensions.kButtonIconSize,
                child: icon,
              ),
      label:
          isLoading
              ? SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
              : Text(label),
      iconAlignment: IconAlignment.end,
      style: FilledButton.styleFrom(
        elevation: 2,
        minimumSize: Size(double.infinity, 50),
        fixedSize: Size(double.infinity, 50),
        disabledBackgroundColor: Colors.grey,
        backgroundColor: AppColor.kPrimaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.zero,
        textStyle: TextStyle(
          fontSize: AppDimensions.kButtonTextSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
