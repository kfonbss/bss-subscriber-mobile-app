import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class TabBarMaterialWidget extends StatefulWidget {
  final ValueChanged<int> onChangedTab;

  const TabBarMaterialWidget({super.key, required this.onChangedTab});

  @override
  State<TabBarMaterialWidget> createState() => _TabBarMaterialWidgetState();
}

class _TabBarMaterialWidgetState extends State<TabBarMaterialWidget> {
  int selectedIndex = 0;

  // ── Static styles & decorations — allocated once, shared across all rebuilds
  static get _selectedTextStyle => TextStyle(
    color: AppColor.kPrimaryColor,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
  static const _unselectedTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
  static get _selectedIndicator => BoxDecoration(
    color: AppColor.kPrimaryColor,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );
  static const _unselectedIndicator = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 70.h,
      shape: const CircularNotchedRectangle(),
      color: Colors.white,
      notchMargin: 8.0,
      elevation: 10.0,
      shadowColor: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: _buildTabItem(
              index: 0,
              icon: AppAssets.homeTab,
              label: context.bssSubL10n.home,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: _buildTabItem(
              index: 1,
              icon: AppAssets.selfCareTab,
              label: context.bssSubL10n.selfCare,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: _buildTabItem(
              index: 2,
              icon: AppAssets.chatTab,
              label: context.bssSubL10n.faq,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildTabItem(
              index: 3,
              icon: AppAssets.profileTab,
              label: context.bssSubL10n.profile,
            ),
          ),
        ],
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ImageIcon(
            AssetImage(icon),
            size: 25,
            color: isSelected ? AppColor.kPrimaryColor : Colors.black,
          ),
          Column(
            children: [
              Text(
                label,
                style: isSelected ? _selectedTextStyle : _unselectedTextStyle,
              ),
              Container(
                height: 2.h,
                width: 5.w,
                decoration:
                    isSelected ? _selectedIndicator : _unselectedIndicator,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
