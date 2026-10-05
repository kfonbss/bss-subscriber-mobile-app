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
import 'package:kfon_subscriber/shared/widgets/login_background.dart';
import 'package:kfon_subscriber/shared/widgets/login_password_text_field.dart';
import 'package:kfon_subscriber/shared/widgets/white_button.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

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

    String newPassword = _newPasswordController.text.trim();

    context.read<AuthBloc>().add(
      ResetPasswordRequested(username: '_username', newPassword: newPassword),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarColor: AppColor.kPrimaryColor,
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSuccess) {
            DialogUtil().showCustomSnackbar(
              context: context,
              content: context.bssSubL10n.passwordUpdatedSuccessfully,
            );

            Future.delayed(const Duration(seconds: 1), () {
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            });
          } else if (state is PasswordResetError) {
            DialogUtil().showCustomSnackbar(
              context: context,
              content: state.errorMessage,
              isError: true,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColor.kPrimaryColor,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              LoginBackground(),
              Column(
                children: [
                  AuthHeader(
                    description: '',
                  ),
                  Form(
                    key: _formKey,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      decoration: AppStyles.boxDecorationMedium.copyWith(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            constraints: BoxConstraints(minHeight: 56.h),
                            alignment: Alignment.center,
                            // Eye IconButton's own padding gives the 14px
                            // right inset.
                            padding: EdgeInsets.only(left: 14.w),
                            child: LoginPasswordTextField(
                              textEditingController: _newPasswordController,
                              hintText: context.bssSubL10n.enterNewPassword,
                              validator: Validators.validatePassword,
                            ),
                          ),
                          const Divider(
                            color: AppColor.kFieldBorder,
                            thickness: 1,
                            height: 1,
                          ),
                          Container(
                            constraints: BoxConstraints(minHeight: 56.h),
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 14.w),
                            child: LoginPasswordTextField(
                              textEditingController: _confirmPasswordController,
                              hintText: context.bssSubL10n.enterConfirmPassword,
                              validator:
                                  (value) => Validators.validateConfirmPassword(
                                    value,
                                    _newPasswordController.text,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      buildWhen:
                          (previous, current) =>
                              (previous is AuthLoading) !=
                              (current is AuthLoading),
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return WhiteButton(
                          isLoading: isLoading,
                          label: context.bssSubL10n.resetPassword,
                          borderRadius: 10,
                          height: 52.h,
                          textColor: AppColor.kPrimaryColor,
                          onClicked: _resetPassword,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
