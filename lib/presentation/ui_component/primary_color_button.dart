import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

import '../../core/constant/constant_dimensions.dart';

class PrimaryColorButton extends StatelessWidget {
  final String label;
  final VoidCallback onClicked;
  final double borderRadius;
  final bool isLoading;

  const PrimaryColorButton({
    super.key,
    required this.label,
    required this.borderRadius,
    required this.onClicked,
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
        backgroundColor: AppColor.kPrimaryColor,
        foregroundColor: Colors.white,
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
                  color: Colors.white,
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
