import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/login/login_state.dart';
import 'package:kfon_subscriber/core/usercase/usecase.dart';

class LoginStateCubit extends Cubit<LoginState> {
  LoginStateCubit() : super(InitialState());

  Future<void> doLogin({dynamic params, required UseCase useCase}) async {
    try {
      emit(LoadingState());
      await Future.delayed(const Duration(seconds: 3));
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(LoginFailureState(errorMessage: error));
        },
        (data) {
          emit(LoginSuccessState());
        },
      );
    } catch (e) {
      emit(LoginFailureState(errorMessage: e.toString()));
    }
  }
}
