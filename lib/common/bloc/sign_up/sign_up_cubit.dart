import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/sign_up/sign_up_state.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(InitialState());

  Future<void> getOTP({dynamic params, required UseCase useCase}) async {
    try {
      emit(GetOTPLoadingState());
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(GetOTPFailureState(errorMessage: error));
        },
        (data) {
          emit(GetOTPSuccessState());
        },
      );
    } catch (e) {
      emit(GetOTPFailureState(errorMessage: e.toString()));
    }
  }

  Future<void> verifyOTP({dynamic params, required UseCase useCase}) async {
    try {
      emit(VerifyOTPLoadingState());
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(VerifyOTPFailureState(errorMessage: error));
        },
        (data) {
          emit(VerifyOTPSuccessState());
        },
      );
    } catch (e) {
      emit(VerifyOTPFailureState(errorMessage: e.toString()));
    }
  }
}
