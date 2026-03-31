import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/extensions.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_bloc.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_event.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_state.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/security_settings_page.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/features/ticket/presentation/pages/tickets_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const FetchProfileRequested());
  }

  Widget _createAccountListItems(
    String image,
    String label, {
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 17.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      height: 70.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38.w,
                height: 38.h,
                padding: EdgeInsets.all(9),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF3F3FA),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/$image.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  height: 1.3,
                  color: textColor ?? const Color(0xFF0F1121),
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: const Color(0xFF67697A),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      title: 'My Profile',
      centerTitle: false,
      titleFontSize: 20.sp,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          // ── Profile Header (from BLoC) ──
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              String name = 'Loading...';
              String subscriberId = '';
              String status = '';

              if (state is ProfileLoaded) {
                name = state.profile.name;
                subscriberId = state.profile.subscriberId.toString();
                status = state.profile.status;
              } else if (state is ProfileError) {
                name = 'Error loading profile';
              }

              return Container(
                height: 100.h,
                decoration: BoxDecoration(
                  color: AppColor.kPrimaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundImage: const NetworkImage(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPrsHSSBc63zNawuN6LUuXgj58de3ciuETGw&s',
                        ),
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              height: 1.3,
                              color: Colors.white,
                            ),
                          ),
                          if (subscriberId.isNotEmpty)
                            Text(
                              'ID : $subscriberId',
                              style: TextStyle(
                                fontFamily: 'General Sans',
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                                height: 1.6,
                                color: Colors.white,
                              ),
                            ),
                          if (status.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(21),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontFamily: 'General Sans',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 9.sp,
                                  height: 1.6,
                                  color: const Color(0xFF219653),
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
          ),
          SizedBox(height: 24.h),
          Text(
            'Account',
            style: TextStyle(
              fontFamily: 'General Sans',
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 17),
          GestureDetector(
            onTap:
                () => Navigator.pushNamed(context, AppRoutes.accountInformationPage),
            child: _createAccountListItems(
              'account_information',
              'Account Information',
            ),
          ),
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder:
                        (context) => SecuritySettingsPage(
                          types: [
                            PasswordChangeEnum.bss,
                            PasswordChangeEnum.internet,
                          ],
                        ),
                  ),
                ),
            child: _createAccountListItems(
              'security_settings',
              'Security Settings',
            ),
          ),
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TicketsPage()),
                ),
            child: _createAccountListItems('my_tickets', 'My Tickets'),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.settingsPage),
            child: _createAccountListItems('settings', 'Settings'),
          ),
          GestureDetector(
            onTap: () => _showLogoutDialog(context),
            child: _createAccountListItems(
              'logout',
              'Logout',
              textColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          context.isTablet ? Colors.transparent : AppColor.kMainBackgroundColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            context.isTablet
                ? BorderRadius.circular(24.w)
                : BorderRadius.vertical(top: Radius.circular(24.w)),
      ),
      builder: (BuildContext context) {
        // Calculate responsive sizes for tablet
        final handleWidth = context.isTablet ? 42.0 * 1.2 : 42.w;
        final handleHeight = context.isTablet ? 6.0 * 1.2 : 6.h;
        final topPadding = context.isTablet ? 53.0 * 1.2 : 53.h;
        final horizontalPadding = context.isTablet ? 20.0 * 1.2 : 20.w;
        final bottomPadding = context.isTablet ? 30.0 * 1.2 : 30.h;
        final titleWidth = context.isTablet ? 193.0 * 1.2 : 193.w;
        final descWidth = context.isTablet ? 319.0 * 1.2 : 319.w;
        final buttonHeight = context.isTablet ? 52.0 * 1.2 : 52.h;
        final gapBetweenTitleDesc = context.isTablet ? 8.0 * 1.2 : 8.h;
        final gapBeforeButtons = context.isTablet ? 40.0 * 1.2 : 40.h;
        final gapBetweenButtons = context.isTablet ? 12.0 * 1.2 : 12.h;
        final handleTopMargin = context.isTablet ? 19.0 * 1.2 : 19.h;
        final maxWidth = context.isTablet ? 500.0 : double.infinity;

        Widget content = Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: topPadding,
                bottom:
                    bottomPadding + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: titleWidth,
                        child: Text(
                          'Are you sure you want to logout?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            color: const Color(0xFF0F1121),
                            fontSize: context.isTablet ? 18.0 * 1.2 : 18.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.2999999523162842,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      SizedBox(height: gapBetweenTitleDesc),
                      SizedBox(
                        width: descWidth,
                        child: Text(
                          'This will return you to the log in screen.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            color: const Color(0xFF67697A),
                            fontSize: context.isTablet ? 12.0 * 1.2 : 12.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.6,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: gapBeforeButtons),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) {
                            if (state is LogoutSuccess) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.login,
                                (Route<dynamic> route) => false,
                              );
                            } else if (state is LogoutFailure) {
                              DialogUtil().showCustomSnackbar(
                                context: context,
                                content: state.errorMessage,
                                backgroundColor: AppColor.kFailedRed,
                              );
                            }
                          },
                          builder: (context, state) {
                            final isLoading = state is LogoutLoading;

                            return ElevatedButton(
                              onPressed:
                                  isLoading
                                      ? null
                                      : () {
                                        context.read<AuthBloc>().add(
                                          const LogoutRequested(),
                                        );
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.kFailedRed,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColor.kFailedRed
                                    .withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.w),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  isLoading
                                      ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        'Logout',
                                        style: TextStyle(
                                          fontFamily: 'GeneralSans',
                                          fontSize:
                                              context.isTablet
                                                  ? 14.0 * 1.2
                                                  : 14.sp,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2999999523162842,
                                          letterSpacing: 0,
                                        ),
                                      ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: gapBetweenButtons),
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color.fromRGBO(0, 0, 0, 0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.w),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontSize: context.isTablet ? 14.0 * 1.2 : 14.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.2999999523162842,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: handleTopMargin,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: handleWidth,
                  height: handleHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1E1E4),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ],
        );

        if (context.isTablet) {
          return SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                decoration: BoxDecoration(
                  color: AppColor.kMainBackgroundColor,
                  borderRadius: BorderRadius.circular(24.w),
                ),
                child: content,
              ),
            ),
          );
        }

        return SafeArea(top: false, child: content);
      },
    );
  }
}
