import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/page_component/intro_screen_layout.dart';

class IntroScreenPage extends StatefulWidget {
  const IntroScreenPage({super.key});

  @override
  State<IntroScreenPage> createState() => _IntroScreenPageState();
}

class _IntroScreenPageState extends State<IntroScreenPage> {
  late final PageController _pageController;
  final duration = Duration(milliseconds: 500);

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kPrimaryColor,
      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/images/intro_screen_background.svg',
            fit: BoxFit.cover,
          ),
          PageView(
            controller: _pageController,
            children: <Widget>[
              IntroScreenLayout(
                index: 0,
                imageName: 'intro_one.svg',
                heading: context.bssSubL10n.stayConnectedAlways,
                description:
                    context.bssSubL10n.experienceLightningFast,
                nextButtonCallback:
                    () => _pageController.animateToPage(
                      1,
                      duration: duration,
                      // Duration of the animation
                      curve: Curves.easeIn,
                    ),
              ),
              IntroScreenLayout(
                index: 1,
                imageName: 'intro_two.svg',
                heading: context.bssSubL10n.bridgingDigitalDivide,
                description:
                    context.bssSubL10n.kfonEmpowersCitizen,
                nextButtonCallback:
                    () => _pageController.animateToPage(
                      2,
                      duration: duration,
                      curve: Curves.easeIn,
                    ),
              ),
              IntroScreenLayout(
                index: 2,
                imageName: 'intro_three.svg',
                heading: context.bssSubL10n.internetWorksForYou,
                description:
                    context.bssSubL10n.enjoyHighSpeed,
                nextButtonCallback: () {
                  PreferenceUtils.setIntroScreenStatus(false);
                  Navigator.pushReplacementNamed(context, AppRoutes.tenant);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
