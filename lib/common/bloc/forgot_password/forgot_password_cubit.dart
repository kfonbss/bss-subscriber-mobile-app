import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/forgot_password/forgot_password_state.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(InitialState());

  Future<void> sendOTP({dynamic params, required UseCase useCase}) async {
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

  Future<void> setNewPassword({
    dynamic params,
    required UseCase useCase,
  }) async {
    try {
      emit(SetNewPasswordLoadingState());
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(SetNewPasswordFailureState(errorMessage: error));
        },
        (data) {
          emit(SetNewPasswordSuccessState());
        },
      );
    } catch (e) {
      emit(SetNewPasswordFailureState(errorMessage: e.toString()));
    }
  }
}
