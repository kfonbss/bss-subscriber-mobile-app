import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/login/login_state.dart';
import 'package:kfon_subscriber/common/bloc/login/login_state_cubit.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/data/auth/model/login_req_params.dart';
import 'package:kfon_subscriber/domain/auth/usecases/login.dart';
import 'package:kfon_subscriber/presentation/page_component/login_header.dart';
import 'package:kfon_subscriber/presentation/ui_component/login_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/password_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/white_button.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _mobileNoTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();
  final LoginStateCubit _loginStateCubit = LoginStateCubit();
  final DialogUtil _dialogUtil = DialogUtil();

  @override
  void dispose() {
    _mobileNoTextFieldController.dispose();
    _passwordTextFieldController.dispose();
    _loginStateCubit.close();
    super.dispose();
  }

  _doLogin() {
    String mobileNo = _mobileNoTextFieldController.text.trim();
    String password = _passwordTextFieldController.text.trim();
    if (mobileNo.length != 10) {
      _dialogUtil.showMessage('Please enter valid mobile number', context);
    } else if (password.isEmpty) {
      _dialogUtil.showMessage('Please enter password', context);
    } else {
      _loginStateCubit.doLogin(
        useCase: sl<LoginUseCase>(),
        params: LoginRequestParams(userName: mobileNo, password: password),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginStateCubit, LoginState>(
      bloc: _loginStateCubit,
      listener: (context, state) {
        if (state is LoginFailureState) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is LoginSuccessState) {
          Navigator.pushReplacementNamed(context, '/main_page');
        }
      },
      listenWhen:
          (previousState, currentState) =>
              currentState is LoginSuccessState ||
              currentState is LoginFailureState,
      child: Scaffold(
        backgroundColor: AppColor.kPrimaryColor,
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/login_background.png"),
              // Path to your image
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  LoginHeader(
                    heading: 'Welcome to KFON',
                    description: 'Don’t have an Account?  ',
                    onClicked: () => Navigator.pushNamed(context, '/sign_up'),
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
                        LoginTextField(
                          hintText: 'Enter Mobile Number',
                          textEditingController: _mobileNoTextFieldController,
                          iconName: 'mobile.png',
                          showBorder: false,
                          maxLength: 10,
                          textInputType: TextInputType.number,
                        ),
                        Divider(color: Colors.grey.shade200, thickness: 1.5),
                        PasswordTextField(
                          textEditingController: _passwordTextFieldController,
                          hintText: 'Enter Password',
                          showBorder: false,
                          showIcon: true,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: true,
                              checkColor: AppColor.kPrimaryColor,
                              activeColor: Colors.white,
                              // A boolean state variable
                              onChanged: (bool? newValue) {},
                            ),
                            const Text(
                              'Remember Me',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed:
                              () => Navigator.pushNamed(
                                context,
                                '/forgot_password_page',
                              ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: BlocBuilder<LoginStateCubit, LoginState>(
                      bloc: _loginStateCubit,
                      builder: (context, state) {
                        return WhiteButton(
                          isLoading: state is LoadingState,
                          label: 'Sign In',
                          borderRadius: 10,
                          textColor: AppColor.kPrimaryColor,
                          onClicked: () => _doLogin(),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    child: WhiteButton(
                      isLoading: false,
                      label: 'Enquiry Forms',
                      borderRadius: 10,
                      textColor: AppColor.kPrimaryColor,
                      onClicked:
                          () => Navigator.pushNamed(
                            context,
                            '/enquiry_list_page',
                          ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 30,
                  width: 180,
                  margin: EdgeInsets.only(bottom: 50),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: const Center(
                    child: Text(
                      'www.kerlainternet.com',
                      style: TextStyle(
                        color: AppColor.kPrimaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
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
