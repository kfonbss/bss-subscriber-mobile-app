import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/autopay/domain/entity/autopay_entity.dart';
import 'package:kfon_subscriber/features/autopay/presentation/widgets/autopay_widgets.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';

/// Shown when Autopay is enabled (ACTIVE or PENDING approval).
class AutopayDetailsView extends StatelessWidget {
  const AutopayDetailsView({
    super.key,
    required this.details,
    required this.status,
    required this.onRemove,
    this.bannerText,
  });

  final AutopayMandateDetailsEntity details;

  /// `content.enrollmentBanner` from the quote.
  final String? bannerText;
  final AutopayStatus status;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
            children: [
              AutopayInfoBanner(text: bannerText),
              if (status == AutopayStatus.pending) ...[
                SizedBox(height: 12.h),
                _buildPendingNotice(context),
              ],
              SizedBox(height: 16.h),
              AutopayCard(
                child: Column(
                  children: [
                    AutopayPlanSummaryCard(details: details),
                    SizedBox(height: 12.h),
                    _infoRow(
                      l10n.paymentInstrument,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AutopayUpiTag(),
                          SizedBox(width: 6.w),
                          Flexible(child: _value(details.upiId)),
                        ],
                      ),
                    ),
                    _infoRow(l10n.mandateUmn, _value(details.umn)),
                    _infoRow(
                      l10n.maxAutoDebitCap,
                      _value(
                        details.maxDebitCap > 0
                            ? l10n.upToPerMonth(
                              formatAutopayAmount(details.maxDebitCap),
                            )
                            : '',
                      ),
                      showDivider: false,
                    ),
                    SizedBox(height: 12.h),
                    _buildRemoveButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
          child: PrimaryButton(
            label: l10n.goBack,
            isLoading: false,
            onClicked: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingNotice(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.kCreamYellowBg,
        border: Border.all(color: AppColor.kLightAmber),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            size: 18.sp,
            color: AppColor.kAmberDark,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              context.bssSubL10n.autopayPendingApproval,
              style: autopayText(
                12,
                FontWeight.w500,
                AppColor.kAmberBrown,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _value(String text) => Text(
    text.trim().isEmpty ? '-' : text,
    textAlign: TextAlign.right,
    overflow: TextOverflow.ellipsis,
    style: autopayText(12, FontWeight.w500, AppColor.kSlate800, height: 1.33),
  );

  Widget _infoRow(String label, Widget value, {bool showDivider = true}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
      decoration: BoxDecoration(
        border:
            showDivider
                ? const Border(bottom: BorderSide(color: AppColor.kStone100))
                : null,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: autopayText(
              12,
              FontWeight.w500,
              AppColor.kSlate500,
              height: 1.33,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: value),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context) {
    return InkWell(
      onTap: onRemove,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColor.kRemoveButtonBg,
          border: Border.all(color: AppColor.kRemoveButtonBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link_off_rounded,
              size: 16.sp,
              color: AppColor.kRemoveButtonText,
            ),
            SizedBox(width: 8.w),
            Text(
              context.bssSubL10n.removeFromAutoPay,
              style: autopayText(
                12,
                FontWeight.w600,
                AppColor.kRemoveButtonText,
                height: 1.33,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
