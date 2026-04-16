import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/security_settings_page.dart';
import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_password_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';

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

  @override
  void dispose() {
    currentPassTextEditingController.dispose();
    newPassTextEditingController.dispose();
    conformPassTextEditingController.dispose();
    super.dispose();
  }

  // Does not use `this` — static to avoid instance closure allocation.
  static String _getLabel(PasswordChangeEnum type, BssSubLocalizations l10n) {
    return switch (type) {
      PasswordChangeEnum.bss => l10n.changeBssPortalPassword,
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
    color: Colors.black,
    height: 1.30,
  );
  static final _buttonTextStyle = TextStyle(
    fontSize: 14.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static const _forgotPasswordStyle = TextStyle(
    color: AppColor.kSlateGrey,
    fontSize: 14,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w400,
    height: 1.60,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

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
            Text(
              _getLabel(widget.type, l10n),
              style: _titleStyle,
            ),
            Column(
              spacing: 16,
              children: [
                CommonPasswordTextField(
                  textEditingController: currentPassTextEditingController,
                  hintText: l10n.enterYourPassword,
                  heading: l10n.currentPassword,
                ),
                CommonPasswordTextField(
                  textEditingController: newPassTextEditingController,
                  hintText: l10n.enterNewPasswordHint,
                  heading: l10n.newPassword,
                ),
                CommonPasswordTextField(
                  textEditingController: conformPassTextEditingController,
                  hintText: l10n.confirmNewPasswordHint,
                  heading: l10n.confirmNewPassword,
                ),
              ],
            ),
            Column(
              spacing: 16,
              children: [
                PrimaryButton(
                  label: l10n.updatePassword,
                  borderRadius: 10,
                  onClicked: () => _passwordChanged(l10n),
                  isLoading: false,
                  textStyle: _buttonTextStyle,
                ),
                Center(
                  child: Text(
                    l10n.forgotPasswordLower,
                    textAlign: TextAlign.center,
                    style: _forgotPasswordStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _passwordChanged(BssSubLocalizations l10n) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Illustration_password.png',
                fit: BoxFit.cover,
                height: 140.h,
                width: 140.w,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.passwordUpdatedSuccessfullyTitle,
                textAlign: TextAlign.center,
                style: _titleStyle,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.passwordUpdatedSuccessfullyDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColor.kMediumGrey,
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                borderRadius: 10,
                isLoading: false,
                label: l10n.loginNow,
                onClicked: () => Navigator.pop(context),
                textStyle: _buttonTextStyle,
              ),
            ],
          ),
        );
      },
    );
  }
}
