import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedSpeed = widget.currentSpeed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
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
                  'Filter By Speed',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedSpeed = null);
                  },
                  child: Text(
                    'Clear',
                    style: TextStyle(color: AppColor.kPrimaryColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RadioGroup<int>(
            groupValue: _selectedSpeed,
            onChanged: (value) => setState(() => _selectedSpeed = value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _speedOptions
                  .map((speed) => _buildSpeedTile(speed, theme))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColor.kPrimaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColor.kPrimaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onApply(_selectedSpeed);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Search',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedTile(int speed, ThemeData theme) {
    return InkWell(
      onTap: () => setState(() => _selectedSpeed = speed),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Radio<int>(
                value: speed,
                activeColor: AppColor.kPrimaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 12),
            Text('$speed Mbps', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
