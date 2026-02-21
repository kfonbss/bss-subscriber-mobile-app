import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/login/login_state.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';

class LoginStateCubit extends Cubit<LoginState> {
  LoginStateCubit() : super(InitialState());

  Future<void> doLogin({dynamic params, required UseCase useCase}) async {
    try {
      emit(LoadingState());
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(LoginSuccessState());
         // emit(LoginFailureState(errorMessage: error));
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
