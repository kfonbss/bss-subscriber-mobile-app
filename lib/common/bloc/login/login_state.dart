abstract class LoginState {}

class InitialState extends LoginState {}

class LoadingState extends LoginState {}

class LoginSuccessState extends LoginState {}

class LoginFailureState extends LoginState {
  final String errorMessage;
  LoginFailureState({required this.errorMessage});
}