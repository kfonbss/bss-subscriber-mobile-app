import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class DialogUtil {
  static final _contentStyle = const TextStyle(
    color: Colors.black,
    fontSize: 15.0,
  );
  static final _positiveButtonStyle = const TextStyle(
    color: AppColor.kCompletedGreen,
  );
  static final _negativeButtonStyle = const TextStyle(
    color: AppColor.kFailedRed,
  );
  static final _logo = Image.asset(
    AppAssets.logoTransparent,
    height: 50.0.h,
  );

  showConfirmationAlert({
    required BuildContext context,
    required String content,
    required VoidCallback onPositiveButtonClick,
    required VoidCallback onNegativeButtonClick,
  }) {
    final negativeButton = TextButton(
      onPressed: onNegativeButtonClick,
      child: Text(context.bssSubL10n.no, style: _negativeButtonStyle),
    );
    final positiveButton = TextButton(
      onPressed: onPositiveButtonClick,
      child: Text(context.bssSubL10n.yes, style: _positiveButtonStyle),
    );

    // set up the AlertDialog
    final alert = AlertDialog(
      //title: Text(kAppName,style: _titleStyle),
      icon: _logo,
      content: Text(content, style: _contentStyle),
      actions: [negativeButton, positiveButton],
      elevation: 5.0,
      backgroundColor: Colors.white,
    );

    // show the dialog
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(canPop: false, child: alert);
      },
    );
  }

  showOKWithAction({
    required BuildContext context,
    required String content,
    required VoidCallback onConfirmation,
  }) {
    final positiveButton = TextButton(
      onPressed: onConfirmation,
      child: Text(context.bssSubL10n.ok, style: _positiveButtonStyle),
    );

    // set up the AlertDialog
    final alert = AlertDialog(
      icon: _logo,
      content: Text(content, style: _contentStyle),
      actions: [positiveButton],
      elevation: 5.0,
      backgroundColor: Colors.white,
    );

    // show the dialog
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(canPop: false, child: alert);
      },
    );
  }

  /// Convenience wrapper — delegates to [showCustomSnackbar].
  void showMessage(
    String content,
    BuildContext context, {
    Color? backgroundColor,
  }) {
    showCustomSnackbar(
      context: context,
      content: content,
      backgroundColor: backgroundColor ?? AppColor.kFailedRed,
    );
  }

  void showCustomSnackbar({
    required BuildContext context,
    required String content,
    Color? backgroundColor,
    bool isError = false,
  }) {
    final theme = Theme.of(context);
    final Color accentColor =
        backgroundColor ??
        (isError ? AppColor.kFailedRed : AppColor.kSecondaryColor);
    final Color themedBorderColor = (isError
            ? AppColor.kFailedRed
            : AppColor.kSecondaryColor)
        .withValues(alpha: 0.45);
    final Color themedShadowColor = (isError
            ? AppColor.kFailedRed
            : AppColor.kSecondaryColor)
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
              color: AppColor.kWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themedBorderColor, width: 1.2),
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColor.kDialogTitleDark,
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
          duration: const Duration(seconds: 3),
        ),
      );
  }

  showConfirmationSheet({
    required BuildContext context,
    required String content,
    String? title,
    required VoidCallback onPositiveButtonClick,
    VoidCallback? onNegativeButtonClick,
  }) {
    final l10n = context.bssSubL10n;
    Widget negativeButton = SecondaryButton(
      borderRadius: 8,
      label: l10n.no,
      onClicked: onNegativeButtonClick ?? () => Navigator.pop(context),
      padding: EdgeInsets.symmetric(vertical: 14),
    );
    Widget positiveButton = PrimaryButton(
      label: l10n.yes,
      onClicked: onPositiveButtonClick,
      padding: EdgeInsets.symmetric(vertical: 14.5),
      borderRadius: 8,
      isLoading: false,
    );

    final contentWidget = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
          ],
          SizedBox(height: 8.h),
          Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: negativeButton),
                SizedBox(width: 24.w),
                Expanded(child: positiveButton),
              ],
            ),
          ),
        ],
      ),
    );

    // show the dialog
    return showAppModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) {
        return PopScope(canPop: false, child: contentWidget);
      },
    );
  }

  void showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: context.isTablet
          ? Colors.transparent
          : AppColor.kMainBackgroundColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: context.isTablet
            ? BorderRadius.circular(24.w)
            : const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        final l10n = context.bssSubL10n;
        // Calculate responsive sizes for tablet
        final handleWidth = context.isTablet ? 42.0 * 1.2 : 42.w;
        final handleHeight = context.isTablet ? 6.0 * 1.2 : 6.h;
        final topPadding = context.isTablet ? 53.0 * 1.2 : 53.h;
        final horizontalPadding = context.isTablet ? 20.0 * 1.2 : 20.w;
        // Design: 56 below Cancel incl. the 34 home indicator (SafeArea).
        final bottomPadding = context.isTablet ? 30.0 * 1.2 : 22.h;
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
                                fontSize: context.isTablet
                                    ? 14.0.sp * 1.2
                                    : 14.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.2999999523162842.h,
                                letterSpacing: 0,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: gapBetweenButtons),
                      // White fill, no outline, dark label — as it was.
                      SecondaryButton(
                        label: l10n.cancel,
                        borderRadius: 10,
                        height: buttonHeight,
                        borderColor: Colors.transparent,
                        foregroundColor: const Color.fromRGBO(0, 0, 0, 0.8),
                        onClicked: () => Navigator.of(context).pop(),
                        textStyle: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: context.isTablet ? 14.0.sp * 1.2 : 14.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.2999999523162842.h,
                          letterSpacing: 0,
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
