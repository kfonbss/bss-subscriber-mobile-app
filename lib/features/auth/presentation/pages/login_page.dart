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
import 'package:kfon_subscriber/features/auth/presentation/components/selected_tenant_card.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/login_password_text_field.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/shimmer_box.dart';
import 'package:kfon_subscriber/shared/widgets/white_button.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameTextFieldController = TextEditingController(
    text: 'Kfon.arun-monthly',
  ); //9114676354
  final _passwordTextFieldController = TextEditingController(
    text: 'pass123',
  ); //pass1234
  final DialogUtil _dialogUtil = DialogUtil();
  String tenantName = '';
  String tenantId = '';

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadSelectedTenant());
  }
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
      LoginRequested(username: username, password: password,tenantId: tenantId),
    );
  }

  static const _websitePillDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(23)),
  );
  static const _websiteMargin = EdgeInsets.only(
    bottom: 50,
    left: 100,
    right: 100,
  );

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
              isError: true,
            );
          } else if (state is LoginSuccess) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.otpVerification,
              arguments: {
                'mobileNumber': state.user.mobile,
                'token': state.user.loginSessionToken,
              },
            );
            // _showRoleSelectionDialog(context, state.user.mobileNumber);
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
                      maxWidth:
                          Sizer.isTablet
                              ? 600.0
                              : double.infinity, // Wider form for tablet
                    ),
                    child: Column(
                      children: [
                        AuthHeader(
                          heading: context.bssSubL10n.welcomeLabel,
                          description: '',
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.w),
                          child: BlocBuilder<AuthBloc, AuthState>(
                            buildWhen: (previous, current) =>
                            current is LoadSelectedTenantSuccess,
                            builder: (context, state) {
                              if (state is LoadSelectedTenantSuccess) {
                                tenantName = state.tenantName;
                                tenantId = state.tenantId;
                                return SelectedTenantCard(
                                  circleName: tenantName,
                                  onEdit: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.tenant,
                                  ),
                                );
                              }
                              return ShimmerBox(width: double.infinity, height: 60.h);
                            },
                          ),
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
                                    validator:
                                        (v) => Validators.validateRequired(
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
                            bottom:
                                Sizer.isTablet
                                    ? 24.h
                                    : 32.0, // Smaller on tablet
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.forgotPassword,
                                    ),
                                child: Text(
                                  context.bssSubL10n.forgotPassword,
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
                                label: context.bssSubL10n.signIn,
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
                  child: Column(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: WhiteButton(
                          isLoading: false,
                          label: context.bssSubL10n.enquiryForms,
                          borderRadius: 10,
                          textColor: AppColor.kPrimaryColor,
                          onClicked:
                              () => Navigator.pushNamed(
                                context,
                                AppRoutes.enquiryListPage,
                              ),
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
