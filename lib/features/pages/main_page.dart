import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/home/presentation/pages/home_page.dart';
import 'package:kfon_subscriber/features/pages/chat_page.dart';
import 'package:kfon_subscriber/features/pages/faq/faq_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/pages/profile_page.dart';
import 'package:kfon_subscriber/features/self_care/presentation/pages/self_care_page.dart';
import 'package:kfon_subscriber/features/ticket/presentation/pages/create_ticket_page.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/help_option_card.dart';
import 'package:kfon_subscriber/presentation/ui_component/tabbar_material_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _currentIndex = ValueNotifier<int>(0);

  static const _pages = <Widget>[
    HomePage(),
    SelfCarePage(),
    FaqPage(),
    ProfilePage(),
  ];

  // ── Static decorations ────────────────────────────────────────────────────
  static const _helpDragHandleDecoration = BoxDecoration(
    color: AppColor.kDividerGrey,
    borderRadius: BorderRadius.all(Radius.circular(100)),
  );
  static const _callbackDragHandleDecoration = BoxDecoration(
    color: AppColor.kDragHandleGrey,
    borderRadius: BorderRadius.all(Radius.circular(100)),
  );
  static const _homeIndicatorDecoration = BoxDecoration(
    color: AppColor.kNearBlack,
    borderRadius: BorderRadius.all(Radius.circular(100)),
  );

  // ── Static text styles ────────────────────────────────────────────────────
  static const _sheetTitleStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFamily: 'GeneralSans',
  );
  static const _sheetSubtitleStyle = TextStyle(
    color: AppColor.kDarkBlue,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 20 / 13,
    fontFamily: 'GeneralSans',
  );
  static const _buttonLabelStyle = TextStyle(
    color: AppColor.kPrimaryColor,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFamily: 'GeneralSans',
  );
  static const _filledButtonLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFamily: 'GeneralSans',
  );
  static const _callbackTitleStyle = TextStyle(
    color: AppColor.kNearBlack,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const _callbackBodyStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.6,
  );

  @override
  void dispose() {
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kMainBackgroundColor,
      bottomNavigationBar: TabBarMaterialWidget(
        onChangedTab: (i) => _currentIndex.value = i,
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: AppColor.kPrimaryColor,
        elevation: 5,
        onPressed: () => _showHelpOptions(context),
        child: const Padding(
          padding: EdgeInsets.all(15.0),
          child: Image(image: AssetImage('assets/bottomNaviBarIcons/headphone.png')),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: ValueListenableBuilder<int>(
        valueListenable: _currentIndex,
        builder: (_, index, __) => IndexedStack(
          index: index,
          children: _pages,
        ),
      ),
    );
  }

  void _showHelpOptions(BuildContext context) {
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
              top: 20,
              bottom: bottomPadding > 0 ? bottomPadding : 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag Handle
                Container(
                  width: 42,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: _helpDragHandleDecoration,
                ),
                // Title and Subtitle — inlined; no redundant Column wrapper
                const Text(
                  'Need Help?',
                  textAlign: TextAlign.center,
                  style: _sheetTitleStyle,
                ),
                const SizedBox(height: 4),
                const Text(
                  'We\u2019re Here to assist you Anytime.',
                  textAlign: TextAlign.center,
                  style: _sheetSubtitleStyle,
                ),
                const SizedBox(height: 30),
                // Three Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: HelpOptionCard(
                        icon: 'chat.png',
                        label: context.bssSubL10n.chatWithUs,
                        containerWidth: 98,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _gotoChatPage(context.bssSubL10n.chatWithUs);
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: HelpOptionCard(
                        icon: 'chat_with_ai.png',
                        label: context.bssSubL10n.chatwithAI,
                        containerWidth: 99,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _gotoChatPage(context.bssSubL10n.chatwithAI);
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
                // Create Ticket Button (Outlined)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateTicketPage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColor.kPrimaryColor, width: 1),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text('Create Ticket', style: _buttonLabelStyle),
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
                      backgroundColor: AppColor.kPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Talk to our Agent', style: _filledButtonLabelStyle),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _gotoChatPage(String heading) {
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
      builder: (BuildContext ctx) {
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
                decoration: _callbackDragHandleDecoration,
              ),
              // Title
              const Text('Call Back', style: _callbackTitleStyle),
              const SizedBox(height: 24),
              // Message
              const Text(
                'Are you sure want to create call back request?',
                textAlign: TextAlign.center,
                style: _callbackBodyStyle,
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
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColor.kPrimaryColor, width: 1),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text('Cancel', style: _buttonLabelStyle),
                    ),
                  ),
                  const SizedBox(width: 21),
                  // Yes Button
                  SizedBox(
                    width: 158,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        // TODO: Implement callback request creation
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Yes', style: _filledButtonLabelStyle),
                    ),
                  ),
                ],
              ),
              // Home Indicator
              Container(
                margin: const EdgeInsets.only(top: 32, bottom: 8),
                width: 140,
                height: 5,
                decoration: _homeIndicatorDecoration,
              ),
            ],
          ),
        );
      },
    );
  }
}
