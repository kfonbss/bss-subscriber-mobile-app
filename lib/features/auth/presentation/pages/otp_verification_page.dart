import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/auth_header.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/verification_success_sheet.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_bottom_sheet.dart';
import 'package:kfon_subscriber/presentation/ui_component/otp_input_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/white_button.dart';

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
  // ValueNotifier instead of int field — the timer updates only the countdown
  // display and resend button via ValueListenableBuilder, avoiding 30 full
  // Scaffold rebuilds per resend cycle.
  final _secondsNotifier = ValueNotifier<int>(30);
  Timer? _timer;
  int _otpWidgetKey = 0;

  // ── Static constants ─────────────────────────────────────────────────────────
  static const _systemUiStyle = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarColor: AppColor.kPrimaryColor,
  );
  static const _backgroundDecoration = BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/login_background.png'),
      fit: BoxFit.cover,
    ),
  );
  static const _timerStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static const _resendStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    decoration: TextDecoration.underline,
    decorationColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _secondsNotifier.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsNotifier.value > 0) {
        // Update ValueNotifier — only rebuilds the ValueListenableBuilder
        // subtree, not the full Scaffold.
        _secondsNotifier.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void _resendOtp() {
    final authBloc = context.read<AuthBloc>();
    if (widget.isFromForgotPassword) {
      final username = authBloc.forgotPasswordUsername;
      if (username == null) {
        DialogUtil().showCustomSnackbar(
          context: context,
          content: 'Session expired. Please restart the forgot password flow.',
          backgroundColor: AppColor.kFailedRed,
        );
        return;
      }
      authBloc.add(SendForgotPasswordOtpRequested(username: username));
    } else {
      authBloc.add(SendOtpRequested(mobileNumber: widget.mobileNumber));
    }
  }

  void _verifyOtp() {
    if (widget.isFromForgotPassword) {
      context.read<AuthBloc>().add(VerifyForgotPasswordOtpRequested(otp: _otp));
    } else {
      context.read<AuthBloc>().add(VerifyOtpRequested(otp: _otp));
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: _systemUiStyle,
      child: BlocConsumer<AuthBloc, AuthState>(
        // Only rebuild when loading status changes — OtpSent, OtpVerified, etc.
        // are handled by the listener, not the builder.
        buildWhen: (prev, curr) =>
            (curr is AuthLoading) != (prev is AuthLoading),
        listener: (context, state) {
          if (state is OtpSent) {
            setState(() {
              _otp = '';
              _otpWidgetKey++;
            });
            _secondsNotifier.value = 30;
            _startTimer();

            DialogUtil().showCustomSnackbar(
              context: context,
              content: context.bssSubL10n.otpResentSuccessfully,
              backgroundColor: AppColor.kSuccessGreen,
            );
          } else if (state is OtpVerified) {
            if (widget.isFromForgotPassword) {
              Navigator.pushReplacementNamed(context, AppRoutes.newPassword);
            } else {
              showAppModalBottomSheet(
                context: context,
                isDismissible: false,
                enableDrag: false,
                builder: (context) => const VerificationSuccessSheet(),
              );
            }
          } else if (state is OtpVerificationFailed) {
            DialogUtil().showCustomSnackbar(
              context: context,
              content: state.errorMessage,
              backgroundColor: AppColor.kFailedRed,
            );
          } else if (state is OtpSendError) {
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
              decoration: _backgroundDecoration,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AuthHeader(
                        heading: context.bssSubL10n.verifyYourAccount,
                        description: context.bssSubL10n.weHaveSentOtpTo(
                          widget.mobileNumber,
                        ),
                        onClicked: () {},
                      ),
                      OtpInputField(
                        key: ValueKey(_otpWidgetKey),
                        length: 6,
                        onCompleted: (otp) => setState(() => _otp = otp),
                        onChanged: (otp) => setState(() => _otp = otp),
                      ),

                      const SizedBox(height: 24),

                      // ValueListenableBuilder scopes timer rebuilds to this
                      // subtree only — the Scaffold above is not re-built per tick.
                      ValueListenableBuilder<int>(
                        valueListenable: _secondsNotifier,
                        builder: (_, seconds, __) => Column(
                          children: [
                            Text(
                              _formatTime(seconds),
                              textAlign: TextAlign.center,
                              style: _timerStyle,
                            ),
                            const SizedBox(height: 40),
                            if (seconds == 0)
                              Center(
                                child: TextButton(
                                  onPressed: isLoading ? null : _resendOtp,
                                  child: Text(
                                    context.bssSubL10n.resendOtp,
                                    style: _resendStyle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      WhiteButton(
                        isLoading: isLoading,
                        label: context.bssSubL10n.verifyNow,
                        borderRadius: 10,
                        textColor: AppColor.kPrimaryColor,
                        onClicked: _otp.length == 6 ? _verifyOtp : null,
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
