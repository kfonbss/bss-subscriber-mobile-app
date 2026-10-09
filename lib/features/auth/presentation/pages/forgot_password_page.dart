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
import 'package:kfon_subscriber/features/auth/presentation/components/login_text_field.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/login_background.dart';
import 'package:kfon_subscriber/shared/widgets/white_button.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

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
              AppRoutes.otpVerification,
              arguments: {
                'mobileNumber': state.mobileNumber,
                'isFromForgotPassword': true,
              },
            );
          } else if (state is OtpSendError) {
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
                    heading: context.bssSubL10n.forgotPassword,
                    description:
                        context.bssSubL10n.forgotPasswordDescription,
                    topSpacing: Sizer.isTablet ? null : 104.5.h,
                  ),
                  Form(
                    key: _formKey,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      decoration: AppStyles.boxDecorationMedium.copyWith(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        constraints: BoxConstraints(minHeight: 56.h),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: LoginTextField(
                          hintText: context.bssSubL10n.enterUsername,
                          textEditingController: _usernameController,
                          iconName: AppAssets.user,
                          textInputType: TextInputType.text,
                          validator:
                              (v) => Validators.validateRequired(
                                v,
                                fieldName: context.bssSubL10n.username,
                                l10n: context.bssSubL10n,
                              ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 60.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) {
                        return (previous is AuthLoading) !=
                            (current is AuthLoading);
                      },
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return WhiteButton(
                          isLoading: isLoading,
                          label: context.bssSubL10n.getOtp,
                          borderRadius: 10,
                          height: 52.h,
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
    );
  }
}
