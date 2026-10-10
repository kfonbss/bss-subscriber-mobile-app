import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

/// Segmented tab bar: light grey track with a white pill that slides to the
/// selected tab.
///
/// ```dart
/// CommonTabBar(
///   tabs: [l10n.today, l10n.thisWeek, l10n.thisMonth],
///   selectedIndex: periodIndex,
///   onChanged: (index) => ...,
/// )
/// ```
class CommonTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double? height;

  const CommonTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.height,
  });

  static const _duration = Duration(milliseconds: 250);
  static const _curve = Curves.easeOutCubic;

  static const _trackDecoration = BoxDecoration(
    color: AppColor.kBlack4,
    border: Border.fromBorderSide(BorderSide(color: Colors.white)),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
  static const _pillDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(10)),
    boxShadow: [
      BoxShadow(color: AppColor.kBlack5, blurRadius: 4, offset: Offset(0, 2)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final count = tabs.length;
    final index = selectedIndex.clamp(0, count - 1);
    // -1 = first tab, 1 = last tab.
    final pillX = count == 1 ? 0.0 : -1 + 2 * index / (count - 1);

    return Container(
      height: height ?? 48.h,
      padding: EdgeInsets.all(4.w),
      decoration: _trackDecoration,
      child: Stack(
        children: [
          // Sliding selected pill
          AnimatedAlign(
            alignment: Alignment(pillX, 0),
            duration: _duration,
            curve: _curve,
            child: FractionallySizedBox(
              widthFactor: 1 / count,
              heightFactor: 1,
              child: const DecoratedBox(decoration: _pillDecoration),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < count; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (i != index) onChanged(i);
                    },
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: _duration,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color:
                              i == index
                                  ? AppColor.kNearBlack
                                  : AppColor.kTabBarUnselectedText,
                        ),
                        child: Text(
                          tabs[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
