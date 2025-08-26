import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/forgot_password/forgot_password_cubit.dart';
import 'package:kfon_subscriber/common/bloc/forgot_password/forgot_password_state.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/data/auth/model/forgot_password_get_OTP_params.dart';
import 'package:kfon_subscriber/data/auth/model/forgot_password_verify_OTP_params.dart';
import 'package:kfon_subscriber/data/auth/model/set_new_password_params.dart';
import 'package:kfon_subscriber/domain/auth/usecases/get_OTP.dart';
import 'package:kfon_subscriber/domain/auth/usecases/set_new_password.dart';
import 'package:kfon_subscriber/domain/auth/usecases/verify_otp.dart';
import 'package:kfon_subscriber/presentation/page_component/login_background.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';
import 'package:kfon_subscriber/presentation/ui_component/secondary_button.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/util/dialog_util.dart';
import 'package:kfon_subscriber/util/extensions.dart';

import '../../core/constant/constant_dimensions.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword>
    with TickerProviderStateMixin {
  final DialogUtil _dialogUtil = DialogUtil();
  final ForgotPasswordCubit _forgotPasswordCubit = ForgotPasswordCubit();
  final _mobileFieldController = TextEditingController();
  final _emailTextFieldController = TextEditingController();
  final _otpFieldController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _conformPasswordController = TextEditingController();
  final PageController _pageController = PageController(initialPage: 0);
  Timer? _timer;
  final ValueNotifier<Duration> _otpTimer = ValueNotifier<Duration>(
    Duration.zero,
  );

  @override
  void dispose() {
    _forgotPasswordCubit.close();
    _mobileFieldController.dispose();
    _emailTextFieldController.dispose();
    _otpFieldController.dispose();
    _newPasswordController.dispose();
    _conformPasswordController.dispose();
    _pageController.dispose();
    _stopTimer();
    super.dispose();
  }

  _getOTP() {
    String mobile = _mobileFieldController.text;
    String email = _emailTextFieldController.text;
    if (mobile.length != 10 && !email.isValidEmail) {
      _dialogUtil.showMessage("Enter valid mobile number of email", context);
      return;
    }
    _startTimer();
    _forgotPasswordCubit.sendOTP(
      useCase: sl<GetOtpUseCase>(),
      params: ForgotPasswordGetOtpParams(mobile: mobile, email: email),
    );
  }

  void _startTimer() {
    _stopTimer();
    Duration timeLeft = Duration(seconds: 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.inSeconds <= 0) {
        _stopTimer();
      } else {
        timeLeft = Duration(seconds: timeLeft.inSeconds - 1);
        _otpTimer.value = timeLeft;
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  _verifyOTP() {
    String otp = _otpFieldController.text;
    if (otp.isEmpty) {
      _dialogUtil.showMessage("Enter OTP", context);
      return;
    }
    _forgotPasswordCubit.verifyOTP(
      useCase: sl<VerifyOtpUseCase>(),
      params: ForgotPasswordVerifyOtpParams(
        mobile: _mobileFieldController.text,
        email: _emailTextFieldController.text,
        otp: otp,
      ),
    );
  }

  _resetPassword() {
    String newPassword = _newPasswordController.text;
    String confirmPassword = _conformPasswordController.text;
    if (newPassword.isEmpty || newPassword != confirmPassword) {
      _dialogUtil.showMessage("Passwords do not match", context);
      return;
    }
    _forgotPasswordCubit.setNewPassword(
      useCase: sl<SetNewPasswordUseCase>(),
      params: SetNewPasswordParams(userId: '', password: newPassword),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      bloc: _forgotPasswordCubit,
      listener: (context, state) {
        if (state is GetOTPFailureState) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is VerifyOTPFailureState) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is SetNewPasswordFailureState) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is GetOTPSuccessState) {
          _pageController.jumpToPage(1);
        } else if (state is VerifyOTPSuccessState) {
          _pageController.jumpToPage(2);
        } else if (state is SetNewPasswordSuccessState) {
          Navigator.of(context).pop();
          //  Navigator.pushReplacementNamed(context, '/home_page');
        }

      },
      listenWhen:
          (previousState, currentState) =>
              currentState is GetOTPFailureState ||
              currentState is GetOTPSuccessState ||
              currentState is VerifyOTPFailureState ||
              currentState is VerifyOTPSuccessState ||
              currentState is SetNewPasswordFailureState ||
              currentState is SetNewPasswordSuccessState,
      child: Scaffold(
        backgroundColor: AppColor.kPrimaryColor,
        resizeToAvoidBottomInset: false,
        body: LoginBackground(
          heading: 'Forgot Password',
          height: 435,
          bottomMargin: 150,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _mobileInputLayout(),
              _otpLayout(),
              _newPasswordLayout(),
            ],
          ),
        ),
      ),
    );
  }

  _mobileInputLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            CommonTextField(
              label: 'Mobile Number',
              hintText: 'Enter Mobile Number',
              textInputType: TextInputType.number,
              textEditingController: _mobileFieldController,
              maxLength: 10,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade400,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'or',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            CommonTextField(
              label: 'Email ID',
              hintText: 'Enter Email ID',
              textInputType: TextInputType.emailAddress,
              textEditingController: _emailTextFieldController,
            ),
            SizedBox(height: 30),
          ],
        ),
        Row(
          spacing: 15,
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Back',
                icon: Icon(
                  Icons.arrow_circle_left_outlined,
                  color: AppColor.kPrimaryColor,
                  size: 24,
                ),
                onClicked: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                bloc: _forgotPasswordCubit,
                buildWhen:
                    (previous, current) =>
                        current is GetOTPLoadingState ||
                        current is GetOTPFailureState ||
                        current is GetOTPSuccessState,
                builder: (context, state) {
                  return PrimaryButton(
                    isLoading: state is GetOTPLoadingState,
                    icon: Image.asset(
                      'assets/images/send_otp_button.png'
                    ),
                    label: 'Send OTP',
                    onClicked: () => _getOTP(),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  _otpLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          spacing: 10,
          children: [
            CommonTextField(
              label: 'Enter OTP',
              hintText: 'Enter OTP',
              textInputType: TextInputType.number,
              textEditingController: _otpFieldController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 5,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_timer != null && _timer!.isActive) return;
                    _getOTP();
                  },
                  child: Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: AppColor.kPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ValueListenableBuilder<Duration>(
                  valueListenable: _otpTimer,
                  builder: (
                    BuildContext context,
                    Duration duration,
                    Widget? child,
                  ) {
                    return Text(
                      duration.inSeconds > 0
                          ? 'in ${(duration.inSeconds).toString().padLeft(2, '0')}s'
                          : '',
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ), // Overrides default
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        Row(
          spacing: 15,
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Back',
                icon: Icon(
                  Icons.arrow_circle_left_outlined,
                  color: AppColor.kPrimaryColor,
                  size: AppDimensions.kButtonIconSize,
                ),
                onClicked: () => _pageController.jumpToPage(0),
              ),
            ),
            Expanded(
              child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                bloc: _forgotPasswordCubit,
                buildWhen:
                    (previous, current) =>
                        current is VerifyOTPLoadingState ||
                        current is VerifyOTPFailureState ||
                        current is VerifyOTPSuccessState,
                builder: (context, state) {
                  return PrimaryButton(
                    isLoading: state is VerifyOTPLoadingState,
                    icon: Image.asset(
                      'assets/images/verify_otp_icon.png',
                    ),
                    label: 'Verify OTP',
                    onClicked: () => _verifyOTP(),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  _newPasswordLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            CommonTextField(
              label: 'New Password',
              hintText: 'Enter New Password',
              textEditingController: _newPasswordController,
            ),
            SizedBox(height: 20),
            CommonTextField(
              label: 'Confirm Password',
              hintText: 'Re-enter New Password',
              textEditingController: _conformPasswordController,
            ),
          ],
        ),
        Row(
          spacing: 15,
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Back',
                icon: Icon(
                  Icons.arrow_circle_left_outlined,
                  color: AppColor.kPrimaryColor,
                  size: AppDimensions.kButtonIconSize,
                ),
                onClicked: () => _pageController.jumpToPage(1),
              ),
            ),
            Expanded(
              child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                bloc: _forgotPasswordCubit,
                buildWhen:
                    (previous, current) =>
                        current is SetNewPasswordLoadingState ||
                        current is SetNewPasswordFailureState ||
                        current is SetNewPasswordSuccessState,
                builder: (context, state) {
                  return PrimaryButton(
                    isLoading: state is SetNewPasswordLoadingState,
                    icon: Image.asset(
                      'assets/images/verify_otp_icon.png'
                    ),
                    label: 'Reset',
                    onClicked: () => _resetPassword(),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
