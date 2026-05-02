import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/entity/active_packages_details_entity.dart';

class PackageInfoCard extends StatelessWidget {
  final ActivePackagesDetailsEntity? entity;
  const PackageInfoCard({super.key, required this.entity});

  // 0.05 × 255 = 12.75 → 13 = 0x0D
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(
        color: Color(0x0D000000),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );

  static const _speedRowDecoration = BoxDecoration(
    color: AppColor.kSecondaryBackgroundColor,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  static const _daysLeftDecoration = BoxDecoration(
    color: AppColor.kDaysLeftYellow,
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );

  static const _packCountDecoration = BoxDecoration(
    color: AppColor.kSecondaryBackgroundColor,
    borderRadius: BorderRadius.all(Radius.circular(80)),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: _speedRowDecoration,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              child: Row(
                children: [
                  Text(
                    '${entity!.speedMbps} Mbps',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '(${entity!.packageType})',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColor.kTextSecondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: _daysLeftDecoration,
                    child: Text(
                      '${entity!.daysLeft} Days left',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.h,
                        decoration: const BoxDecoration(
                          color: AppColor.kPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10.w),
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
                                color: AppColor.kTextSecondaryDark,
                                height: 1.30
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Active until ${DateFormat('MMM dd, yyyy').format(entity!.activeUntil)}',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColor.kTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 5.h,
                        ),
                        decoration: _packCountDecoration,
                        child: Text(
                          '+ ${entity!.totalPackageCount} Pack',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColor.kTextSecondaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
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
  static const _barRadius = BorderRadius.all(Radius.circular(6));
  static const _trackDecoration = BoxDecoration(
    color: AppColor.kDividerGrey,
    borderRadius: _barRadius,
  );
  static const _fillDecoration = BoxDecoration(
    color: AppColor.kPrimaryColor,
    borderRadius: _barRadius,
  );

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
        SizedBox(height: 10.h),
        Text(
          '$availableGB GB Available / $totalGB GB',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.kTextSecondaryDark,
          ),
        ),
        SizedBox(height: 6.h),
      ],
    );
  }
}
