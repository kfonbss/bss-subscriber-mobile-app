import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

/// Seasonal plan list tile — mirrors [PlanTile] layout but uses the seasonal
/// leading icon treatment (light-blue tile + blue globe) without changing
/// `plan_tile.dart`.
class SeasonalPlanTile extends StatelessWidget {
  /// Background for the leading icon container (light blue).

  final PackageEntity package;
  final bool isSelected;
  final VoidCallback onTap;

  const SeasonalPlanTile({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  static String _formatRupee(double amount, {int decimals = 2}) {
    return '₹${amount.toStringAsFixed(decimals)}';
  }

  /// Offer / promo chrome driven only by API-derived [package] fields.
  static bool _hasOfferChrome(PackageEntity p) {
    if (p.badgeLabel?.isNotEmpty ?? false) return true;
    if (p.seasonName?.isNotEmpty ?? false) return true;
    final list = p.listPrice;
    if (list != null && list > p.price) return true;
    final discount = p.discountAmount;
    if (discount != null && discount > 0) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final hasOffer = _hasOfferChrome(package);
    final list = package.listPrice;
    final showStrikethrough =
        list != null && list > package.price && package.price >= 0;
    final chipText = () {
      final b = package.badgeLabel?.trim();
      if (b != null && b.isNotEmpty) return b;
      final s = package.seasonName?.trim();
      if (s != null && s.isNotEmpty) return s;
      return '';
    }();
    final showChip = chipText.isNotEmpty;
    final offerLabel = _offerLabel(package);
    final saveText = _saveText(context, package);
    final seasonCaption = _seasonDiscountCaption(context, package);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            // Room for the 23px check badge (overhangs 7 right / 8 top).
            margin: const EdgeInsets.only(right: 7, top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Color(0x0F000000), blurRadius: 16),
              ],
              border: isSelected
                  ? Border.all(color: AppColor.kPrimaryColor, width: 1.w)
                  : null,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Figma: 30px #F2EFE7 circle with a primary globe.
                    Container(
                      width: 30.w,
                      height: 30.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColor.kIconBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.language,
                        size: 16,
                        color: AppColor.kPrimaryColor,
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Plan name + API meta row (package type · plan type · subscription type)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.packageName,
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                              color: AppColor.kTextSecondaryDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_metaText(package).isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              _metaText(package),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                height: 1.h,
                                letterSpacing: 0.2,
                                color: AppColor.kTextSecondary,
                              ),
                            ),
                          ],
                          if (showChip && chipText.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 160,
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFFFFD000),
                                        Color(0xFFFF8C00),
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      7,
                                      2,
                                      7,
                                      2,
                                    ),
                                    child: Text(
                                      chipText,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      textHeightBehavior:
                                      const TextHeightBehavior(
                                        applyHeightToFirstAscent: false,
                                        applyHeightToLastDescent: false,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 9.5.sp,
                                        fontWeight: FontWeight.w700,
                                        height: 1.h,
                                        letterSpacing: 0,
                                        color: AppColor.kPrimaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Right price block: list price on new line above current price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (showStrikethrough)
                          Text(
                            _formatRupee(list),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: GoogleFonts.dmSans(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.h,
                              letterSpacing: 0,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColor.kTextSecondary,
                              color: AppColor.kTextSecondary,
                            ),
                          ),
                        if (showStrikethrough) SizedBox(height: 4.h),
                        if (isSelected)
                          Container(
                            height: 30.h,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            decoration: BoxDecoration(
                              color: AppColor.kPrimaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '₹ ${package.price.toStringAsFixed(2)}',
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontFamily: 'General Sans',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 30.h,
                            alignment: Alignment.centerRight,
                            child: Text(
                              '₹ ${package.price.toStringAsFixed(2)}',
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontFamily: 'General Sans',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                                color: AppColor.kTextSecondaryDark,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (hasOffer) ...[
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 26.h,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF3C892)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (offerLabel.isNotEmpty) ...[
                            Container(
                              height: 17.h,
                              padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8671A),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                offerLabel,
                                style: TextStyle(
                                  fontFamily: 'General Sans',
                                  fontSize: 9.5.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.h,
                                  letterSpacing: 0.3,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Expanded(
                            child: Text(
                              seasonCaption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'General Sans',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                height: 1.h,
                                letterSpacing: 0,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                          if (saveText.isNotEmpty) ...[
                            SizedBox(width: 8.w),
                            Text(
                              saveText,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: 'General Sans',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.h,
                                letterSpacing: 0,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 16.h),

                // Plan details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.kSecondaryBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _planDetail(context, l10n.speed, package.speed),
                      ),
                      Expanded(
                        child: _planDetail(
                          context,
                          l10n.validity,
                          '${package.validity} Days',
                        ),
                      ),
                      Expanded(
                        child: _planDetail(context, l10n.volume, package.data),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 23.w,
                height: 23.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.kPrimaryColor,
                ),
                child: Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _planDetail(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'General Sans',
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            height: 1.3,
            color: AppColor.kTextSecondary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'General Sans',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            height: 1.3,
            color: AppColor.kTextSecondaryDark,
          ),
        ),
      ],
    );
  }

  String _metaText(PackageEntity package) {
    final parts = <String>[
      package.packageType?.name.trim() ?? '',
      package.planType.trim(),
      package.subscriptionType?.trim() ?? '',
    ].where((v) => v.isNotEmpty).map((v) => v.toUpperCase()).toList();

    return parts.join(' · ');
  }

  String _offerLabel(PackageEntity package) {
    final list = package.listPrice;
    final price = package.price;
    if (list != null && list > 0 && price >= 0 && list > price) {
      final percent = ((list - price) / list * 100).round();
      if (percent > 0) {
        return '$percent% OFF';
      }
    }
    final amount = package.discountAmount;
    if (amount != null && amount > 0) {
      final dec = amount % 1 == 0 ? 0 : 2;
      return '₹${amount.toStringAsFixed(dec)} OFF';
    }
    return '';
  }

  String _saveText(BuildContext context, PackageEntity package) {
    final l10n = context.bssSubL10n;
    final amount = package.discountAmount;
    if (amount != null && amount > 0) {
      final dec = amount % 1 == 0 ? 0 : 2;
      return l10n.saveAmount(amount.toStringAsFixed(dec));
    }
    final list = package.listPrice;
    if (list != null && list > package.price) {
      final save = list - package.price;
      final dec = save % 1 == 0 ? 0 : 2;
      return l10n.saveAmount(save.toStringAsFixed(dec));
    }
    return '';
  }

  String _seasonDiscountCaption(BuildContext context, PackageEntity package) {
    final l10n = context.bssSubL10n;
    final name = package.seasonName?.trim();
    if (name != null && name.isNotEmpty) {
      return '$name · ${l10n.seasonDiscount}';
    }
    final badge = package.badgeLabel?.trim();
    if (badge != null &&
        badge.isNotEmpty &&
        badge.toUpperCase() != 'SEASONAL') {
      return badge;
    }
    return l10n.seasonDiscount;
  }
}

