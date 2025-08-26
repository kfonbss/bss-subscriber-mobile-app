abstract class ForgotPasswordState {}

class InitialState extends ForgotPasswordState {}

class VerifyOTPLoadingState extends ForgotPasswordState {}

class SetNewPasswordLoadingState extends ForgotPasswordState {}

class VerifyOTPSuccessState extends ForgotPasswordState {}

class SetNewPasswordSuccessState extends ForgotPasswordState {}

class GetOTPLoadingState extends ForgotPasswordState {}

class GetOTPSuccessState extends ForgotPasswordState {}

class GetOTPFailureState extends ForgotPasswordState {
  final String errorMessage;
  GetOTPFailureState({required this.errorMessage});
}


class VerifyOTPFailureState extends ForgotPasswordState {
  final String errorMessage;
  VerifyOTPFailureState({required this.errorMessage});
}


class SetNewPasswordFailureState extends ForgotPasswordState {
  final String errorMessage;
  SetNewPasswordFailureState({required this.errorMessage});
}