abstract class SignUpState {}

class InitialState extends SignUpState {}

class VerifyOTPLoadingState extends SignUpState {}

class VerifyOTPSuccessState extends SignUpState {}

class GetOTPLoadingState extends SignUpState {}

class GetOTPSuccessState extends SignUpState {}

class GetOTPFailureState extends SignUpState {
  final String errorMessage;
  GetOTPFailureState({required this.errorMessage});
}


class VerifyOTPFailureState extends SignUpState {
  final String errorMessage;
  VerifyOTPFailureState({required this.errorMessage});
}

