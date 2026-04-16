import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class AboutKfonPage extends StatelessWidget {
  const AboutKfonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: l10n.aboutKfon,
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
                  _KfonSection(title: l10n.kfon, content: l10n.kfonDescription),
                  SizedBox(height: 20.h),
                  _KfonSection(
                    title: l10n.mission,
                    content: l10n.missionDescription,
                  ),
                  SizedBox(height: 20.h),
                  _KfonSection(
                    title: l10n.achievements,
                    content: l10n.achievementsDescription,
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

// ── Content section ───────────────────────────────────────────────────────────
// Extracted from _buildSection so Flutter can track each section's identity.
class _KfonSection extends StatelessWidget {
  final String title;
  final String content;

  const _KfonSection({required this.title, required this.content});

  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );
  // 0xB3 = 179 ≈ 0.7 × 255 → Colors.black @ 70% opacity
  static final _contentStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: const Color(0xB3000000),
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.8,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _titleStyle),
        SizedBox(height: 10.h),
        Text(content, style: _contentStyle),
      ],
    );
  }
}
