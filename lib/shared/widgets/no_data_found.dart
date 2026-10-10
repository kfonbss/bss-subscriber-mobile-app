import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/shared/widgets/tenant_recolored_image.dart';
import 'package:flutter/material.dart';

class NoDataFound extends StatelessWidget {
  const NoDataFound({
    super.key,
    required this.errorMessage,
    this.iconColor,
    this.textColor,
  });

  final String errorMessage;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Inside a scroll view / sliver the height is unbounded, so fall back
        // to a fraction of the screen instead of an infinite image.
        final availableHeight =
            constraints.hasBoundedHeight
                ? constraints.maxHeight
                : MediaQuery.sizeOf(context).height * 0.6;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TenantRecoloredImage(
                  AppAssets.filler,
                  height: availableHeight * 0.5,
                ),
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: textColor ?? Colors.black,
                    fontSize: 14,
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
