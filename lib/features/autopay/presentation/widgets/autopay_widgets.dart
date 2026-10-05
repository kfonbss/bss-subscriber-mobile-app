import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/autopay/domain/entity/autopay_entity.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

/// Shared text style for the Autopay screens.
TextStyle autopayText(
  double size,
  FontWeight weight,
  Color color, {
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) => TextStyle(
  fontFamily: 'GeneralSans',
  fontSize: size.sp,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
  decoration: decoration,
  decorationColor: color,
);

final NumberFormat _currency = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹ ',
  decimalDigits: 2,
);

/// ₹ amount in Indian grouping, e.g. `₹ 1,599.00`.
String formatAutopayAmount(double amount) => _currency.format(amount);

/// White card with the soft shadow used across the Autopay screens.
class AutopayCard extends StatelessWidget {
  const AutopayCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  static const _shadows = [
    BoxShadow(
      color: AppColor.kBlack4,
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: -1,
    ),
    BoxShadow(
      color: AppColor.kCardShadowWine,
      blurRadius: 20,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColor.kStone200Alpha70),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _shadows,
      ),
      child: child,
    );
  }
}

/// "Enroll in UPI Autopay to renew your plan automatically…" banner.
class AutopayInfoBanner extends StatelessWidget {
  /// Text from the API (`content.enrollmentBanner`); the built-in copy is
  /// used when it's empty. "UPI Autopay" is highlighted either way.
  final String? text;

  const AutopayInfoBanner({super.key, this.text});

  List<TextSpan> _spans(String value, String highlight, TextStyle style) {
    final at = value.indexOf(highlight);
    if (at < 0) return [TextSpan(text: value)];
    return [
      TextSpan(text: value.substring(0, at)),
      TextSpan(
        text: highlight,
        style: style.copyWith(
          color: AppColor.kPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      TextSpan(text: value.substring(at + highlight.length)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final apiText = text?.trim() ?? '';
    final style = autopayText(
      12,
      FontWeight.w500,
      AppColor.kStone700,
      height: 1.63,
    );
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.kSecondaryBackgroundColor,
        border: Border.all(color: AppColor.kInfoBannerBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColor.kPrimaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.autorenew, size: 14.sp, color: Colors.white),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: style,
                children:
                    apiText.isNotEmpty
                        ? _spans(apiText, l10n.upiAutopay, style)
                        : [
                          TextSpan(text: '${l10n.autopayEnrollIn} '),
                          TextSpan(
                            text: l10n.upiAutopay,
                            style: style.copyWith(
                              color: AppColor.kPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: ' ${l10n.autopayEnrollSuffix}'),
                        ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small grey "UPI" tag.
class AutopayUpiTag extends StatelessWidget {
  const AutopayUpiTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColor.kStone100,
        border: Border.all(color: AppColor.kStone200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        context.bssSubL10n.upiLabel,
        style: autopayText(10, FontWeight.w700, AppColor.kStone500),
      ),
    );
  }
}

/// Plan + next debit summary (details screen and remove sheet).
class AutopayPlanSummaryCard extends StatelessWidget {
  const AutopayPlanSummaryCard({super.key, required this.details});

  final AutopayMandateDetailsEntity details;

  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    // speedProfile comes as a number ("5") → "5 Mbps".
    final speedMbps = int.tryParse(details.speed.trim());
    final planTitle = [
      details.planName,
      speedMbps != null ? l10n.mbps(speedMbps) : details.speed,
    ].where((s) => s.trim().isNotEmpty).join(' · ');
    final nextDate = details.nextDebitDate;

    String? dueText;
    if (nextDate != null) {
      final now = DateTime.now();
      final days =
          DateTime(
            nextDate.year,
            nextDate.month,
            nextDate.day,
          ).difference(DateTime(now.year, now.month, now.day)).inDays;
      if (days == 0) dueText = l10n.dueToday;
      if (days > 0) dueText = l10n.dueInDays('$days');
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColor.kPlanCardGradientStart,
            AppColor.kPlanCardGradientEnd,
          ],
        ),
        border: Border.all(color: AppColor.kPlanCardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.broadbandPlan,
                      style: autopayText(
                        12,
                        FontWeight.w500,
                        AppColor.kStone600,
                        height: 1.33,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      planTitle.isEmpty ? '-' : planTitle,
                      style: autopayText(
                        14,
                        FontWeight.w600,
                        AppColor.kSlate900,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.baseRate,
                    style: autopayText(
                      12,
                      FontWeight.w500,
                      AppColor.kStone600Alpha80,
                      height: 1.33,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${formatAutopayAmount(details.baseRate)} ',
                          style: autopayText(
                            14,
                            FontWeight.w600,
                            AppColor.kSlate900,
                            height: 1.43,
                          ),
                        ),
                        TextSpan(
                          text: l10n.perMonth,
                          style: autopayText(
                            11,
                            FontWeight.w400,
                            AppColor.kSlate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.only(top: 8.h),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColor.kPlanCardDivider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${l10n.nextAutoDebitDate} ',
                        style: autopayText(
                          10,
                          FontWeight.w500,
                          AppColor.kSlate600,
                          height: 1.6,
                        ),
                      ),
                      TextSpan(
                        text:
                            nextDate == null
                                ? '-'
                                : '${_dateFormat.format(nextDate)} ',
                        style: autopayText(
                          10,
                          FontWeight.w600,
                          AppColor.kSlate900,
                          height: 1.6,
                        ),
                      ),
                      if (dueText != null)
                        TextSpan(
                          text: dueText,
                          style: autopayText(
                            10,
                            FontWeight.w600,
                            AppColor.kStone600,
                            height: 1.6,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.totalScheduledDebit,
                        style: autopayText(
                          12,
                          FontWeight.w500,
                          AppColor.kSlate600,
                          height: 1.33,
                        ),
                      ),
                    ),
                    Text(
                      '${formatAutopayAmount(details.totalDebit)} ',
                      style: autopayText(
                        12,
                        FontWeight.w600,
                        AppColor.kPrimaryColor,
                        height: 1.33,
                      ),
                    ),
                    Text(
                      l10n.inclGst,
                      style: autopayText(
                        10,
                        FontWeight.w400,
                        AppColor.kSlate500,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
