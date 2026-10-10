import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/home/presentation/pages/home_page.dart';
import 'package:kfon_subscriber/features/pages/chat_page.dart';
import 'package:kfon_subscriber/features/pages/faq/faq_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/pages/profile_page.dart';
import 'package:kfon_subscriber/features/self_care/presentation/pages/self_care_page.dart';
import 'package:kfon_subscriber/features/ticket/presentation/pages/create_ticket_page.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';
import 'package:kfon_subscriber/shared/widgets/help_option_card.dart';
import 'package:kfon_subscriber/shared/widgets/tabbar_material_widget.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';

/// [FloatingActionButtonLocation.centerDocked] lifted by [lift] pixels.
class _RaisedCenterDockedLocation extends FloatingActionButtonLocation {
  const _RaisedCenterDockedLocation(this.lift);

  final double lift;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final docked = FloatingActionButtonLocation.centerDocked.getOffset(
      geometry,
    );
    return Offset(docked.dx, docked.dy - lift);
  }
}

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
  static const _homeIndicatorDecoration = BoxDecoration(
    color: AppColor.kNearBlack,
    borderRadius: BorderRadius.all(Radius.circular(100)),
  );

  static get _buttonLabelStyle => TextStyle(
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
      floatingActionButton: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColor.kTealOverlay,
              blurRadius: 8.721,
              offset: Offset(0, 6.977),
            ),
          ],
        ),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: AppColor.kPrimaryColor,
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          onPressed: () => _showHelpOptions(context),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Image(image: AssetImage(AppAssets.headphone)),
          ),
        ),
      ),
      floatingActionButtonLocation: const _RaisedCenterDockedLocation(9),
      body: ValueListenableBuilder<int>(
        valueListenable: _currentIndex,
        builder: (_, index, __) => IndexedStack(index: index, children: _pages),
      ),
    );
  }

  void _showHelpOptions(BuildContext context) {
    // Background, top radius, drag handle and bottom safe area come from
    // showAppModalBottomSheet.
    showAppModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title and Subtitle — inlined; no redundant Column wrapper
              Text(
                context.bssSubL10n.needHelp,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.kTextSecondaryDark,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  fontFamily: 'GeneralSans',
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                context.bssSubL10n.hereToAssistAnytime,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.kDarkBlue,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  height: 20.h / 13.h,
                  fontFamily: 'GeneralSans',
                ),
              ),
              SizedBox(height: 30.h),
              // Three Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: HelpOptionCard(
                      icon: AppAssets.chat,
                      label: context.bssSubL10n.chatWithUs,
                      containerWidth: 98.w,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _gotoChatPage(context.bssSubL10n.chatWithUs);
                      },
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Flexible(
                    child: HelpOptionCard(
                      icon: AppAssets.chatWithAi,
                      label: context.bssSubL10n.chatwithAI,
                      containerWidth: 99.w,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _gotoChatPage(context.bssSubL10n.chatwithAI);
                      },
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Flexible(
                    child: HelpOptionCard(
                      icon: AppAssets.callback,
                      label: context.bssSubL10n.callBack,
                      containerWidth: 98.w,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _showCallbackConfirmation(context);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              // Create Ticket Button (Outlined)
              SecondaryButton(
                label: context.bssSubL10n.createTicket,
                borderRadius: 10,
                height: 52.h,
                backgroundColor: Colors.white,
                borderColor: AppColor.kPrimaryColor,
                foregroundColor: AppColor.kPrimaryColor,
                textStyle: _buttonLabelStyle,
                onClicked: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateTicketPage(),
                    ),
                  );
                },
              ),
              SizedBox(height: 13.h),
              // Talk to our Agent Button (Filled)
              PrimaryButton(
                label: context.bssSubL10n.talkToOurAgent,
                isLoading: false,
                borderRadius: 10,
                height: 52.h,
                textStyle: _filledButtonLabelStyle,
                onClicked: () {
                  Navigator.pop(sheetContext);
                  // TODO: Implement talk to agent functionality
                },
              ),
            ],
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
    showAppModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(context.bssSubL10n.callBack, style: _callbackTitleStyle),
              SizedBox(height: 24.h),
              // Message
              Text(
                context.bssSubL10n.confirmCallBackRequest,
                textAlign: TextAlign.center,
                style: _callbackBodyStyle,
              ),
              SizedBox(height: 30.h),
              // Buttons — two fixed 158 buttons + 21 gap (337) overflowed the
              // 335 left by the 20 side padding, so they share the width.
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: SecondaryButton(
                      label: context.bssSubL10n.cancel,
                      borderRadius: 10,
                      height: 52.h,
                      backgroundColor: Colors.white,
                      borderColor: AppColor.kPrimaryColor,
                      foregroundColor: AppColor.kPrimaryColor,
                      textStyle: _buttonLabelStyle,
                      onClicked: () => Navigator.pop(ctx),
                    ),
                  ),
                  SizedBox(width: 21.w),
                  // Yes Button
                  Expanded(
                    child: PrimaryButton(
                      label: context.bssSubL10n.yes,
                      isLoading: false,
                      borderRadius: 10,
                      height: 52.h,
                      textStyle: _filledButtonLabelStyle,
                      onClicked: () {
                        Navigator.pop(ctx);
                        // TODO: Implement callback request creation
                      },
                    ),
                  ),
                ],
              ),
              // Home Indicator
              Container(
                margin: const EdgeInsets.only(top: 32, bottom: 8),
                width: 140.w,
                height: 5.h,
                decoration: _homeIndicatorDecoration,
              ),
            ],
          ),
        );
      },
    );
  }
}
