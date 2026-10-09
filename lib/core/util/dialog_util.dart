import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';

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
  static final _logo = Image.asset(AppAssets.logoTransparent, height: 50.0.h);

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
    final negativeButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColor.kPrimaryColor),
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onNegativeButtonClick ?? () => Navigator.pop(context),
      child: Text(context.bssSubL10n.no),
    );
    final positiveButton = ElevatedButton(
      onPressed: onPositiveButtonClick,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.5),
      ),
      child: Text(context.bssSubL10n.yes),
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

  /// Shows a common logout confirmation dialog
  void showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColor.kMainBackgroundColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
      ),
      builder: (BuildContext context) {
        final l10n = context.bssSubL10n;
        // Calculate responsive sizes for tablet
        final handleWidth = 42.w;
        final handleHeight = 6.h;
        final topPadding = 53.h;
        final horizontalPadding = 20.w;
        final bottomPadding = 30.h;
        final titleWidth = 193.w;
        final descWidth = 319.w;
        final buttonHeight = 52.h;
        final gapBetweenTitleDesc = 8.h;
        final gapBeforeButtons = 40.h;
        final gapBetweenButtons = 12.h;
        final handleTopMargin = 19.h;
        final maxWidth = double.infinity;

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
                            fontFamily: 'GeneralSans',
                            color: AppColor.kTextSecondaryDark,
                            fontSize: 18.sp,
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
                          l10n.willReturnToLoginScreen,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            color: AppColor.kTextFiledPlaceholderColor,
                            fontSize: 12.sp,
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
                                        height: 20.h,
                                        width: 20.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        context.bssSubL10n.logout,
                                        style: TextStyle(
                                          fontFamily: 'GeneralSans',
                                          fontSize: 14.sp,
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
                            foregroundColor: AppColor.kBlack80,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.w),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontSize: 14.sp,
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
                    color: AppColor.kDividerGrey,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ],
        );

        return SafeArea(top: false, child: content);
      },
    );
  }
}
