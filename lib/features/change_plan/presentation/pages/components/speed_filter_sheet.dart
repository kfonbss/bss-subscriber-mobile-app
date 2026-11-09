import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';

/// "Filter By Speed" bottom sheet. Show it with `showAppModalBottomSheet`,
/// which already draws the drag handle. Tapping the selected speed again
/// clears it (Search then applies "any speed").
class SpeedFilterSheet extends StatefulWidget {
  final int? currentSpeed;
  final ValueChanged<int?> onApply;

  const SpeedFilterSheet({super.key, this.currentSpeed, required this.onApply});

  @override
  State<SpeedFilterSheet> createState() => _SpeedFilterSheetState();
}

class _SpeedFilterSheetState extends State<SpeedFilterSheet> {
  int? _selectedSpeed;

  static const List<int> _speedOptions = [10, 20, 30, 50, 100, 150];

  @override
  void initState() {
    super.initState();
    _selectedSpeed = widget.currentSpeed;
  }

  void _toggle(int speed) {
    setState(() => _selectedSpeed = _selectedSpeed == speed ? null : speed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.filterBySpeed,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: AppColor.kTextSecondaryDark,
            ),
          ),
          SizedBox(height: 16.h),
          RadioGroup<int>(
            groupValue: _selectedSpeed,
            onChanged: (value) {
              if (value != null) _toggle(value);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final speed in _speedOptions) ...[
                  _buildSpeedTile(context, speed),
                  SizedBox(height: 10.h),
                ],
              ],
            ),
          ),
          SizedBox(height: 14.h),
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
              SizedBox(width: 20.w),
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

  Widget _buildSpeedTile(BuildContext context, int speed) {
    final selected = _selectedSpeed == speed;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _toggle(speed),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              SizedBox(
                width: 16.w,
                height: 16.h,
                child: Radio<int>(
                  value: speed,
                  activeColor: AppColor.kPrimaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                context.bssSubL10n.mbps(speed),
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  color:
                      selected
                          ? AppColor.kPrimaryColor
                          : AppColor.kTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
