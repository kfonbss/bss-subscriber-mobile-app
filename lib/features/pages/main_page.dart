import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/pages/chat_page.dart';
import 'package:kfon_subscriber/features/pages/faq_page.dart';
import 'package:kfon_subscriber/features/self_care/presentation/pages/diagnostics_page.dart';
import 'package:kfon_subscriber/features/home/presentation/pages/home_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/pages/profile_page.dart';
import 'package:kfon_subscriber/features/ticket/presentation/pages/create_ticket_page.dart';
import 'package:kfon_subscriber/presentation/ui_component/help_option_card.dart';
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
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kMainBackgroundColor,
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
      bottomNavigationBar: TabBarMaterialWidget(onChangedTab: onChangedTab),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: AppColor.kPrimaryColor,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Image.asset('assets/bottomNaviBarIcons/headphone.png'),
        ),
        onPressed: () => _showHelpOptions(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          Center(child: HomePage()),
          Center(child: DiagnosticsPage()),
          Center(child: FaqPage()),
          Center(child: ProfilePage()),
        ],
      ),
    );
  }

  _showHelpOptions(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.kMainBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20, // -20px offset (content starts above)
              bottom: bottomPadding > 0 ? bottomPadding : 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag Handle - positioned (-42px from top, but in Column layout)
                Container(
                  width: 42,
                  height: 6,
                  margin: const EdgeInsets.only(top: 0, bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1E1E4),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                // Title and Subtitle section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Need Help?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF0F1121),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'We’re Here to assist you Anytime.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF354259),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 20 / 13,
                        // 20px line height for 13px font size
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Three Action Buttons - exact sizes: 98px, 99px, 98px
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: HelpOptionCard(
                        icon: 'chat.png',
                        label: 'Chat with Us',
                        containerWidth: 98,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _gotoChatPage('Chat with Us');
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: HelpOptionCard(
                        icon: 'chat_with_ai.png',
                        label: 'Chat with AI',
                        containerWidth: 99,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _gotoChatPage('Chat with AI');
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: HelpOptionCard(
                        icon: 'callback.svg',
                        label: 'Call Back',
                        isSvg: true,
                        isImageAsset: true,
                        containerWidth: 98,
                        iconColor: AppColor.kPrimaryColor,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _showCallbackConfirmation(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Bottom Action Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateTicketPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF8D0247),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          'Create Ticket',
                          style: const TextStyle(
                            color: Color(0xFF8D0247),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    // Talk to our Agent Button (Filled)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          // TODO: Implement talk to agent functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D0247),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Talk to our Agent',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _gotoChatPage(String heading) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ChatPage(pageHeading: heading)),
    );
  }

  void _showCallbackConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.kMainBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFB9BAC0),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              // Title
              Text(
                'Call Back',
                style: const TextStyle(
                  color: Color(0xFF262629),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // Message
              Text(
                'Are you sure want to create call back request?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0F1121),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 30),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cancel Button
                  SizedBox(
                    width: 158,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF8D0247),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'Cancel',
                        style: const TextStyle(
                          color: Color(0xFF8D0247),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 21),
                  // Yes Button
                  SizedBox(
                    width: 158,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement callback request creation
                        DialogUtil().showCustomSnackbar(
                          context: context,
                          content: 'Ticket Created Successfully!',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8D0247),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Yes',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Home Indicator
              Container(
                margin: const EdgeInsets.only(top: 32, bottom: 8),
                width: 140,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF262629),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
