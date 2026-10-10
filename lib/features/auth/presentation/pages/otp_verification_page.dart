import 'package:kfon_subscriber/shared/widgets/common_text_button.dart';
import 'dart:async';

import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/auth_header.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/verification_success_sheet.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/shared/widgets/login_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/shared/widgets/otp_input_field.dart';
import 'package:kfon_subscriber/shared/widgets/white_button.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class OtpVerificationPage extends StatefulWidget {
  final String mobileNumber;
  final String token;
  final bool isFromForgotPassword;

  const OtpVerificationPage({
    super.key,
    required this.mobileNumber,
    required this.token,
    this.isFromForgotPassword = false,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  String _otp = '';
  int _remainingSeconds = 30;
  Timer? _timer;
  int _otpWidgetKey = 0;
  final DialogUtil _dialogUtil = DialogUtil();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resendOtp() {
    final authBloc = context.read<AuthBloc>();
    if (widget.isFromForgotPassword) {
      authBloc.add(
        ResendForgotPasswordOtpRequested(
          username: authBloc.forgotPasswordUsername!,
        ),
      );
    } else {
      authBloc.add(ResendOTP(loginSessionToken: widget.token));
    }

    setState(() {
      _otp = '';
      _remainingSeconds = 30;
      _otpWidgetKey++;
    });

    _startTimer();

    _dialogUtil.showCustomSnackbar(
      context: context,
      content: context.bssSubL10n.otpResentSuccessfully,
    );
  }

  void _verifyOtp() {
    if (widget.isFromForgotPassword) {
      context.read<AuthBloc>().add(VerifyForgotPasswordOtpRequested(otp: _otp));
    } else {
      context.read<AuthBloc>().add(VerifyOtpRequested(otp: _otp));
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarColor: AppColor.kPrimaryColor,
      ),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpVerified) {
            // Show success bottom sheet for registration/login flow
            showAppModalBottomSheet(
              context: context,
              isDismissible: false,
              enableDrag: false,
              // Account Verified design: white sheet, 42×6 handle 8 from top.
              // 8 + 6 + 22 = 36, same handle area as the default.
              backgroundColor: Colors.white,
              dragHandleColor: AppColor.kDividerGrey,
              dragHandleSize: Size(42.w, 6.h),
              dragHandlePadding: EdgeInsets.only(top: 8.h, bottom: 22.h),
              builder: (context) => VerificationSuccessSheet(),
            );
          } else if (state is ForgotPasswordOtpVerified) {
            Navigator.pushReplacementNamed(context, AppRoutes.newPassword);
          } else if (state is OtpVerificationFailed) {
            _dialogUtil.showCustomSnackbar(
              context: context,
              content: state.errorMessage,
              isError: true,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: AppColor.kPrimaryColor,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                LoginBackground(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AuthHeader(
                        topSpacing: 104.5.h,
                        heading: context.bssSubL10n.verifyYourAccount,
                        description: context.bssSubL10n.otpSentMessage(
                          widget.mobileNumber,
                        ),
                        descriptionHighlight: widget.mobileNumber,
                        // Page already pads 24 each side; the first line
                        // needs the full 327 width to stay on one line.
                        descriptionPadding: EdgeInsets.only(
                          top: 12.h,
                          bottom: 32.h,
                        ),
                      ),

                      OtpInputField(
                        key: ValueKey(_otpWidgetKey),
                        length: 6,
                        onCompleted: (otp) {
                          setState(() {
                            _otp = otp;
                          });
                        },
                        onChanged: (otp) {
                          setState(() {
                            _otp = otp;
                          });
                        },
                      ),

                      SizedBox(height: 24.h),

                      Text(
                        _formatTime(_remainingSeconds),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: 'General Sans',
                          height: 1.65.h,
                          letterSpacing: -0.14,
                        ),
                      ),

                      SizedBox(height: 54.h),

                      WhiteButton(
                        isLoading: isLoading,
                        label: context.bssSubL10n.verifyNow,
                        borderRadius: 10,
                        textColor: AppColor.kPrimaryColor,
                        onClicked: _otp.length == 6 ? _verifyOtp : null,
                      ),

                      SizedBox(height: 20.h),

                      if (_remainingSeconds == 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${context.bssSubL10n.didntReceiveCode} ',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontFamily: 'General Sans',
                                height: 1.65.h,
                                letterSpacing: -0.14,
                              ),
                            ),
                            CommonTextButton(
                              label: context.bssSubL10n.resendOtp,
                              onPressed: _resendOtp,
                              textStyle: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'General Sans',
                                height: 1.65.h,
                                letterSpacing: -0.14,
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
