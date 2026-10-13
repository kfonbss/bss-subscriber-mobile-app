import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/app_brand.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/constant/mis_constant.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/feedback/presentation/widgets/app_feedback_sheet.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/common_webview_page.dart';
import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAppPage extends StatelessWidget {
  AboutAppPage({super.key});

  final DialogUtil _dialogUtil = DialogUtil();

  Widget _buildInfoItem({
    required String title,
    required String value,
    bool isTappable = false,
    VoidCallback? onTap,
  }) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: Color(0xFFEAEAEA), width: 1.w),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isTappable ? onTap : null,
          borderRadius: BorderRadius.circular(12.w),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    color: const Color(0xFF0F1121),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3.h,
                    letterSpacing: 0,
                  ),
                ),
                const Spacer(),
                if (isTappable)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16.w,
                    color: Colors.grey.shade500,
                  )
                else
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      color: AppColor.kPrimaryColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.3.h,
                      letterSpacing: 0,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'General Sans',
            color: const Color(0xFF0F1121),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            height: 1.3.h,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 16.h),
        ...children,
        SizedBox(height: 20.h),
      ],
    );
  }

  void _goTOWebview(
      BuildContext context,
      String url,
      BssSubLocalizations l10n,
      ) {
    if (url.isEmpty) {
      _dialogUtil.showCustomSnackbar(
        context: context,
        content: context.bssSubL10n.notAvailable,
        backgroundColor: Colors.orange,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommonWebviewPage(title: l10n.termsOfService, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: l10n.aboutApp,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 50.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Information Section
                  _buildSection(
                    title: l10n.appInformation,
                    children: [
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          final version = snapshot.hasData
                              ? 'v${snapshot.data!.version}'
                              : 'v1.0.0';
                          return _buildInfoItem(
                            title: l10n.appVersion,
                            value: version,
                            isTappable: false,
                          );
                        },
                      ),
                      _buildInfoItem(
                        title: l10n.copyright,
                        value: AppBrand.isRailWire
                            ? MisConstant.kRailWireCopyright
                            : MisConstant.kKfonCopyright,
                        isTappable: false,
                      ),
                    ],
                  ),
                  // Legal Section
                  _buildSection(
                    title: l10n.legal,
                    children: [
                      _buildInfoItem(
                        title: l10n.termsOfService,
                        value: '',
                        isTappable: true,
                        onTap: () => _goTOWebview(
                          context,
                          AppBrand.isRailWire
                              ? MisConstant.kRailwireTermsOfService
                              : MisConstant.kKfonTermsOfService,
                          l10n,
                        ),
                      ),
                      _buildInfoItem(
                        title: l10n.privacyPolicy,
                        value: '',
                        isTappable: true,
                        onTap: () => _goTOWebview(
                          context,
                          AppBrand.isRailWire
                              ? MisConstant.kRailwirePrivacyPolicy
                              : MisConstant.kKfonPrivacyPolicy,
                          l10n,
                        ),
                      ),
                    ],
                  ),
                  // Support Section
                  _buildSection(
                    title: l10n.support,
                    children: [
                      _buildInfoItem(
                        title: l10n.contactUs,
                        value: '',
                        isTappable: true,
                        onTap: () => _showContactUsBottomSheet(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactUsBottomSheet(BuildContext context) {
    final contactText = AppBrand.isRailWire
        ? MisConstant.kRailwireContactUs
        : MisConstant.kKfonContactUs;
    if (contactText.isEmpty) {
      _dialogUtil.showCustomSnackbar(
        context: context,
        content: context.bssSubL10n.notAvailable,
        backgroundColor: Colors.orange,
      );
      return;
    }
    showAppModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      topRadius: 20,
      dragHandleColor: AppColor.kTextSecondaryLight,
      dragHandleSize: Size(50.w, 5.h),
      dragHandlePadding: EdgeInsets.only(top: 16.h, bottom: 16.h),
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 36.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.bssSubL10n.contactUs,
              style: TextStyle(
                fontFamily: 'General Sans',
                color: const Color(0xFF0F1121),
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                height: 1.3.h,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              contactText,
              style: TextStyle(
                fontFamily: 'General Sans',
                color: const Color(0xFF5C5C5C),
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                height: 1.5.h,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: SecondaryButton(
                label: context.bssSubL10n.close,
                borderRadius: 12,
                onClicked: () => Navigator.pop(context),
                textStyle: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.3.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}