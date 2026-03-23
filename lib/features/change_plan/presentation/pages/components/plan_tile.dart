import 'package:kfon_subscriber/core/constant/app_styles.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:flutter/material.dart';

class PlanTile extends StatelessWidget {
  final PackageEntity package;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanTile({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(right: 6, top: 6),
            decoration: AppStyles.boxDecorationSmall.copyWith(
              border: isSelected
                  ? Border.all(color: AppColor.kPrimaryColor, width: 1)
                  : null,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColor.kMainBackgroundColor,
                      child: Icon(
                        Icons.language,
                        size: 14,
                        color: AppColor.kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Plan name
                    Expanded(
                      child: Text(
                        package.packageName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Price
                    Text(
                      '₹ ${package.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Plan details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.kSecondaryBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _planDetail(context, 'Data', package.data),
                      ),
                      Expanded(
                        child: _planDetail(context, 'Speed', package.speed),
                      ),
                      Expanded(
                        child: _planDetail(
                          context,
                          'Validity',
                          '${package.validity} Days',
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
                child: Icon(
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

  Widget _planDetail(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColor.kTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
