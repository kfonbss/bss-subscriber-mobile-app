import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

class PlanTileNew extends StatelessWidget {
  final PackageInfoEntity package;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanTileNew({
    super.key, // exposes key so callers can pass ValueKey(package.packageId)
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(right: 6, top: 6),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side:
                    isSelected
                        ? BorderSide(width: 1, color: AppColor.kPrimaryColor)
                        : BorderSide.none,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: PackageCard(
              packageName: package.packageName,
              tags:[package.broadbandCategory??'', package.subscriberCategory!],
              seasonalLabel: '🌸 Onam',
              originalPrice: package.originalAmount,
              discountedPrice: package.renewalFee,
              discountLabel: '₹${package.discountAmount} OFF',
              discountDescription: 'Onam Season Discount',
              savingsAmount: package.savedAmount,
              speedMbps: package.speedInKbps/1024,
              validityDays: package.validity,
              volume: package.volumeType,
              isSelected: isSelected,
            ),
          ),
          if (isSelected)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColor.kPrimaryColor, width: 1),
                ),
                child: const Icon(
                  Icons.check,
                  size: 18,
                  color: AppColor.kPrimaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PackageCard extends StatelessWidget {
  final String packageName;
  final List<String> tags;
  final String seasonalLabel;
  final double originalPrice;
  final double discountedPrice;
  final String discountLabel;
  final String discountDescription;
  final double savingsAmount;
  final double speedMbps;
  final int validityDays;
  final String volume;
  final bool isSelected;
  final Color _gray=const Color(0xFFB0A898);

  const PackageCard({
    super.key,
    required this.packageName,
    required this.tags,
    required this.seasonalLabel,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountLabel,
    required this.discountDescription,
    required this.savingsAmount,
    required this.speedMbps,
    required this.validityDays,
    required this.volume,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Row ──────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Globe icon
            Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '🌐',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + tags + seasonal badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    packageName,
                    style: TextStyle(
                      color: const Color(0xFF0F1121),
                      fontSize: 14.sp,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w500,
                      height: 1.30,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tags.join(' · '),
                    style: TextStyle(
                      color: const Color(0xFF9A9080),
                      fontSize: 10.sp,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SeasonalBadge(label: seasonalLabel),
                ],
              ),
            ),

            // Price column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${originalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: _gray,
                    fontSize: 10.50.sp,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w400,
                     decoration: TextDecoration.lineThrough,
                    decorationColor: _gray,
                    height: 1,
                  ),
                ),
                SizedBox(height: 7.5.h),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected?AppColor.kSecondaryColor:const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(7),
                  ),

                  child: Text(
                    '₹${discountedPrice.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: isSelected?Colors.white:Colors.black,
                      fontSize: 14.sp,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.30,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 19),

        // ── Discount Banner ─────────────────────────────────────────────
        _DiscountBanner(
          discountLabel: discountLabel,
          discountDescription: discountDescription,
          savingsAmount: savingsAmount,
        ),

        const SizedBox(height: 16),

        // ── Stats Row ───────────────────────────────────────────────────
        Row(
          children: [
            _StatItem(
              label: l10n.speed,
              value: '${speedMbps.toStringAsFixed(0)} Mbps',
            ),
            _StatItem(label: l10n.validity, value: '$validityDays Days'),
            _StatItem(label: l10n.volume, value: volume),
          ],
        ),
      ],
    );
  }
}

class _SeasonalBadge extends StatelessWidget {
  final String label;

  const _SeasonalBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.09, -0.41),
          end: Alignment(0.91, 1.41),
          colors: [const Color(0xFFFFD000), const Color(0xFFFF8C00)],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF3D1F00),
              fontSize: 9.50.sp,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscountBanner extends StatelessWidget {
  final String discountLabel;
  final String discountDescription;
  final double savingsAmount;

  const _DiscountBanner({
    required this.discountLabel,
    required this.discountDescription,
    required this.savingsAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.00, 0.50),
          end: Alignment(1.00, 0.50),
          colors: [const Color(0xFFFFF7ED), const Color(0xFFFFFBEB)],
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: const Color(0xFFFED7AA)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 12,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: ShapeDecoration(
                    color: AppColor.kSecondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discountLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.50.sp,
                          fontFamily: 'General Sans',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.30,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  discountDescription,
                  style: TextStyle(
                    color: const Color(0xFF92400E),
                    fontSize: 10.sp,
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Save ₹${savingsAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: const Color(0xFF047857),
                  fontSize: 10.sp,
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stat Item ──────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF707070),
              fontSize: 10.sp,
              fontFamily: 'General Sans',
              fontWeight: FontWeight.w400,
              height: 1.30,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF0F1121),
              fontSize: 14.sp,
              fontFamily: 'General Sans',
              fontWeight: FontWeight.w500,
              height: 1.30,
            ),
          ),
        ],
      ),
    );
  }
}
