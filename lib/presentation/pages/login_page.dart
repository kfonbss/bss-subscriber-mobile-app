import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/login/login_state.dart';
import 'package:kfon_subscriber/common/bloc/login/login_state_cubit.dart';
import 'package:kfon_subscriber/core/constant/constant.dart';
import 'package:kfon_subscriber/data/auth/model/login_req_params.dart';
import 'package:kfon_subscriber/domain/auth/usecases/login.dart';
import 'package:kfon_subscriber/presentation/page_component/login_background.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';
import 'package:kfon_subscriber/presentation/ui_component/secondary_button.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/util/dialog_util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();
  final LoginStateCubit _loginStateCubit = LoginStateCubit();
  final DialogUtil _dialogUtil = DialogUtil();

  @override
  void dispose() {
    _usernameTextFieldController.dispose();
    _passwordTextFieldController.dispose();
    _loginStateCubit.close();
    super.dispose();
  }

  _doLogin() {
    String userName = _usernameTextFieldController.text.trim();
    String password = _passwordTextFieldController.text.trim();
    if (userName.isEmpty || password.isEmpty) {
      _dialogUtil.showMessage('Please enter username and password', context);
      return;
    }
    _loginStateCubit.doLogin(
      useCase: sl<LoginUseCase>(),
      params: LoginRequestParams(userName: userName, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginStateCubit, LoginState>(
      bloc: _loginStateCubit,
      listener: (context, state) {
        if (state is LoginFailureState) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is LoginSuccessState) {
          Navigator.pushReplacementNamed(context, '/home_page');
        }
      },
      listenWhen:
          (previousState, currentState) =>
              currentState is LoginSuccessState ||
              currentState is LoginFailureState,
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        resizeToAvoidBottomInset: false,
        body: LoginBackground(
          heading: 'Log in',
          height: 650,
          bottomMargin: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CommonTextField(
                label: 'Username',
                hintText: 'Enter username here',
                textEditingController: _usernameTextFieldController,
              ),
              SizedBox(height: 20),
              CommonTextField(
                label: 'Password',
                hintText: 'Enter password here',
                textEditingController: _passwordTextFieldController,
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed:
                    () => Navigator.pushNamed(context, '/forgot_password_page'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 25),
              Image.asset('assets/images/reCAPTCHA.png',height: 60,),
              SizedBox(height: 25),
              BlocBuilder<LoginStateCubit, LoginState>(
                bloc: _loginStateCubit,
                builder: (context, state) {
                  return PrimaryButton(
                    isLoading: state is LoadingState,
                    icon: Image.asset(
                      'assets/images/login_icon.png',
                      height: 24,
                    ),
                    label: 'Login',
                    onClicked: () => _doLogin(),
                  );
                },
              ),
              SizedBox(height: 50),
              SecondaryButton(label: 'Register', onClicked: () {}),
              SizedBox(height: 10),
              SecondaryButton(label: 'FAQ', onClicked: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
