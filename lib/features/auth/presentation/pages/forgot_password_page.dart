import 'package:kfon_subscriber/core/constant/app_styles.dart';
import 'package:kfon_subscriber/core/validator/validators.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/auth_header.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/login_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/presentation/ui_component/white_button.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController(
    text: '',
  );

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _getOtp() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String username = _usernameController.text.trim();

    context.read<AuthBloc>().add(
      SendForgotPasswordOtpRequested(username: username),
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
          if (state is OtpSent) {
            Navigator.pushNamed(
              context,
              '/otp_verification',
              arguments: {
                'mobileNumber': state.mobileNumber,
                'isFromForgotPassword': true,
              },
            );
          } else if (state is OtpSendError) {
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

            child: Stack(
              children: [
                Column(
                  children: [
                    AuthHeader(
                      heading: 'Forgot Password?',
                      description: "Don't worry! Enter your registered username to reset your password.",
                      onClicked: () {},
                    ),
                    Form(
                      key: _formKey,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: AppStyles.boxDecorationMedium,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 11,
                          ),
                          child: LoginTextField(
                            hintText: 'Enter Username',
                            textEditingController: _usernameController,
                            iconName: 'user.png',
                            textInputType: TextInputType.text,
                            validator: (v) => Validators.validateRequired(
                              v,
                              fieldName: 'Username',
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: BlocBuilder<AuthBloc, AuthState>(
                        buildWhen: (previous, current) {
                          return (previous is AuthLoading) !=
                              (current is AuthLoading);
                        },
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return WhiteButton(
                            isLoading: isLoading,
                            label: 'Get OTP',
                            borderRadius: 10,
                            textColor: AppColor.kPrimaryColor,
                            onClicked: _getOtp,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                //place backbutton same as app bar backbutton
                Positioned(top: 50, child: BackButton(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
