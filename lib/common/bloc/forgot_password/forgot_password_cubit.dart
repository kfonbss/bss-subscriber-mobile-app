import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/forgot_password/forgot_password_state.dart';
import 'package:kfon_subscriber/core/usercase/usecase.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(InitialState());

  Future<void> sendOTP({dynamic params, required UseCase useCase}) async {
    emit(SendOTPLoadingState());
    await Future.delayed(const Duration(seconds: 3));
    emit(GetOTPSuccessState());
    // try {
    //emit(SendOTPLoadingState());
    //   Either result = await useCase.call(param: params);
    //   result.fold((error) {
    //     emit(SendOTPFailureState(errorMessage: error));
    //   }, (data) {
    //     emit(SendOTPSuccessState());
    //   });
    // } catch (e) {
    //   emit(SendOTPFailureState(errorMessage: e.toString()));
    // }
  }


  Future<void> verifyOTP({dynamic params, required UseCase useCase}) async {
    emit(VerifyOTPLoadingState());
    await Future.delayed(const Duration(seconds: 3));
    emit(VerifyOTPSuccessState());
    // try {
    //   emit(VerifyOTPLoadingState());
    //   await Future.delayed(const Duration(seconds: 3));
    //   Either result = await useCase.call(param: params);
    //   result.fold((error) {
    //     emit(VerifyOTPFailureState(errorMessage: error));
    //   }, (data) {
    //     emit(VerifyOTPSuccessState());
    //   });
    // } catch (e) {
    //   emit(VerifyOTPFailureState(errorMessage: e.toString()));
    // }
  }


  Future<void> setNewPassword({dynamic params, required UseCase useCase}) async {
    emit(SetNewPasswordLoadingState());
    await Future.delayed(const Duration(seconds: 3));
    emit(SetNewPasswordSuccessState());
    // try {
    //   emit(SetNewPasswordLoadingState());
    //   await Future.delayed(const Duration(seconds: 3));
    //   Either result = await useCase.call(param: params);
    //   result.fold((error) {
    //     emit(SetNewPasswordFailureState(errorMessage: error));
    //   }, (data) {
    //     emit(SetNewPasswordSuccessState());
    //   });
    // } catch (e) {
    //   emit(SetNewPasswordFailureState(errorMessage: e.toString()));
    // }
  }
}