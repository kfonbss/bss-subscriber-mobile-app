import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class AboutKfonPage extends StatelessWidget {
  const AboutKfonPage({super.key});

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            color: const Color(0xFF0F1121),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            height: 1.3,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          content,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            color: Colors.black.withOpacity(0.7),
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            height: 1.8,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const loremIpsumText =
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting";

    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'About Kfon',
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
                  // KFON Section
                  _buildSection(title: 'KFON', content: loremIpsumText),
                  SizedBox(height: 20.h),
                  // Mission Section
                  _buildSection(title: 'Mission', content: loremIpsumText),
                  SizedBox(height: 20.h),
                  // Achievements Section
                  _buildSection(
                    title: 'Achievements',
                    content: loremIpsumText,
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
