import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth < containerWidth
                ? constraints.maxWidth
                : containerWidth;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: width,
            height: width,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 32,
                  width: 32,
                  child:
                      isSvg
                          ? SvgPicture.asset(
                            'assets/images/$icon',
                            height: 32,
                            width: 32,
                            fit: BoxFit.contain,
                            colorFilter:
                                iconColor != null
                                    ? ColorFilter.mode(
                                      iconColor!,
                                      BlendMode.srcIn,
                                    )
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
                    style: const TextStyle(
                      color: Color(0xFF0F1121),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
