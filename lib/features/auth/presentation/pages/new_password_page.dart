import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/app_styles.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/validator/validators.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/auth_header.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/login_password_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/white_button.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  static const _systemUiStyle = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarColor: AppColor.kPrimaryColor,
  );

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newPassword = _newPasswordController.text.trim();
    final authBloc = context.read<AuthBloc>();

    authBloc.add(
      ResetPasswordRequested(
        username: authBloc.forgotPasswordUsername ?? '',
        newPassword: newPassword,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: _systemUiStyle,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSuccess) {
            DialogUtil().showCustomSnackbar(
              context: context,
              content: context.bssSubL10n.passwordUpdatedSuccessfully,
              backgroundColor: AppColor.kSuccessGreen,
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          } else if (state is PasswordResetError) {
            DialogUtil().showCustomSnackbar(
              context: context,
              content: state.errorMessage,
              backgroundColor: AppColor.kFailedRed,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColor.kPrimaryColor,
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                AuthHeader(
                  heading: context.bssSubL10n.welcomeToKfon,
                  description: '',
                  onClicked: () {},
                ),

                Form(
                  key: _formKey,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: AppStyles.boxDecorationMedium,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            top: 11,
                            bottom: 11,
                          ),
                          child: LoginPasswordTextField(
                            textEditingController: _newPasswordController,
                            hintText: context.bssSubL10n.enterNewPassword,
                            validator: Validators.validatePassword,
                          ),
                        ),
                        const Divider(
                          color: AppColor.kDividerGrey,
                          thickness: 1,
                          height: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            top: 11,
                            bottom: 11,
                          ),
                          child: LoginPasswordTextField(
                            textEditingController: _confirmPasswordController,
                            hintText: context.bssSubL10n.enterConfirmPassword,
                            validator: (value) =>
                                Validators.validateConfirmPassword(
                                  value,
                                  _newPasswordController.text,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (previous, current) =>
                        (previous is AuthLoading) != (current is AuthLoading),
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return WhiteButton(
                        isLoading: isLoading,
                        label: context.bssSubL10n.resetPassword,
                        borderRadius: 10,
                        textColor: AppColor.kPrimaryColor,
                        onClicked: _resetPassword,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
