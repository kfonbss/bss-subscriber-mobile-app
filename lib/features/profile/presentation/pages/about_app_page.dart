import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

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
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1.w),
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
                    fontFamily: 'GeneralSans',
                    color: const Color(0xFF0F1121),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
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
                      fontFamily: 'GeneralSans',
                      color: AppColor.kPrimaryColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
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
            fontFamily: 'GeneralSans',
            color: const Color(0xFF0F1121),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            height: 1.3,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 16.h),
        ...children,
        SizedBox(height: 20.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'About App',
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
                    title: 'App Information',
                    children: [
                      _buildInfoItem(
                        title: 'App Version',
                        value: 'v10.2.2',
                        isTappable: false,
                      ),
                      _buildInfoItem(
                        title: 'Copyright',
                        value: '@2025kfon.in',
                        isTappable: false,
                      ),
                    ],
                  ),
                  // Legal Section
                  _buildSection(
                    title: 'Legal',
                    children: [
                      _buildInfoItem(
                        title: 'Terms of Service',
                        value: '',
                        isTappable: true,
                        onTap: () {
                          // TODO: Navigate to Terms of Service page
                        },
                      ),
                      _buildInfoItem(
                        title: 'Privacy Policy',
                        value: '',
                        isTappable: true,
                        onTap: () {
                          // TODO: Navigate to Privacy Policy page
                        },
                      ),
                    ],
                  ),
                  // Support Section
                  _buildSection(
                    title: 'Support',
                    children: [
                      _buildInfoItem(
                        title: 'Contact Us',
                        value: '',
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
