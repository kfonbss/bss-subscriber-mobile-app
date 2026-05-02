import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
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
      await result.fold(
        (failure) async =>
            emit(GetDataFailure(errorMessage: failure.toString())),
        (homeEntity) async {
          await PreferenceUtils.setUserDetails(
            userId: homeEntity.subscriberId,
            userName: homeEntity.firstName,
          );
          emit(
            GetDataSuccess(
              homeEntity: homeEntity,
              loadPackage: event.loadPackage,
            ),
          );
        },
      );
    } catch (e) {
      emit(GetDataFailure(errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadPlans(GetPlans event, Emitter<HomeState> emit) async {
    try {
      final result = await repository.getPackages(
        GetAllPackagesParams(
          subscriberId: event.subscriberUuid,
          type: 'retail',
          search: null,
          speedMbps: null,
          ott: null,
          page: 0,
          size: 2,
        ),
      );
      result.fold(
        (failure) => emit(GetPlansFailure(errorMessage: failure.toString())),
        (packages) => emit(
          GetPlansSuccess(
            // packageEntities:
            //     packages.content
            //         .where((package) => package.id != event.packageId)
            //         .take(2)
            //         .toList(),
            packageEntities: packages.content
          ),
        ),
      );
    } catch (e) {
      emit(GetPlansFailure(errorMessage: e.toString()));
    }
  }
}
