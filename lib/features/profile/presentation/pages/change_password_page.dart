import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/app_brand.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/core/validator/validators.dart';
import 'package:kfon_subscriber/features/profile/domain/params/change_password_params.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/features/profile/presentation/bloc/change_password_cubit.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/security_settings_page.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';
import 'package:kfon_subscriber/shared/widgets/common_password_text_field.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';

class ChangePasswordPage extends StatefulWidget {
  final PasswordChangeEnum type;

  const ChangePasswordPage({super.key, required this.type});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController currentPassTextEditingController =
      TextEditingController();
  final TextEditingController newPassTextEditingController =
      TextEditingController();
  final TextEditingController conformPassTextEditingController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ChangePasswordCubit _cubit = ChangePasswordCubit(
    repository: sl<ProfileRepository>(),
  );

  /// Only the BSS portal password has an API so far; the other types keep
  /// their previous (UI-only) behaviour.
  bool get _isPortal => widget.type == PasswordChangeEnum.bss;

  @override
  void dispose() {
    currentPassTextEditingController.dispose();
    newPassTextEditingController.dispose();
    conformPassTextEditingController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onUpdatePressed(BssSubLocalizations l10n) {
    if (!_isPortal) {
      _passwordChanged(l10n);
      return;
    }
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _cubit.changePortalPassword(
      ChangePasswordParams(
        oldPassword: currentPassTextEditingController.text,
        newPassword: newPassTextEditingController.text,
        confirmPassword: conformPassTextEditingController.text,
      ),
    );
  }

  // Does not use `this` — static to avoid instance closure allocation.
  static String _getLabel(PasswordChangeEnum type, BssSubLocalizations l10n) {
    return switch (type) {
      PasswordChangeEnum.bss => l10n.changeAppPortalPassword(AppBrand.appName),
      PasswordChangeEnum.internet => l10n.changeInternetPassword,
      PasswordChangeEnum.ssid => l10n.changeSsidPassword,
      PasswordChangeEnum.wifi => l10n.changeWifiPassword,
    };
  }

  // Sizer-based styles — computed once as static final.
  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    fontSize: 18.sp,
    color: AppColor.kTextSecondaryDark,
    height: 1.30,
  );
  static final _buttonTextStyle = TextStyle(
    fontSize: 14.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return BlocListener<ChangePasswordCubit, ChangePasswordState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          _formKey.currentState?.reset();
          currentPassTextEditingController.clear();
          newPassTextEditingController.clear();
          conformPassTextEditingController.clear();
          _passwordChanged(l10n);
        } else if (state is ChangePasswordFailure) {
          DialogUtil().showCustomSnackbar(
            context: context,
            content: state.message,
            isError: true,
          );
        }
      },
      child: _buildPage(l10n),
    );
  }

  Widget _buildPage(BssSubLocalizations l10n) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: l10n.securitySettings,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 40,
          children: [
            Text(_getLabel(widget.type, l10n), style: _titleStyle),
            Form(
              key: _formKey,
              child: Column(
                spacing: 16,
                // Labels, fields and the button share the same left/right
                // edges (was centred, so fields sat inset from the labels).
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CommonPasswordTextField(
                    textEditingController: currentPassTextEditingController,
                    hintText: l10n.enterYourPassword,
                    heading: l10n.currentPassword,
                    validator:
                        (v) => Validators.validateRequired(
                          v,
                          fieldName: l10n.currentPassword,
                          l10n: l10n,
                        ),
                  ),
                  CommonPasswordTextField(
                    textEditingController: newPassTextEditingController,
                    hintText: l10n.enterNewPasswordHint,
                    heading: l10n.newPassword,
                    validator:
                        (v) => Validators.validateNewPassword(v, l10n: l10n),
                  ),
                  CommonPasswordTextField(
                    textEditingController: conformPassTextEditingController,
                    hintText: l10n.confirmNewPasswordHint,
                    heading: l10n.confirmNewPassword,
                    validator:
                        (v) => Validators.validateConfirmPassword(
                          v,
                          newPassTextEditingController.text,
                          l10n: l10n,
                        ),
                  ),
                ],
              ),
            ),
            Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                  bloc: _cubit,
                  builder: (context, state) {
                    return PrimaryButton(
                      label: l10n.updatePassword,
                      borderRadius: 10,
                      height: 52.h,
                      // TODO(BE): Internet password has no API yet, so its
                      // Update button stays disabled until it's integrated.
                      onClicked:
                          widget.type == PasswordChangeEnum.internet
                              ? null
                              : () => _onUpdatePressed(l10n),
                      isLoading: state is ChangePasswordLoading,
                      textStyle: _buttonTextStyle,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Clears the whole stack and opens the login screen.
  static void _goToLogin(BuildContext context) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  /// Portal password changed → the saved session/credentials are stale, so
  /// "Login Now" logs out (same as the Logout button) and opens login.
  Widget _loginNowButton(BssSubLocalizations l10n) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is LogoutSuccess) {
          _goToLogin(context);
        } else if (state is LogoutFailure) {
          // The server may already have revoked the old session after the
          // password change; still sign out locally (incl. remembered
          // credentials, which now hold the old password).
          await PreferenceUtils.clearAll(true);
          if (context.mounted) _goToLogin(context);
        }
      },
      builder: (context, state) {
        return PrimaryButton(
          width: double.infinity,
          borderRadius: 10,
          height: 52.h,
          isLoading: state is LogoutLoading,
          label: l10n.loginNow,
          onClicked:
              () => context.read<AuthBloc>().add(const LogoutRequested()),
          textStyle: _buttonTextStyle,
        );
      },
    );
  }

  Future<void> _passwordChanged(BssSubLocalizations l10n) async {
    showAppModalBottomSheet<void>(
      context: context,
      topRadius: 20,
      // Portal: the user must go through "Login Now" — no swipe/tap-outside.
      isDismissible: !_isPortal,
      enableDrag: !_isPortal,
      builder: (BuildContext context) {
        // Design: 438-tall sheet — image 56 from top, button 20 from the
        // sides, text 28 from the sides, 50 below the button.
        return PopScope(
          canPop: !_isPortal,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 50.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAssets.illustrationPassword,
                  fit: BoxFit.cover,
                  height: 140.w,
                  width: 140.w,
                ),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Column(
                    children: [
                      Text(
                        l10n.passwordUpdatedSuccessfullyTitle,
                        textAlign: TextAlign.center,
                        style: _titleStyle,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        l10n.passwordUpdatedSuccessfullyDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.60,
                          color: AppColor.kTextFiledPlaceholderColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                if (_isPortal)
                  _loginNowButton(l10n)
                else
                  PrimaryButton(
                    // Full width of the sheet (minus its 20 side padding).
                    width: double.infinity,
                    borderRadius: 10,
                    height: 52.h,
                    isLoading: false,
                    label: l10n.loginNow,
                    onClicked: () => Navigator.pop(context),
                    textStyle: _buttonTextStyle,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
