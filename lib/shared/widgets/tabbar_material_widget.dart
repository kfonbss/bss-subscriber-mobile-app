import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

/// Bar outline from the Figma "Bottom Navigation" background: a flat top with a
/// smooth curved dip (128.85 wide, 27.9 deep on a 375 frame) centred on the FAB.
class _CurvedNotchShape extends NotchedShape {
  const _CurvedNotchShape();

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }
    final double s = host.width / 374.128;
    final double cx = guest.center.dx;
    final double top = host.top;
    return Path()
      ..moveTo(host.left, top)
      ..lineTo(cx - 64.427 * s, top)
      ..cubicTo(
        cx - 23.903 * s,
        top + 6.106 * s,
        cx - 25.167 * s,
        top + 27.905 * s,
        cx,
        top + 27.905 * s,
      )
      ..cubicTo(
        cx + 28.188 * s,
        top + 27.905 * s,
        cx + 21.305 * s,
        top + 6.978 * s,
        cx + 64.427 * s,
        top,
      )
      ..lineTo(host.right, top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}

class TabBarMaterialWidget extends StatefulWidget {
  final ValueChanged<int> onChangedTab;

  const TabBarMaterialWidget({super.key, required this.onChangedTab});

  @override
  State<TabBarMaterialWidget> createState() => _TabBarMaterialWidgetState();
}

class _TabBarMaterialWidgetState extends State<TabBarMaterialWidget> {
  int selectedIndex = 0;

  // ── Static styles & decorations — allocated once, shared across all rebuilds
  // Design: 10 / line 17.44, letter spacing 0.0872; selected is semibold.
  static get _selectedTextStyle => TextStyle(
    color: AppColor.kPrimaryColor,
    fontSize: 10.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 17.442 / 10,
    letterSpacing: 0.0872,
  );
  static TextStyle get _unselectedTextStyle => TextStyle(
    color: AppColor.kNeutralGray90,
    fontSize: 10.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 17.442 / 10,
    letterSpacing: 0.0872,
  );
  static get _selectedIndicator => BoxDecoration(
    color: AppColor.kPrimaryColor,
    borderRadius: BorderRadius.all(Radius.circular(87.209)),
  );
  static const _unselectedIndicator = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.all(Radius.circular(87.209)),
  );

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 70.h,
      // Design: smooth 129-wide, 28-deep curve instead of a circular notch.
      shape: const _CurvedNotchShape(),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      // M3 default padding (16 × 12) squeezed the tabs and caused overflow.
      padding: EdgeInsets.zero,
      // Design: soft black 11% shadow, blur ~19.
      elevation: 10.0,
      shadowColor: AppColor.kNavBarShadow,
      // Design: 20.93 side padding, tabs 48.84 wide and 26.16 apart in pairs
      // either side of the FAB; items sit ~15 below the bar top.
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.93.w, 8.h, 20.93.w, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 26.163.w,
              children: [
                _buildTabItem(
                  index: 0,
                  icon: AppAssets.homeTab,
                  label: context.bssSubL10n.home,
                ),
                _buildTabItem(
                  index: 1,
                  icon: AppAssets.selfCareTab,
                  label: context.bssSubL10n.selfCare,
                ),
              ],
            ),
            Row(
              spacing: 26.163.w,
              children: [
                _buildTabItem(
                  index: 2,
                  icon: AppAssets.chatTab,
                  label: context.bssSubL10n.faq,
                ),
                _buildTabItem(
                  index: 3,
                  icon: AppAssets.profileTab,
                  label: context.bssSubL10n.profile,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String icon,
    required String label,
  }) {
    final isSelected = index == selectedIndex;
    return InkWell(
      onTap:
          () => setState(() {
            selectedIndex = index;
            widget.onChangedTab(index);
          }),
      child: SizedBox(
        width: 48.837.w,
        // Scales down instead of overflowing when the bar is short (small
        // screens or a large bottom inset).
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.all(3.488.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ImageIcon(
                  AssetImage(icon),
                  size: 20.93.w,
                  color:
                      isSelected
                          ? AppColor.kPrimaryColor
                          : AppColor.kNeutralGray90,
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: isSelected ? _selectedTextStyle : _unselectedTextStyle,
                ),
                Container(
                  height: 2.616.h,
                  width: 4.36.w,
                  decoration:
                      isSelected ? _selectedIndicator : _unselectedIndicator,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
