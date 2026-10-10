import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';

class SpeedFilterSheet extends StatefulWidget {
  final int? currentSpeed;
  final ValueChanged<int?> onApply;

  const SpeedFilterSheet({super.key, this.currentSpeed, required this.onApply});

  @override
  State<SpeedFilterSheet> createState() => _SpeedFilterSheetState();
}

class _SpeedFilterSheetState extends State<SpeedFilterSheet> {
  int? _selectedSpeed;

  static const List<int> _speedOptions = [10, 20, 30, 60, 100, 150];

  static const _dragHandleDecoration = BoxDecoration(
    color: AppColor.kDragHandleGrey,
    borderRadius: BorderRadius.all(Radius.circular(2)),
  );

  @override
  void initState() {
    super.initState();
    _selectedSpeed = widget.currentSpeed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.bssSubL10n;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: _dragHandleDecoration,
            ),
          ),
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  l10n.filterBySpeed,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSpeed = null),
                  child: Text(
                    l10n.clear,
                    style: TextStyle(color: AppColor.kPrimaryColor),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          RadioGroup<int>(
            groupValue: _selectedSpeed,
            onChanged: (value) => setState(() => _selectedSpeed = value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  _speedOptions
                      .map((speed) => _buildSpeedTile(speed, theme, l10n))
                      .toList(),
            ),
          ),
          SizedBox(height: 20.h),
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
                    widget.onApply(_selectedSpeed);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedTile(int speed, ThemeData theme, BssSubLocalizations l10n) {
    return InkWell(
      onTap: () => setState(() => _selectedSpeed = speed),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: Radio<int>(
                value: speed,
                activeColor: AppColor.kPrimaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            SizedBox(width: 12.w),
            Text(l10n.mbps(speed), style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
