import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/entity/active_packages_details_entity.dart';

class PackageInfoCard extends StatelessWidget {
  final ActivePackagesDetailsEntity? entity;
  const PackageInfoCard({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColor.kSecondaryBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
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
                    decoration: BoxDecoration(
                      color: AppColor.kYellowBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: const BoxDecoration(
                          color: AppColor.kPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.language_rounded,
                          size: 22.w,
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
                        decoration: BoxDecoration(
                          color: AppColor.kSecondaryBackgroundColor,
                          borderRadius: BorderRadius.circular(80),
                        ),
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
  final int usedGB;
  final int totalGB;

  const _DataUsageBar({required this.usedGB, required this.totalGB});

  @override
  Widget build(BuildContext context) {
    final availableGB = totalGB - usedGB;
    final progress = usedGB / totalGB;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 6.h,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.kPrimaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
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
