import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class TabBarMaterialWidget extends StatefulWidget {
  final ValueChanged<int> onChangedTab;

  const TabBarMaterialWidget({super.key, required this.onChangedTab});

  @override
  State<TabBarMaterialWidget> createState() => _TabBarMaterialWidgetState();
}

class _TabBarMaterialWidgetState extends State<TabBarMaterialWidget> {
  int selectedIndex = 0;

  // ── Static styles & decorations — allocated once, shared across all rebuilds
  static const _selectedTextStyle = TextStyle(
    color: AppColor.kPrimaryColor,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
  static const _unselectedTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
  static const _selectedIndicator = BoxDecoration(
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
      height: 70,
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
            child: _buildTabItem(index: 0, icon: 'home', label: 'Home'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: _buildTabItem(index: 1, icon: 'self_care', label: 'Self care'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: _buildTabItem(index: 2, icon: 'chat', label: 'FAQ'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildTabItem(index: 3, icon: 'profile', label: 'Profile'),
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
      onTap: () => setState(() {
        selectedIndex = index;
        widget.onChangedTab(index);
      }),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ImageIcon(
            AssetImage('assets/bottomNaviBarIcons/$icon.png'),
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
                height: 2,
                width: 5,
                decoration: isSelected ? _selectedIndicator : _unselectedIndicator,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
