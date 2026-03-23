import 'package:kfon_subscriber/core/constant/app_styles.dart';
import 'package:kfon_subscriber/core/validator/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/auth_header.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/login_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/login_password_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/white_button.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  // lnp
  final _usernameTextFieldController = TextEditingController(
    text: 'Kfon.aji007',
  );
  final _passwordTextFieldController = TextEditingController(text: 'pass123');
  final DialogUtil _dialogUtil = DialogUtil();

  @override
  void dispose() {
    _usernameTextFieldController.dispose();
    _passwordTextFieldController.dispose();
    super.dispose();
  }

  void _doLogin() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String username = _usernameTextFieldController.text.trim();
    String password = _passwordTextFieldController.text.trim();

    context.read<AuthBloc>().add(
      LoginRequested(username: username, password: password),
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
          if (state is LoginFailure) {
            _dialogUtil.showCustomSnackbar(
              context: context,
              content: state.errorMessage,
              backgroundColor: AppColor.kFailedRed,
            );
          } else if (state is LoginSuccess) {
            Navigator.pushReplacementNamed(
              context,
              '/otp_verification',
              arguments: {'mobileNumber': state.user.mobileNumber},
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
                // Center content on tablets, full width on mobile
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Sizer.isTablet
                          ? 600.0
                          : double.infinity, // Wider form for tablet
                    ),
                    child: Column(
                      children: [
                        AuthHeader(
                          heading: 'Welcome to KFON',
                          description: '',
                          onClicked: () {},
                        ),

                        Form(
                          key: _formKey,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 20.w, // Proportional scaling
                            ),
                            decoration: AppStyles.boxDecorationMedium,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, // Proportional scaling
                                    vertical: 11.h, // Proportional scaling
                                  ),
                                  child: LoginTextField(
                                    hintText: 'Enter Username',
                                    textEditingController:
                                        _usernameTextFieldController,
                                    iconName: 'user.png',
                                    textInputType: TextInputType.name,
                                    validator: (v) =>
                                        Validators.validateRequired(
                                          v,
                                          fieldName: 'Username',
                                        ),
                                  ),
                                ),
                                Divider(
                                  color: Colors.grey.shade200,
                                  thickness: 1,
                                  height: 2,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 16.w, // Proportional scaling
                                    top: 11.h, // Proportional scaling
                                    bottom: 11.h, // Proportional scaling
                                  ),
                                  child: LoginPasswordTextField(
                                    textEditingController:
                                        _passwordTextFieldController,
                                    hintText: 'Enter Password',
                                    validator: Validators.validatePassword,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                            left: Sizer.isTablet ? 24.w : 7.0,
                            right: Sizer.isTablet ? 24.w : 10.0,
                            top: 10.h, // Proportional scaling
                            bottom: Sizer.isTablet
                                ? 24.h
                                : 32.0, // Smaller on tablet
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/forgot_password',
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: Sizer.isTablet ? 15.0 : 14.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontFamily: 'GeneralSans',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w, // Proportional scaling
                          ),
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return WhiteButton(
                                isLoading: state is AuthLoading,
                                label: 'Sign In',
                                borderRadius: 10,
                                textColor: AppColor.kPrimaryColor,
                                onClicked: () => _doLogin(),
                                //Navigator.pushNamed(context, AppRoutes.mainPage),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(

                    height: 30.h,
                    margin: EdgeInsets.only(bottom: 50,left: 100,right: 100),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: const Center(
                      child: Text(
                        'www.kerlainternet.com',
                        style: TextStyle(
                          color: AppColor.kPrimaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
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
