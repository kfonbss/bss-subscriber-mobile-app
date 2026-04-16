import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/extensions.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class CommonToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double? width;
  final double? height;

  const CommonToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width,
    this.height,
  });

  // Thumb shadow does not change — precomputed as static const.
  // 0x1A = 26 ≈ 0.1 × 255 → Colors.black @ 10% opacity
  static const _thumbDecoration = BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final toggleWidth = width ?? (context.isTablet ? 36.0 * 1.2 : 36.w);
    final toggleHeight = height ?? (context.isTablet ? 20.0 * 1.2 : 20.w);
    final thumbRadius = (toggleHeight - 4) / 2; // Thumb radius with padding

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: toggleWidth,
        height: toggleHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(toggleHeight / 2),
          color: value ? AppColor.kPrimaryColor : AppColor.kToggleDisabledGrey,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? toggleWidth - thumbRadius * 2 - 2 : 2,
              top: 2,
              child: Container(
                width: thumbRadius * 2,
                height: thumbRadius * 2,
                decoration: _thumbDecoration,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
