import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:kfon_subscriber/common/bloc/sign_up/sign_up_cubit.dart';
import 'package:kfon_subscriber/common/bloc/sign_up/sign_up_state.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/data/sign_up/models/sign_up_get_OTP_params.dart';
import 'package:kfon_subscriber/data/sign_up/models/sign_up_verify_OTP_params.dart';
import 'package:kfon_subscriber/domain/sign_up/usecases/sign_up_get_OTP.dart';
import 'package:kfon_subscriber/domain/sign_up/usecases/sign_up_verify_OTP.dart';
import 'package:kfon_subscriber/presentation/page_component/login_header.dart';
import 'package:kfon_subscriber/presentation/ui_component/login_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/password_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_color_button.dart';
import 'package:kfon_subscriber/presentation/ui_component/white_button.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final DialogUtil _dialogUtil = DialogUtil();
  final SignUpCubit _signUpCubit = SignUpCubit();
  final _mobileFieldController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final PageController _pageController = PageController(initialPage: 0);
  Timer? _timer;
  final ValueNotifier<Duration> _otpTimer = ValueNotifier<Duration>(
    Duration.zero,
  );
  String _otp = '';

  @override
  void dispose() {
    _signUpCubit.close();
    _mobileFieldController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _pageController.dispose();
    _stopTimer();
    super.dispose();
  }

  _getOTP() {
    String mobile = _mobileFieldController.text;
    String name = _nameController.text;
    String password = _passwordController.text;
    if (name.isEmpty) {
      _dialogUtil.showMessage("Enter your name", context);
    } else if (mobile.length != 10) {
      _dialogUtil.showMessage("Enter valid mobile number", context);
    } else if (password.isEmpty) {
      _dialogUtil.showMessage("Enter your password", context);
    } else {
      _startTimer();
      _signUpCubit.getOTP(
        useCase: sl<SignUpGetOtpUseCase>(),
        params: SignUpGetOtpParams(
          mobile: mobile,
          name: name,
          password: password,
        ),
      );
    }
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
    _signUpCubit.verifyOTP(
      useCase: sl<SignUpVerifyOtpUseCase>(),
      params: SignUpVerifyOtpParams(
        mobile: _mobileFieldController.text,
        otp: _otp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
      bloc: _signUpCubit,
      listener: (context, state) {
        if (state is GetOTPFailureState) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is VerifyOTPFailureState) {
          _dialogUtil.showMessage(state.errorMessage, context);
        }  else if (state is GetOTPSuccessState) {
          _pageController.jumpToPage(1);
        } else if (state is VerifyOTPSuccessState) {
          _signUpCompleted();
        }
      },
      listenWhen:
          (previousState, currentState) =>
              currentState is GetOTPFailureState ||
              currentState is GetOTPSuccessState ||
              currentState is VerifyOTPFailureState ||
              currentState is VerifyOTPSuccessState ,
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
            // physics: const NeverScrollableScrollPhysics(),
            children: [_mobileInputLayout(), _otpLayout()],
          ),
        ),
      ),
    );
  }

  _mobileInputLayout() {
    return Column(
      children: [
        LoginHeader(
          heading: 'Create account',
          description: 'Already have an account?  ',
          clickableText: 'Log In',
          onClicked:
              () => Navigator.pushReplacementNamed(context, '/login_page'),
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
              LoginTextField(
                hintText: 'Enter your name',
                textEditingController: _nameController,
                iconName: 'user.png',
                textInputType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                showBorder: false,
              ),
              Divider(color: Colors.grey.shade200, thickness: 1.5),
              LoginTextField(
                hintText: 'Enter your phone number',
                textEditingController: _mobileFieldController,
                textInputType: TextInputType.number,
                iconName: 'mobile.png',
                showBorder: false,
              ),
              Divider(color: Colors.grey.shade200, thickness: 1.5),
              PasswordTextField(
                textEditingController: _passwordController,
                hintText: 'Enter your password',
                showBorder: false,
                showIcon: true,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 60),
          child: BlocBuilder<SignUpCubit, SignUpState>(
            bloc: _signUpCubit,
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
          BlocBuilder<SignUpCubit, SignUpState>(
            bloc: _signUpCubit,
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

  Future<void> _signUpCompleted() async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 100,
                right: 100,
                top: 50,
                bottom: 24,
              ),
              child: Image.asset(
                'assets/images/Illustration.png',
                fit: BoxFit.cover,
              ),
            ),
            Text(
              'Account Verified! 🎉',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 28,
                right: 28,
                top: 4,
                bottom: 32,
              ),
              child: Text(
                'Congratulations! your account has been verified from our system.  Please login first before enjoy our amazing experience. We hope you enjoy it!"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PrimaryColorButton(
                borderRadius: 10,
                isLoading: false,
                label: 'Login Now',
                onClicked: () =>Navigator.pushReplacementNamed(context, '/login_page'),
              ),
            ),
          ],
        );
      },
    );
  }
}
