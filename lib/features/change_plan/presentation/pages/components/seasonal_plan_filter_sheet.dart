import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/change_plan/seasonal_plan_api_filters.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';

class SeasonalPlanFilterSheet extends StatefulWidget {
  final String? currentSubscriptionType;
  final String? currentPackageType;
  final void Function(String? subscriptionType, String? packageType) onApply;

  const SeasonalPlanFilterSheet({
    super.key,
    this.currentSubscriptionType,
    this.currentPackageType,
    required this.onApply,
  });

  @override
  State<SeasonalPlanFilterSheet> createState() =>
      _SeasonalPlanFilterSheetState();
}

class _SeasonalPlanFilterSheetState extends State<SeasonalPlanFilterSheet> {
  String? _subscriptionType;
  String? _packageType;

  @override
  void initState() {
    super.initState();
    _subscriptionType = widget.currentSubscriptionType;
    _packageType = widget.currentPackageType;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColor.kDragHandleGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    l10n.filter,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _subscriptionType = null;
                        _packageType = null;
                      });
                    },
                    child: Text(
                      l10n.clear,
                      style: TextStyle(color: AppColor.kPrimaryColor),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.subscriptionType,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            RadioGroup<String>(
              groupValue: _subscriptionType,
              onChanged: (value) => setState(() => _subscriptionType = value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _subscriptionTile(
                    theme,
                    label: l10n.home,
                    value: SeasonalPlanApiFilters.subscriptionHome,
                  ),
                  _subscriptionTile(
                    theme,
                    label: l10n.sme,
                    value: SeasonalPlanApiFilters.subscriptionSme,
                  ),
                  _subscriptionTile(
                    theme,
                    label: l10n.ews,
                    value: SeasonalPlanApiFilters.subscriptionEws,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.planType,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            RadioGroup<String>(
              groupValue: _packageType,
              onChanged: (value) => setState(() => _packageType = value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _packageTypeTile(
                    theme,
                    label: l10n.fup,
                    value: SeasonalPlanApiFilters.packageFup,
                  ),
                  _packageTypeTile(
                    theme,
                    label: l10n.unlimited,
                    value: SeasonalPlanApiFilters.packageUnlimited,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: l10n.cancel,
                    borderRadius: 12,
                    backgroundColor: Colors.transparent,
                    borderColor: AppColor.kPrimaryColor,
                    foregroundColor: AppColor.kPrimaryColor,
                    onClicked: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PrimaryButton(
                    label: l10n.search,
                    borderRadius: 12,
                    isLoading: false,
                    onClicked: () {
                      Navigator.pop(context);
                      widget.onApply(_subscriptionType, _packageType);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _subscriptionTile(
    ThemeData theme, {
    required String label,
    required String value,
  }) {
    return InkWell(
      onTap: () => setState(() => _subscriptionType = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: Radio<String>(
                value: value,
                activeColor: AppColor.kSecondaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }

  Widget _packageTypeTile(
    ThemeData theme, {
    required String label,
    required String value,
  }) {
    return InkWell(
      onTap: () => setState(() => _packageType = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: Radio<String>(
                value: value,
                activeColor: AppColor.kSecondaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
