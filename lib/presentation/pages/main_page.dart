import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/constant/constant_dimensions.dart';
import 'package:kfon_subscriber/presentation/pages/home_page.dart';
import 'package:kfon_subscriber/presentation/ui_component/tabbar_material_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController(initialPage: 0);
  late int _selectedIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onChangedTab(int index) {
    setState(() {
      this._selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColor.kToolbarBackground,
        toolbarHeight: AppDimensions.kDefaultToolbarHeights,
        actionsPadding: EdgeInsets.only(right: 15),
        actions: [
          Image.asset(
            'assets/bottomNaviBarIcons/chat.png',
            width: AppDimensions.kActionButtonSize,
            height: AppDimensions.kActionButtonSize,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 15),
          Image.asset(
            'assets/icons/notification_white.png',
            width: AppDimensions.kActionButtonSize,
            height: AppDimensions.kActionButtonSize,
            fit: BoxFit.cover,
          ),
        ],
        title: SizedBox(
          height: 45.0,
          child: Image.asset(
            'assets/images/logo_transparent.png',
            fit: BoxFit.fitHeight,
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Remove padding from the top
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Drawer Header',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                // Handle tap for Home
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Handle tap for Settings
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: TabBarMaterialWidget(index: _selectedIndex, onChangedTab: onChangedTab),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: AppColor.kPrimaryColor,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Image.asset('assets/bottomNaviBarIcons/headphone.png',),
        ),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: PageView(

        controller: _pageController,
        children: <Widget>[
          Center(child: HomePage()),
          Center(child: HomePage()),
          Center(child: HomePage()),
          Center(child: HomePage()),
        ],
      ),
    );
  }
}
