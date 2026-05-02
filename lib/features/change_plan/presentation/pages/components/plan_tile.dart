import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/app_styles.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

class PlanTile extends StatelessWidget {
  final PackageItemEntity package;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanTile({
    super.key,        // exposes key so callers can pass ValueKey(package.packageId)
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Only titleStyle stays here — detailLabel/Value styles live in _PlanDetail
    // so each _PlanDetail rebuilds independently with the correct theme data.
    final titleStyle =
        Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600);
    final l10n = context.bssSubL10n;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(right: 6, top: 6),
            decoration: isSelected
                ? AppStyles.boxDecorationSmall.copyWith(
                    border: Border.all(color: AppColor.kPrimaryColor, width: 1),
                  )
                : AppStyles.boxDecorationSmall,
            child: Column(
              children: [
                Row(
                  children: [
                    // const-constructible: radius, backgroundColor, and Icon
                    // child are all compile-time constants.
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColor.kMainBackgroundColor,
                      child: Icon(
                        Icons.language,
                        size: 14,
                        color: AppColor.kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(package.packageName, style: titleStyle),
                    ),
                    Text(
                      '₹ ${package.renewalFee.toStringAsFixed(2)}',
                      style: titleStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Detail row — const BoxDecoration replaces the previous
                // BoxDecoration(borderRadius: BorderRadius.circular(12)) that
                // was allocating a new object on every build().
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColor.kSecondaryBackgroundColor,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _PlanDetail(label: l10n.data, value: '${package.allocatedVolume}'),
                      ),
                      Expanded(
                        child: _PlanDetail(label: l10n.speed, value: '${package.speedInKbps/1024}'),
                      ),
                      Expanded(
                        child: _PlanDetail(
                          label: l10n.validity,
                          value: '${package.renewPeriod} ${l10n.day}',
                        ),
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

/// Extracted from the old `_planDetail` helper method so that Flutter's widget
/// reconciliation engine can track identity and skip rebuilds when [label] and
/// [value] haven't changed.  Helper methods returning Widget always force a
/// full subtree rebuild; a StatelessWidget does not.
class _PlanDetail extends StatelessWidget {
  final String label;
  final String value;

  const _PlanDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: AppColor.kTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
