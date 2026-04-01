import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/get_all_packages_parms.dart';
import 'package:kfon_subscriber/features/home/domain/entity/home_entity.dart';
import 'package:kfon_subscriber/features/home/domain/repository/home_repository.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_event.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;
  HomeEntity? homeData;

  HomeBloc({required this.repository}) : super(const HomeInitial()) {
    on<GetHomeData>(_onLoadHomeData);
    on<GetPlans>(_onLoadPlans);
  }

  Future<void> _onLoadHomeData(
    GetHomeData event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final result = await repository.getHomePageData();
      result.fold(
        (failure) {
          emit(GetDataFailure(errorMessage: failure.toString()));
        },
        (homeEntity) {
          homeData = homeEntity;
          emit(GetDataSuccess(homeEntity: homeEntity));
        },
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
          search:  null,
          speedMbps: null,
          ott: null,
        ),
      );
      result.fold(
            (failure) {
          emit(GetDataFailure(errorMessage: failure.toString()));
        },
            (packages) {
              emit(GetPlansSuccess(
                packageEntities: packages
                    .where((package) => package.packageId != event.packageId) // Filter out current ID
                    .take(2)                                           // Take top 2 from remainder
                    .toList(),                                         // Convert back to List
              ));
        },
      );
    } catch (e) {
      emit(GetDataFailure(errorMessage: e.toString()));
    }
  }
}
