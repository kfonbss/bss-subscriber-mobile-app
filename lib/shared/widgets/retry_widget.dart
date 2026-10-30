import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';
import 'package:kfon_subscriber/shared/widgets/tenant_recolored_image.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';

class RetryWidget extends StatelessWidget {
  final Color? buttonColor;
  final Color? textColor;
  final String errorMessage;
  final VoidCallback onRetry;

  const RetryWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.buttonColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Inside a scroll view / sliver the height is unbounded, so fall back
        // to a fraction of the screen instead of an infinite image.
        final availableHeight = constraints.hasBoundedHeight
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
                  style: TextStyle(color: textColor ?? Colors.black),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: constraints.maxWidth - 50.h,
                  // On a coloured surface the caller passes [textColor]; the
                  // button then inverts, so it is a secondary button there and
                  // the plain primary one everywhere else.
                  child: textColor == null
                      ? PrimaryButton(
                    label: context.bssSubL10n.retry,
                    isLoading: false,
                    borderRadius: 10,
                    height: 44.h,
                    onClicked: onRetry,
                  )
                      : SecondaryButton(
                    label: context.bssSubL10n.retry,
                    borderRadius: 10,
                    height: 44.h,
                    backgroundColor: textColor,
                    borderColor: AppColor.kPrimaryColor,
                    onClicked: onRetry,
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
