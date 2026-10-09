import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/app_brand.dart';
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
import 'package:kfon_subscriber/shared/widgets/login_background.dart';
import 'package:kfon_subscriber/shared/widgets/login_password_text_field.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/shimmer_box.dart';
import 'package:kfon_subscriber/shared/widgets/simple_webview_page.dart';
import 'package:kfon_subscriber/shared/widgets/white_button.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameTextFieldController = TextEditingController(
    text: 'ld.amal',
  ); //9114676354
  final _passwordTextFieldController = TextEditingController(
    text: 'Pass@123',
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
      LoginRequested(
        username: username,
        password: password,
        tenantId: tenantId,
      ),
    );
  }

  static const _websitePillDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(23)),
  );

  // Design: 24px side margin, 56px fields, 52px buttons.
  static final double _sideMargin = 24.w;
  static final double _fieldMinHeight = 56.h;
  static final double _buttonHeight = 52.h;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
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
                      AuthHeader(description: ''),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          _sideMargin,
                          0,
                          _sideMargin,
                          24.h,
                        ),
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
                          margin: EdgeInsets.symmetric(horizontal: _sideMargin),
                          decoration: AppStyles.boxDecorationMedium.copyWith(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: _fieldMinHeight,
                                ),
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                child: LoginTextField(
                                  hintText: context.bssSubL10n.enterUsername,
                                  textEditingController:
                                      _usernameTextFieldController,
                                  iconName: AppAssets.user,
                                  textInputType: TextInputType.name,
                                  validator:
                                      (v) => Validators.validateRequired(
                                        v,
                                        fieldName: context.bssSubL10n.username,
                                      ),
                                ),
                              ),
                              const Divider(
                                color: AppColor.kFieldBorder,
                                thickness: 1,
                                height: 1,
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: _fieldMinHeight,
                                ),
                                alignment: Alignment.center,
                                // Eye IconButton's own padding gives the
                                // 14px right inset.
                                padding: EdgeInsets.only(left: 14.w),
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
                          left: _sideMargin,
                          right: _sideMargin,
                          top: Sizer.isTablet ? 10.h : 19.h,
                          bottom: Sizer.isTablet ? 24.h : 27.h,
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
                              // No internal padding, so the gaps above and
                              // below match the design.
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                context.bssSubL10n.forgotPassword,
                                style: TextStyle(
                                  fontSize: Sizer.isTablet ? 15.0 : 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontFamily: 'GeneralSans',
                                  height: 1.30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: _sideMargin),
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return WhiteButton(
                              isLoading: state is AuthLoading,
                              label: context.bssSubL10n.signIn,
                              borderRadius: 10,
                              height: _buttonHeight,
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
                  spacing: 11.h,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: _sideMargin),
                      child: WhiteButton(
                        isLoading: false,
                        label: context.bssSubL10n.enquiryForms,
                        borderRadius: 10,
                        height: _buttonHeight,
                        backgroundColor: AppColor.kPrimaryColor,
                        borderColor: Colors.white,
                        textColor: Colors.white,
                        // TEMP: opens the web enquiry page. Restore the block
                        // below to go back to the in-app enquiry list.
                        // onClicked:
                        //     () => Navigator.pushNamed(
                        //       context,
                        //       AppRoutes.enquiryListPage,
                        //     ),
                        onClicked:
                            () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder:
                                    (_) => const SimpleWebViewPage(
                                      url:
                                          'https://rwbssqa.sritindia.com/enquiry/home',
                                    ),
                              ),
                            ),
                      ),
                    ),
                    Container(
                      height: 30.h,
                      margin: EdgeInsets.only(bottom: 44.h),
                      padding: EdgeInsets.symmetric(horizontal: 28.w),
                      decoration: _websitePillDecoration,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.bssSubL10n.kerlaInternetWebsite,
                            style: TextStyle(
                              color: AppColor.kPrimaryColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'GeneralSans',
                              height: 1.40,
                              letterSpacing: -0.12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
