import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/auth/auth_state.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';

class AuthStateCubit extends Cubit<AuthState> {
  AuthStateCubit() : super(InitialState());

  Future<void> checkLoginStatus({
    dynamic params,
    required UseCase useCase,
  }) async {
    bool status = await useCase.call(param: params);
    if (status) {
      emit(Authenticated());
    } else {
      emit(UnAuthenticated());
    }
  }
}
