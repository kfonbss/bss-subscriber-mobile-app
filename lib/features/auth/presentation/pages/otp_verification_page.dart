import 'dart:async';

import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/auth_header.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/verification_success_sheet.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_bottom_sheet.dart';
import 'package:kfon_subscriber/presentation/ui_component/otp_input_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/white_button.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class OtpVerificationPage extends StatefulWidget {
  final String mobileNumber;
  final bool isFromForgotPassword;

  const OtpVerificationPage({
    super.key,
    required this.mobileNumber,
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
        SendForgotPasswordOtpRequested(
          username: authBloc.forgotPasswordUsername!,
        ),
      );
    } else {
      authBloc.add(SendOtpRequested(mobileNumber: widget.mobileNumber));
    }

    setState(() {
      _otp = '';
      _remainingSeconds = 30;
      _otpWidgetKey++;
    });

    _startTimer();

    DialogUtil().showCustomSnackbar(
      context: context,
      content: 'OTP resent successfully',
      backgroundColor: Colors.green,
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
            if (widget.isFromForgotPassword) {
              // Navigate to new password page for forgot password flow
              Navigator.pushReplacementNamed(context, '/new_password');
            } else {
              // Show success bottom sheet for registration/login flow
              showAppModalBottomSheet(
                context: context,
                builder: (context) => const VerificationSuccessSheet(),
              );
            }
          } else if (state is OtpVerificationFailed) {
            DialogUtil().showCustomSnackbar(
              context: context,
              content: state.errorMessage,
              backgroundColor: AppColor.kFailedRed,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: AppColor.kPrimaryColor,
            resizeToAvoidBottomInset: false,
            body: Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/login_background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AuthHeader(
                        heading: 'Verify Your Account',
                        description:'We have sent you 6 digits verification code to ${widget.mobileNumber}',
                        onClicked: () {},
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

                      const SizedBox(height: 24),

                      Text(
                        _formatTime(_remainingSeconds),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 40),

                      WhiteButton(
                        isLoading: isLoading,
                        label: 'Verify Now',
                        borderRadius: 10,
                        textColor: AppColor.kPrimaryColor,
                        onClicked: _otp.length == 6 ? _verifyOtp : null,
                      ),

                      const SizedBox(height: 24),

                      if (_remainingSeconds == 0)
                        Center(
                          child: TextButton(
                            onPressed: _resendOtp,
                            child: Text(
                              'Resend OTP',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
