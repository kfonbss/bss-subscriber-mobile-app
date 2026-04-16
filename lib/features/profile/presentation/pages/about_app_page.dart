import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  static Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return _AppSection(title: title, children: children);
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
                  _buildSection(
                    title: l10n.appInformation,
                    children: [
                      _AppInfoItem(
                        title: l10n.appVersion,
                        value: 'v10.2.2',
                      ),
                      _AppInfoItem(
                        title: l10n.copyright,
                        value: '@2025kfon.in',
                      ),
                    ],
                  ),
                  _buildSection(
                    title: l10n.legal,
                    children: [
                      _AppInfoItem(
                        title: l10n.termsOfService,
                        isTappable: true,
                        onTap: () {
                          // TODO: Navigate to Terms of Service page
                        },
                      ),
                      _AppInfoItem(
                        title: l10n.privacyPolicy,
                        isTappable: true,
                        onTap: () {
                          // TODO: Navigate to Privacy Policy page
                        },
                      ),
                    ],
                  ),
                  _buildSection(
                    title: l10n.support,
                    children: [
                      _AppInfoItem(
                        title: l10n.contactUs,
                        isTappable: true,
                        onTap: () {
                          // TODO: Navigate to Contact Us page or open contact options
                        },
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
}

// ── Section wrapper ───────────────────────────────────────────────────────────
class _AppSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _AppSection({required this.title, required this.children});

  static final _headingStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _headingStyle),
        SizedBox(height: 16.h),
        ...children,
        SizedBox(height: 20.h),
      ],
    );
  }
}

// ── Info item row ─────────────────────────────────────────────────────────────
// Extracted from _buildInfoItem so Flutter can track each row's identity.
class _AppInfoItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isTappable;
  final VoidCallback? onTap;

  const _AppInfoItem({
    required this.title,
    this.value = '',
    this.isTappable = false,
    this.onTap,
  });

  static final _itemDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12.w)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColor.kinputFiledLightBorder, width: 1.w),
    ),
  );
  static final _inkRadius = BorderRadius.all(Radius.circular(12.w));
  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );
  static final _valueStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kPrimaryColor,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: _itemDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isTappable ? onTap : null,
          borderRadius: _inkRadius,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Text(title, style: _titleStyle),
                const Spacer(),
                if (isTappable)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16.w,
                    color: AppColor.kMediumGrey,
                  )
                else
                  Text(value, style: _valueStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
