import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:kfon_subscriber/common/bloc/forgot_password/forgot_password_cubit.dart';
import 'package:kfon_subscriber/common/bloc/forgot_password/forgot_password_state.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/data/auth/model/forgot_password_get_OTP_params.dart';
import 'package:kfon_subscriber/data/auth/model/forgot_password_verify_OTP_params.dart';
import 'package:kfon_subscriber/data/auth/model/set_new_password_params.dart';
import 'package:kfon_subscriber/domain/auth/usecases/get_OTP.dart';
import 'package:kfon_subscriber/domain/auth/usecases/set_new_password.dart';
import 'package:kfon_subscriber/domain/auth/usecases/verify_otp.dart';
import 'package:kfon_subscriber/presentation/page_component/login_header.dart';
import 'package:kfon_subscriber/presentation/ui_component/login_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/password_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/white_button.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';

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
  final _newPasswordController = TextEditingController();
  final _conformPasswordController = TextEditingController();
  final PageController _pageController = PageController(initialPage: 0);
  Timer? _timer;
  final ValueNotifier<Duration> _otpTimer = ValueNotifier<Duration>(
    Duration.zero,
  );
  String _otp = '';

  @override
  void dispose() {
    _forgotPasswordCubit.close();
    _mobileFieldController.dispose();
    _newPasswordController.dispose();
    _conformPasswordController.dispose();
    _pageController.dispose();
    _stopTimer();
    super.dispose();
  }

  _getOTP() {
    String mobile = _mobileFieldController.text;
    if (mobile.isEmpty) {
      _dialogUtil.showMessage("Enter valid mobile number of email", context);
      return;
    }
    _startTimer();
    _forgotPasswordCubit.sendOTP(
      useCase: sl<GetOtpUseCase>(),
      params: ForgotPasswordGetOtpParams(mobile: mobile, email: ''),
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
    if (_otp.isEmpty) {
      _dialogUtil.showMessage("Enter OTP", context);
      return;
    }
    _forgotPasswordCubit.verifyOTP(
      useCase: sl<VerifyOtpUseCase>(),
      params: ForgotPasswordVerifyOtpParams(
        mobile: _mobileFieldController.text,
        email: '',
        otp: _otp,
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
      params: SetNewPasswordParams(userName: '', password: newPassword),
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
          //  Navigator.pushReplacementNamed(context, '/main_page');
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
        backgroundColor: Colors.red,
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/login_background.png"),
              // Path to your image
              fit: BoxFit.cover,
            ),
          ),
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
      children: [
        LoginHeader(
          heading: 'Forgot Password?',
          description:
              'Don’t worry! Enter your registered email or phone number to reset your password.',
          onClicked: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            spacing: 60,
            children: [
              LoginTextField(
                hintText: 'Enter Email / Mobile Number',
                textEditingController: _mobileFieldController,
                iconName: 'mobile.png',
                showBorder: true,
              ),
              BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                bloc: _forgotPasswordCubit,
                buildWhen:
                    (previous, current) =>
                        current is GetOTPLoadingState ||
                        current is GetOTPFailureState ||
                        current is GetOTPSuccessState,
                builder: (context, state) {
                  return WhiteButton(
                    isLoading: state is GetOTPLoadingState,
                    label: 'Get OTP',
                    borderRadius: 10,
                    textColor: AppColor.kPrimaryColor,
                    onClicked: () => _getOTP(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  _otpLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          LoginHeader(
            heading: 'Verify Your Account',
            description:
                'We have sent you 6 digits verification code to ${_mobileFieldController.text}',
            onClicked: () {},
          ),
          OtpTextField(
            numberOfFields: 6,
            borderColor: Colors.white,
            filled: true,
            fillColor: Colors.white,
            showFieldAsBox: true,
            textStyle: TextStyle(color: AppColor.kPrimaryColor),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            onCodeChanged: (String code) {},
            onSubmit: (String verificationCode) {
              _otp = verificationCode;
            },
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                    color: Colors.white,
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
                      color: Colors.white,
                    ), // Overrides default
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 60),
          BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
            bloc: _forgotPasswordCubit,
            buildWhen:
                (previous, current) =>
                    current is VerifyOTPLoadingState ||
                    current is VerifyOTPFailureState ||
                    current is VerifyOTPSuccessState,
            builder: (context, state) {
              return WhiteButton(
                isLoading: state is VerifyOTPLoadingState,
                label: 'Verify Now',
                borderRadius: 10,
                textColor: AppColor.kPrimaryColor,
                onClicked: () => _verifyOTP(),
              );
            },
          ),
        ],
      ),
    );
  }

  _newPasswordLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            LoginHeader(
              heading: 'Welcome to KFON',
              description: 'Don’t have an Account?  ',
              onClicked:
                  () => Navigator.pushReplacementNamed(context, '/sign_up'),
              clickableText: 'Sign Up',
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  PasswordTextField(
                    textEditingController: _newPasswordController,
                    hintText: 'Enter New Password',
                    showBorder: false,
                    showIcon: true,
                  ),
                  Divider(color: Colors.grey.shade200, thickness: 1.5),
                  PasswordTextField(
                    textEditingController: _conformPasswordController,
                    hintText: 'Enter Confirm Password',
                    showBorder: false,
                    showIcon: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 60),
              child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                bloc: _forgotPasswordCubit,
                buildWhen:
                    (previous, current) =>
                        current is SetNewPasswordLoadingState ||
                        current is SetNewPasswordFailureState ||
                        current is SetNewPasswordSuccessState,
                builder: (context, state) {
                  return WhiteButton(
                    isLoading: state is SetNewPasswordLoadingState,
                    label: 'Upadate',
                    borderRadius: 10,
                    textColor: AppColor.kPrimaryColor,
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
