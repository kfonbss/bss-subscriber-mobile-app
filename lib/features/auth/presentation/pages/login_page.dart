import 'package:kfon_subscriber/shared/widgets/common_text_button.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/constant/app_styles.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/core/validator/validators.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/remember_me.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/selected_tenant_card.dart';
import 'package:kfon_subscriber/shared/widgets/login_background.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/auth_header.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/login_text_field.dart';
import 'package:kfon_subscriber/shared/widgets/login_password_text_field.dart';
import 'package:kfon_subscriber/shared/widgets/white_button.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameTextFieldController = TextEditingController(
    text: '6008426648',
    //ld lnp '6008426648'
    //qa lnp '2951432933'
    //dev lnp '8453892290'
    //qa agnp '6368189449'
    //qa fe 'FE-Vinod',
  );
  final _passwordTextFieldController = TextEditingController(
    text: 'Pass@123',
    //ld lnp 'Pass@123',
    //qa lnp 'Pass@1234',
    //dev lnp 'Pass@123',
    //qa agnp 'Pass@123',
    //qa fe 'Pass@123',
  );
  final DialogUtil _dialogUtil = DialogUtil();
  String tenantName = '';
  String tenantId = '';
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadSelectedTenant());
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final username = await PreferenceUtils.getUsername();
    final password = await PreferenceUtils.getPassword();
    if (mounted) {
      _usernameTextFieldController.text = username ?? '';
      _passwordTextFieldController.text = password ?? '';
    }
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
      LoginRequested(
        username: username,
        password: password,
        tenantId: tenantId,
        rememberMe: rememberMe,
      ),
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
          body: Stack(
            children: [
              Positioned.fill(child: LoginBackground()),
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
                        description: '',
                        topSpacing: 74.h,
                        bottomSpacing: 24.h,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                        child: BlocBuilder<AuthBloc, AuthState>(
                          buildWhen:
                              (previous, current) =>
                                  current is LoadSelectedTenantSuccess,
                          builder: (context, state) {
                            if (state is LoadSelectedTenantSuccess) {
                              tenantName = state.tenantName;
                              tenantId = state.tenantId;
                              return SelectedTenantCard(
                                circleName: tenantName,
                                onEdit:
                                    () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.tenant,
                                    ),
                              );
                            }
                            return ShimmerBox(
                              width: double.infinity,
                              height: 60.h,
                            );
                          },
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 24.w, // Proportional scaling
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: AppStyles.boxShadowForWhite,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, // Proportional scaling
                                  vertical: 4.h, // 48 field + 8 = 56 row
                                ),
                                child: LoginTextField(
                                  hintText: context.bssSubL10n.enterUsername,
                                  textEditingController:
                                      _usernameTextFieldController,
                                  textInputType: TextInputType.number,
                                  validator:
                                      (v) => Validators.validateRequired(
                                        v,
                                        fieldName: context.bssSubL10n.username,
                                      ),
                                ),
                              ),
                              Divider(
                                color: AppColor.kFieldBorder,
                                thickness: 1,
                                height: 1.h,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 14.w, // Proportional scaling
                                  top: 4.h,
                                  bottom: 4.h,
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
                        // Checkbox row → Sign In: 48 in the login design.
                        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 48.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: RememberMe(
                                onChanged: (value) => rememberMe = value,
                              ),
                            ),
                            CommonTextButton(
                              label: context.bssSubL10n.forgotPassword,
                              onPressed:
                                  () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.forgotPassword,
                                  ),
                              textStyle: TextStyle(
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontFamily: 'General Sans',
                                height: 1.30.h,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w, // Proportional scaling
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        Sizer.isTablet
                            ? 600.0
                            : double.infinity, // Match form width
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w, // Proportional scaling

                      // LNP Enquiry bottom → screen bottom: 45 in the design.
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 11,
                      children: [
                        SecondaryButton(
                          label: context.bssSubL10n.enquiryForms,
                          borderRadius: 10,
                          backgroundColor: AppColor.kPrimaryColor,
                          borderColor: Colors.white,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: Sizer.isTablet ? 18.0 : 17.0,
                            horizontal: Sizer.isTablet ? 30.0 : 28.0,
                          ),
                          onClicked: () {},
                          textStyle: TextStyle(
                            fontSize: Sizer.isTablet ? 15.0.sp : 14.0.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'General Sans',
                            height: 1.30.h,
                          ),
                        ),
                        Container(
                          height: 30.h,
                          margin: EdgeInsets.only(
                            bottom: 50,
                            left: 100,
                            right: 100,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(23)),
                          ),
                          child: Center(
                            child: Text(
                              context.bssSubL10n.kerlaInternetWebsite,
                              style: TextStyle(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
