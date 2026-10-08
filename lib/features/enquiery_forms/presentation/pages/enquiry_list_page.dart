import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
// import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/form_app_bar.dart';
// import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';

class EnquiryFormList extends StatelessWidget {
  const EnquiryFormList({super.key});

  static const Color _pageBackground = Color(0xFFF8FAFC);
  static const Color _titleColor = Color(0xFF111827);
  static const Color _subtitleColor = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    // final l10n = context.bssSubL10n;

    return FormAppBar(
      showBackButton: true,
      body: ColoredBox(
        color: _pageBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text.rich(
                  TextSpan(
                    text: 'Apply for a ',
                    children: [
                      TextSpan(
                        text: 'New Connection',
                        style: TextStyle(color: AppColor.kPrimaryColor),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: _titleColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose the right type of connection\nbased on your needs',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: _subtitleColor,
                ),
              ),
              const SizedBox(height: 28),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 14,
                  children: [
                    Expanded(
                      child: _EnquiryTypeCard(
                        backgroundImage: AppAssets.enquiryHomeBg,
                        icon: AppAssets.enquiryHomeIcon,
                        title: 'Home Connection',
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.homeEnquiryForm,
                            ),
                      ),
                    ),
                    Expanded(
                      child: _EnquiryTypeCard(
                        backgroundImage: AppAssets.enquiryDarkFiberBg,
                        icon: AppAssets.enquiryDarkFiberIcon,
                        title: 'Dark Fiber',
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.darkFibreEnquiryForm,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 14,
                  children: [
                    Expanded(
                      child: _EnquiryTypeCard(
                        backgroundImage: AppAssets.enquiryCorporateBg,
                        icon: AppAssets.enquiryCorporateIcon,
                        title: 'Corporate',
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              '/corporate_enquiry_form',
                            ),
                      ),
                    ),
                    Expanded(
                      child: _EnquiryTypeCard(
                        backgroundImage: AppAssets.enquiryPartnerBg,
                        icon: AppAssets.enquiryPartnerIcon,
                        title: 'Partner Enquiry',
                        // TODO: Partner Enquiry route is not decided yet.
                        onTap: null,
                      ),
                    ),
                  ],
                ),
              ),

              // Hidden for now (not part of the current design):
              // SecondaryButton(
              //   label: l10n.government,
              //   onClicked: () => Navigator.pushNamed(
              //       context, AppRoutes.governmentEnquiryForm),
              // ),
              // SecondaryButton(
              //   label: l10n.bplEnquiry,
              //   onClicked: () =>
              //       Navigator.pushNamed(context, AppRoutes.bplEnquiryForm),
              // ),
              // SecondaryButton(
              //   label: l10n.lnpEnquiry,
              //   onClicked: () =>
              //       Navigator.pushNamed(context, AppRoutes.lnpEnquiryForm),
              // ),
              // SecondaryButton(
              //   label: l10n.agnpEnquiry,
              //   onClicked: () =>
              //       Navigator.pushNamed(context, AppRoutes.agnpEnquiryForm),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnquiryTypeCard extends StatelessWidget {
  const _EnquiryTypeCard({
    required this.backgroundImage,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final String backgroundImage;
  final String icon;
  final String title;
  final VoidCallback? onTap;

  static const double _imageHeight = 96;
  static const double _iconCircleSize = 40;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      backgroundImage,
                      height: _imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: -_iconCircleSize / 2,
                    child: Container(
                      width: _iconCircleSize,
                      height: _iconCircleSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(icon, width: 20, height: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _iconCircleSize / 2 + 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: EnquiryFormList._titleColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
