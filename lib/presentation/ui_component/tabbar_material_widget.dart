import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class TabBarMaterialWidget extends StatefulWidget {
  final ValueChanged<int> onChangedTab;

  const TabBarMaterialWidget({super.key, required this.onChangedTab});

  @override
  _TabBarMaterialWidgetState createState() => _TabBarMaterialWidgetState();
}

class _TabBarMaterialWidgetState extends State<TabBarMaterialWidget> {
  int selectedIndex = 0;

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
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: _buildTabItem(index: 0, icon: 'home', label: 'Home'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: _buildTabItem(
              index: 1,
              icon: 'self_care',
              label: 'Self care',
            ),
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
            size: 25,
            AssetImage('assets/bottomNaviBarIcons/$icon.png'),
            color:
                index == selectedIndex ? AppColor.kPrimaryColor : Colors.black,
          ),
          Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color:
                      index == selectedIndex
                          ? AppColor.kPrimaryColor
                          : Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                height: 2,
                width: 5,
                decoration: BoxDecoration(
                  color:
                      index == selectedIndex
                          ? AppColor.kPrimaryColor
                          : Colors.white,
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
