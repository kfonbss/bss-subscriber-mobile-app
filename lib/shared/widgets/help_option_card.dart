import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

/// Reusable widget for help option cards (icon + label)
class HelpOptionCard extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;
  final bool isSvg;
  final bool isImageAsset;
  final double containerWidth;
  final Color? iconColor;

  const HelpOptionCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.isSvg = false,
    this.isImageAsset = false,
    this.containerWidth = 98,
    this.iconColor,
  });

  static const _shadowColor = Color(0x0F000000); // black @ 6% opacity
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(color: _shadowColor, blurRadius: 4, offset: Offset(0, 2)),
    ],
  );
  static const _inkRadius = BorderRadius.all(Radius.circular(12));
  static const _labelStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'GeneralSans',
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _inkRadius,
      child: Container(
        width: containerWidth,
        height: containerWidth,
        padding: const EdgeInsets.all(8),
        decoration: _cardDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 32,
              width: 32,
              child: isSvg
                  ? SvgPicture.asset(
                      'assets/images/$icon',
                      height: 32,
                      width: 32,
                      fit: BoxFit.contain,
                      colorFilter: iconColor != null
                          ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                          : null,
                    )
                  : Image.asset(
                      'assets/images/$icon',
                      height: 32,
                      width: 32,
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(height: 11),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: _labelStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
