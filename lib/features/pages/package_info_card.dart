import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/entity/active_packages_details_entity.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

class PackageInfoCard extends StatelessWidget {
  final ActivePackagesDetailsEntity? entity;
  const PackageInfoCard({super.key, required this.entity});

  // Design: white, radius 16, no shadow.
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  static const _speedRowDecoration = BoxDecoration(
    color: AppColor.kSpeedBoxGrey,
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  static const _daysLeftDecoration = BoxDecoration(
    color: AppColor.kAutopayButtonColor,
    borderRadius: BorderRadius.all(Radius.circular(50)),
  );

  static const _packCountDecoration = BoxDecoration(
    color: AppColor.kSpeedBoxGrey,
    borderRadius: BorderRadius.all(Radius.circular(80)),
  );

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
                  Container(
                    height: 28.h,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: _daysLeftDecoration,
                    child: Text(
                      context.bssSubL10n.daysLeft('${entity!.daysLeft}'),
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.30,
                        color: AppColor.kTextSecondaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                              context.bssSubL10n.activeUntilDate(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(entity!.activeUntil),
                              ),
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
                      Container(
                        height: 24.h,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: _packCountDecoration,
                        child: Text(
                          context.bssSubL10n.plusPackCount(
                            '${entity!.totalPackageCount}',
                          ),
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.60,
                            color: AppColor.kBlack80,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 17.h),
                  _DataUsageBar(
                    usedGB: entity!.availableVolumeGb,
                    totalGB: entity!.totalVolumeGb,
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
  final double usedGB;
  final double totalGB;

  const _DataUsageBar({required this.usedGB, required this.totalGB});

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
    final availableGB = totalGB - usedGB;
    final progress = usedGB / totalGB;

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
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(decoration: _fillDecoration),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          context.bssSubL10n.gbAvailableOfTotal('$availableGB', '$totalGB'),
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            height: 1.30,
            color: AppColor.kTextPrimary,
          ),
        ),
      ],
    );
  }
}
