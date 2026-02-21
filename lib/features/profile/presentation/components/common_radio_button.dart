import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class CommonRadioButton extends StatelessWidget {
  final bool isSelected;
  final double? size;

  const CommonRadioButton({
    super.key,
    required this.isSelected,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? 20.0;

    return isSelected
        ? SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.kPrimaryColor,
                      width: 2,
                    ),
                  ),
                ),
                // Inner filled circle
                Container(
                  width: buttonSize * 0.5,
                  height: buttonSize * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.kPrimaryColor,
                  ),
                ),
              ],
            ),
          )
        : Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF67697A),
                width: 1,
              ),
            ),
          );
  }
}

