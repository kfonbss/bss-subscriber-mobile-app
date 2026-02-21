import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/home/home_state.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomePageLoading());

  Future<void> getHomeData({dynamic params, required UseCase useCase}) async {
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) => emit(GetDataError(errorMessage: error)),
        (data) => emit(
          GetDataError(errorMessage: 'error'),
        ), // emit(GetDataSuccess(data)),
      );
    } catch (e) {
      emit(GetDataError(errorMessage: e.toString()));
    }
  }
}
