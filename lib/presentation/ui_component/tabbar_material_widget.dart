import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class TabBarMaterialWidget extends StatefulWidget {
  final int index;
  final ValueChanged<int> onChangedTab;

  const TabBarMaterialWidget({
    super.key,
    required this.index,
    required this.onChangedTab,
  });

  @override
  _TabBarMaterialWidgetState createState() => _TabBarMaterialWidgetState();
}

class _TabBarMaterialWidgetState extends State<TabBarMaterialWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 70,
      shape: CircularNotchedRectangle(),
      color: Colors.white,
      notchMargin: 8.0,
      elevation: 10.0,
      shadowColor: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabItem(index: 0, icon: 'home', label: 'Home'),
          _buildTabItem(index: 1, icon: 'broadband', label: 'Broadband'),

          _buildTabItem(index: 2, icon: 'chat', label: 'FAQ'),
          _buildTabItem(index: 3, icon: 'profile', label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String icon,
    required String label,
  }) {
    final isSelected = index == widget.index;

    return InkWell(
      onTap: () => widget.onChangedTab(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ImageIcon(
            size: 25,
            AssetImage('assets/bottomNaviBarIcons/$icon.png'),
            color: isSelected ? AppColor.kPrimaryColor : Colors.black,
          ),
          Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColor.kPrimaryColor : Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                height: 2,
                width: 5,
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.kPrimaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
