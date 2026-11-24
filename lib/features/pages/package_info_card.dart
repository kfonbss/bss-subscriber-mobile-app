import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/data_volume_format.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/entity/active_packages_details_entity.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/plan_validity_badge.dart';

class PackageInfoCard extends StatelessWidget {
  final ActivePackagesDetailsEntity? entity;

  /// Shows a "View Usage" link next to the data line when set. Left null
  /// on the Data Usage screen itself.
  final VoidCallback? onViewUsage;

  const PackageInfoCard({super.key, required this.entity, this.onViewUsage});

  // Design: white, radius 16, no shadow.
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  static const _speedRowDecoration = BoxDecoration(
    color: AppColor.kSpeedBoxGrey,
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  // Same outlined look as the home "+N Pack" button: white, 1px primary
  // border, primary text. A getter so the primary follows the tenant.
  static BoxDecoration get _packCountDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.all(Radius.circular(80)),
    border: Border.all(color: AppColor.kPrimaryColor, width: 1),
  );

  static final _dateFmt = DateFormat('MMM dd, yyyy');

  /// "Active until …", or "Expired on …" once the plan has lapsed.
  static String _validityText(BuildContext context, DateTime activeUntil) {
    final l10n = context.bssSubL10n;
    final date = _dateFmt.format(activeUntil);
    return PlanValidityBadge.isExpired(activeUntil)
        ? l10n.expiredOnDate(date)
        : l10n.activeUntilDate(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Design: 46 tall, 12 side padding.
            Container(
              height: 46.h,
              decoration: _speedRowDecoration,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    context.bssSubL10n.mbps(entity!.speedMbps),
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      height: 0.92,
                      color: AppColor.kTextPrimary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '(${entity!.packageType})',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      color: AppColor.kTextPrimary80,
                    ),
                  ),
                  const Spacer(),
                  PlanValidityBadge(activeUntil: entity!.activeUntil),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                children: [
                  // Top-aligned so a plan name that wraps grows downwards
                  // while the icon and "+N Pack" pill stay at the top.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: AppColor.kPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.language_rounded,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entity!.packageName}   ₹${entity!.renewalFee}',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColor.kTextPrimary,
                                height: 1.30,
                              ),
                            ),
                            Text(
                              _validityText(context, entity!.activeUntil),
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                height: 1.60,
                                color: AppColor.kTextPrimary80,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // "+N Pack" counts the active add-ons; hidden when
                      // there are none.
                      if (entity!.activeAddOns.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        // Design: 68×24, radius 80, 1px border, 10 side padding.
                        // 68 is a minimum so "+ 12 Pack" still fits.
                        Container(
                          height: 24.h,
                          constraints: BoxConstraints(minWidth: 68.w),
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: _packCountDecoration,
                          child: Text(
                            context.bssSubL10n.plusPackCount(
                              '${entity!.activeAddOns.length}',
                            ),
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                              color: AppColor.kPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 17.h),
                  _DataUsageBar(
                    availableGB: entity!.availableVolumeGb,
                    totalGB: entity!.totalVolumeGb,
                    onViewUsage: onViewUsage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataUsageBar extends StatelessWidget {
  /// Data left (the API's `availableVolumeGb`), not data used. Null when
  /// the API doesn't send it.
  final double? availableGB;
  final double totalGB;
  final VoidCallback? onViewUsage;

  const _DataUsageBar({
    required this.availableGB,
    required this.totalGB,
    this.onViewUsage,
  });

  // Shared across ClipRRect and both inner BoxDecorations.
  static const _barRadius = BorderRadius.all(Radius.circular(30));
  static const _trackDecoration = BoxDecoration(
    color: AppColor.kUsageTrackGrey,
    borderRadius: _barRadius,
  );
  static BoxDecoration get _fillDecoration =>
      BoxDecoration(color: AppColor.kPrimaryColor, borderRadius: _barRadius);

  @override
  Widget build(BuildContext context) {
    // Bar shows what's left, matching the "Available" label: full on a fresh
    // plan, emptying as data is used. No total means no data cap: show
    // "Unlimited" and an empty bar. Remaining data missing from the API:
    // treat it as the full plan (same as the web portal) with a full bar.
    final hasLimit = totalGB > 0;
    final available =
        hasLimit
            ? (availableGB ?? totalGB).clamp(0.0, totalGB).toDouble()
            : null;
    final progress = available != null ? available / totalGB : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: _barRadius,
          child: SizedBox(
            height: 6.h,
            child: Stack(
              children: [
                Container(decoration: _trackDecoration),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(decoration: _fillDecoration),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                !hasLimit
                    ? context.bssSubL10n.unlimited
                    : available == null
                    ? formatDataVolume(totalGB)
                    : context.bssSubL10n.gbAvailableOfTotal(
                      formatDataVolume(available),
                      formatDataVolume(totalGB),
                    ),
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.30,
                  color: AppColor.kTextPrimary,
                ),
              ),
            ),
            if (onViewUsage != null) ...[
              SizedBox(width: 8.w),
              // Design: plain primary-coloured text link, right-aligned.
              InkWell(
                onTap: onViewUsage,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                child: Padding(
                  // Larger tap target without shifting the text.
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Text(
                    context.bssSubL10n.viewUsage,
                    // Design: Medium 500, 12, line height 130%, no letter
                    // spacing.
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.30,
                      letterSpacing: 0,
                      color: AppColor.kPrimaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
