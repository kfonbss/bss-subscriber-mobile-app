import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/extensions.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';
import 'package:kfon_subscriber/shared/widgets/tenant_svg_color_mapper.dart';

class DialogUtil {
  Widget get logo => Image.asset(AppAssets.kLogoAsset, height: 40.h);

   /// Session expired dialog: clock illustration, title, message and a
  /// full-width Login button. Not dismissible.
  Future<void> showSessionExpiredDialog({
    required BuildContext context,
    required VoidCallback onLogin,
  }) {
    final l10n = context.bssSubL10n;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 23.w, vertical: 40.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox.square(
                      dimension: 104.875.w,
                      child: FittedBox(
                        child: SvgPicture(
                          SvgAssetLoader(
                            AppAssets.logoutImage,
                            colorMapper: TenantSvgColorMapper(
                              extraColors: const {0xFF026DA7},
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      l10n.sessionExpired,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        color: AppColor.kTextSecondaryDark,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: 203.w,
                      child: Text(
                        l10n.yourSessionHasExpiredPleaseLogIn,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          color: AppColor.kDarkBlue,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          height: 20 / 13,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    PrimaryButton(
                      label: l10n.login,
                      isLoading: false,
                      height: 52.h,
                      borderRadius: 8,
                      backgroundColor: AppColor.kPrimaryColor,
                      onClicked: onLogin,
                      textStyle: TextStyle(
                        fontFamily: 'General Sans',
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showInsufficientBalanceDialog({
    required BuildContext context,
    required String title,
    required VoidCallback onRechargeWallet,
  }) {
    final l10n = context.bssSubL10n;
    final buttonTextStyle = TextStyle(
      fontFamily: 'General Sans',
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Design image keeps its own colours (no tenant mapping).
                    Center(
                      child: Image.asset(
                        AppAssets.insufficientBalanceWarning,
                        width: 75.w,
                        height: 75.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      l10n.insufficientBalance,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        color: AppColor.kTextSecondaryDark,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 7.h),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        color: AppColor.kDarkBlue,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        height: 20 / 13,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    PrimaryButton(
                      label: l10n.ok,
                      isLoading: false,
                      height: 52.h,
                      borderRadius: 8,
                      backgroundColor: AppColor.kPrimaryColor,
                      onClicked: onRechargeWallet,
                      textStyle: buttonTextStyle.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showCustomSnackbar({
    required BuildContext context,
    required String content,
    Color? backgroundColor,
    bool isError = false,
    Duration? duration,
  }) {
    final theme = Theme.of(context);
    final Color accentColor =
        backgroundColor ??
        (isError ? AppColor.kFailedRed : AppColor.kPrimaryColor);
    final Color themedBorderColor = (isError
            ? AppColor.kFailedRed
            : AppColor.kPrimaryColor)
        .withValues(alpha: 0.45);
    final Color themedShadowColor = (isError
            ? AppColor.kFailedRed
            : AppColor.kPrimaryColor)
        .withValues(alpha: 0.16);
    final IconData leadingIcon =
        isError ? Icons.error_outline_rounded : Icons.info_outline_rounded;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          content: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themedBorderColor, width: 1.2.w),
              boxShadow: [
                BoxShadow(
                  color: themedShadowColor,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 60.w,
                      color: accentColor,
                      alignment: Alignment.center,
                      child: Icon(leadingIcon, color: Colors.white, size: 30),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Text(
                          content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF2F3447),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          duration: duration ?? const Duration(seconds: 3),
        ),
      );
  }

  /// Shows a common logout confirmation dialog
  void showLogoutDialog(BuildContext context) {
    // Calculate responsive sizes for tablet
    final handleWidth = context.isTablet ? 42.0 * 1.2 : 42.w;
    final handleHeight = context.isTablet ? 6.0 * 1.2 : 6.h;
    final handleTopMargin = context.isTablet ? 19.0 * 1.2 : 19.h;
    // Design: content starts 53 from the sheet top.
    final topPadding = context.isTablet ? 53.0 * 1.2 : 53.h;

    showAppModalBottomSheet(
      context: context,
      useRootNavigator: true,
      topRadius: 30,
      dragHandleColor: const Color(0xFFE1E1E4),
      dragHandleSize: Size(handleWidth, handleHeight),
      dragHandlePadding: EdgeInsets.only(
        top: handleTopMargin,
        bottom: topPadding - handleTopMargin - handleHeight,
      ),
      builder: (BuildContext context) {
        final l10n = context.bssSubL10n;
        final horizontalPadding = context.isTablet ? 20.0 * 1.2 : 20.w;
        // Design: 56 below Cancel incl. the 34 home indicator (SafeArea).
        final bottomPadding = context.isTablet ? 30.0 * 1.2 : 22.h;
        final titleWidth = context.isTablet ? 193.0 * 1.2 : 193.w;
        final descWidth = context.isTablet ? 319.0 * 1.2 : 319.w;
        final buttonHeight = context.isTablet ? 52.0 * 1.2 : 52.h;
        final gapBetweenTitleDesc = context.isTablet ? 8.0 * 1.2 : 8.h;
        final gapBeforeButtons = context.isTablet ? 40.0 * 1.2 : 40.h;
        final gapBetweenButtons = context.isTablet ? 12.0 * 1.2 : 12.h;
        final maxWidth = context.isTablet ? 500.0 : double.infinity;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
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
                          l10n.areYouSureLogout,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            color: const Color(0xFF0F1121),
                            fontSize: context.isTablet ? 18.0.sp * 1.2 : 18.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.2999999523162842.h,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      SizedBox(height: gapBetweenTitleDesc),
                      SizedBox(
                        width: descWidth,
                        child: Text(
                          l10n.willReturnToLoginScreen,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            color: const Color(0xFF67697A),
                            fontSize: context.isTablet ? 12.0.sp * 1.2 : 12.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.6.h,
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
                              // Navigate to login screen and clear all routes
                              // (this removes the bottom sheet along with all other routes)
                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pushNamedAndRemoveUntil(
                                AppRoutes.login,
                                (route) => false,
                              );
                            } else if (state is LogoutFailure) {
                              DialogUtil().showCustomSnackbar(
                                context: context,
                                content: state.errorMessage,
                                isError: true,
                              );
                            }
                          },
                          builder: (context, state) {
                            final isLoading = state is LogoutLoading;

                            return PrimaryButton(
                              label: context.bssSubL10n.logout,
                              isLoading: isLoading,
                              loaderSize: 20,
                              borderRadius: 10,
                              backgroundColor: AppColor.kLogoutRed,
                              onClicked: () {
                                context.read<AuthBloc>().add(
                                  const LogoutRequested(),
                                );
                              },
                              textStyle: TextStyle(
                                fontFamily: 'General Sans',
                                fontSize:
                                    context.isTablet ? 14.0.sp * 1.2 : 14.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.2999999523162842.h,
                                letterSpacing: 0,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: gapBetweenButtons),
                      // White fill, thin primary outline, primary label
                      // (SecondaryButton defaults).
                      SizedBox(
                        width: double.infinity,
                        child: SecondaryButton(
                          label: l10n.cancel,
                          borderRadius: 10,
                          height: buttonHeight,
                          onClicked: () => Navigator.of(context).pop(),
                          textStyle: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: context.isTablet ? 14.0.sp * 1.2 : 14.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.2999999523162842.h,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
