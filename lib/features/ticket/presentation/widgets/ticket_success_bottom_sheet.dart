import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/shared/widgets/tenant_svg_color_mapper.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';

class TicketSuccessBottomSheet extends StatelessWidget {
  final String ticketId;
  final VoidCallback onReturnHome;

  const TicketSuccessBottomSheet({
    super.key,
    required this.ticketId,
    required this.onReturnHome,
  });

  Future<void> _copyTicketId(BuildContext context) async {
    final l10n = context.bssSubL10n;
    await Clipboard.setData(ClipboardData(text: ticketId));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ticketIdCopied),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    return Container(
      height: 506.h,
      decoration: BoxDecoration(
        color: AppColor.kMainBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            width: 42.w,
            height: 6.h,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColor.kDividerGrey,
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          // Success Illustration
          Container(
            width: 140.w,
            height: 140.h,
            margin: const EdgeInsets.only(top: 48, bottom: 24),
            child: SvgPicture(
              SvgAssetLoader(
                AppAssets.ticketCreateSuccess,
                // Orange accent (#F97316) follows the tenant primary colour.
                colorMapper: TenantSvgColorMapper(
                  extraColors: const {0xFFF97316},
                ),
              ),
              width: 140.w,
              height: 140.h,
              fit: BoxFit.contain,
            ),
          ),

          // Success Title and Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  l10n.success,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColor.kTextSecondaryDark,
                    height: 1.3,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.yourTicketHasBeenCreated,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.kTextFiledPlaceholderColor,
                    height: 1.6,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.ourSupportTeamWillGetBack,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColor.kTextFiledPlaceholderColor,
                    height: 1.6,
                    fontFamily: 'GeneralSans',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Ticket ID Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48.h,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColor.kIconContainerGrey,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ticketId,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColor.kTextFiledPlaceholderColor,
                        height: 1.3,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _copyTicketId(context),
                    child: Icon(
                      Icons.copy,
                      size: 24,
                      color: AppColor.kTextFiledPlaceholderColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Return to Homepage Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PrimaryButton(
              label: l10n.returnToHomepage,
              isLoading: false,
              borderRadius: 10,
              height: 52.h,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
                fontFamily: 'GeneralSans',
              ),
              onClicked: onReturnHome,
            ),
          ),
          const Spacer(),

          // Home Indicator
          Container(
            height: 34.h,
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 9),
            child: Container(
              width: 134.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColor.kTextSecondaryDark,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
