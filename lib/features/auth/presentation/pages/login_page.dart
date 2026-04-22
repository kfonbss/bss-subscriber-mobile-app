import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/app_styles.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/core/validator/validators.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/auth_header.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/login_text_field.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/login_password_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/white_button.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();
  final DialogUtil _dialogUtil = DialogUtil();

  // ── Static decorations ───────────────────────────────────────────────────────
  static const _backgroundDecoration = BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/login_background.png'),
      fit: BoxFit.cover,
    ),
  );
  static const _websitePillDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(23)),
  );
  static const _websiteMargin = EdgeInsets.only(bottom: 50, left: 100, right: 100);

  // Sizer.isTablet is a static bool fixed after MaterialApp.builder — compute once.
  static final _forgotPasswordStyle = TextStyle(
    fontSize: Sizer.isTablet ? 15.0 : 14.0,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    fontFamily: 'GeneralSans',
  );

  // SystemUiOverlayStyle is const-constructible and AppColor values are const.
  static const _systemUiStyle = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarColor: AppColor.kPrimaryColor,
  );

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

    final username = _usernameTextFieldController.text.trim();
    final password = _passwordTextFieldController.text;

    context.read<AuthBloc>().add(
      LoginRequested(username: username, password: password),
    );
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: _systemUiStyle,
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
              AppRoutes.otpVerification,
              arguments: {'mobileNumber': state.user.mobileNumber},
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColor.kPrimaryColor,
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: _backgroundDecoration,
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
                          heading: context.bssSubL10n.welcomeToKfon,
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
                                    hintText: context.bssSubL10n.enterUsername,
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
                                  color: AppColor.kDividerGrey,
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
                                    hintText: context.bssSubL10n.enterPassword,
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
                                  AppRoutes.forgotPassword,
                                ),
                                child: Text(
                                  context.bssSubL10n.forgotPassword,
                                  style: _forgotPasswordStyle,
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
                            // Only rebuild when loading status changes — LoginFailure,
                            // LoginSuccess, etc. don't affect the button appearance.
                            buildWhen: (prev, curr) =>
                                (curr is AuthLoading) != (prev is AuthLoading),
                            builder: (context, state) {
                              return WhiteButton(
                                isLoading: state is AuthLoading,
                                label: context.bssSubL10n.signIn,
                                borderRadius: 10,
                                textColor: AppColor.kPrimaryColor,
                                onClicked: _doLogin,
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
                  child: Column(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal:20.w, ),
                        child: WhiteButton(
                          isLoading: false,
                          label: context.bssSubL10n.enquiryForms,
                          borderRadius: 10,
                          textColor: AppColor.kPrimaryColor,
                          onClicked: () => Navigator.pushNamed(context, AppRoutes.enquiryListPage),
                        ),
                      ),
                      Container(
                        height: 30.h,
                        margin: _websiteMargin,
                        decoration: _websitePillDecoration,
                        child: Center(
                          child: Text(
                            context.bssSubL10n.kerlaInternetWebsite,
                            style: const TextStyle(
                              color: AppColor.kPrimaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
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
