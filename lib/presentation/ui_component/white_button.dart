import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

import '../../core/constant/constant_dimensions.dart';

class WhiteButton extends StatelessWidget {
  final String label;
  final VoidCallback onClicked;
  final double borderRadius;
  final Color? textColor;
  final bool isLoading;

  const WhiteButton({
    super.key,
    required this.label,
    required this.borderRadius,
    required this.onClicked,
    this.textColor,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onClicked,
      style: FilledButton.styleFrom(
        elevation: 0,
        minimumSize: Size(double.infinity, 50),
        fixedSize: Size(double.infinity, 50),
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        foregroundColor: textColor ?? Colors.black,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius,
          ), // Adjust the radius for desired curvature
        ),
      ),
      child:
          isLoading
              ? SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  color: AppColor.kPrimaryColor,
                  strokeWidth: 3,
                ),
              )
              : Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
    );
  }
}
