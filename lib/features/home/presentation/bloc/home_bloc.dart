import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/get_all_packages_parms.dart';
import 'package:kfon_subscriber/features/home/domain/repository/home_repository.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_event.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;

  HomeBloc({required this.repository}) : super(const HomeInitial()) {
    on<GetHomeData>(_onLoadHomeData);
    on<GetPlans>(_onLoadPlans);
  }

  Future<void> _onLoadHomeData(
    GetHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final result = await repository.getHomePageData();
      result.fold(
        (failure) => emit(GetDataFailure(errorMessage: failure.toString())),
        (homeEntity) => emit(GetDataSuccess(homeEntity: homeEntity)),
      );
    } catch (e) {
      emit(GetDataFailure(errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadPlans(
    GetPlans event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final result = await repository.getPackages(
        GetAllPackagesParams(
          subscriberId: event.subscriberUuid,
          type: 'retail',
          search: null,
          speedMbps: null,
          ott: null,
        ),
      );
      result.fold(
        (failure) => emit(GetPlansFailure(errorMessage: failure.toString())),
        (packages) => emit(
          GetPlansSuccess(
            packageEntities: packages
                .where((package) => package.packageId != event.packageId)
                .take(2)
                .toList(),
          ),
        ),
      );
    } catch (e) {
      emit(GetPlansFailure(errorMessage: e.toString()));
    }
  }
}
