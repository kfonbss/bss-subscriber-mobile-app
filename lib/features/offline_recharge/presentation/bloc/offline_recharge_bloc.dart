import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/offline_recharge/domain/repository/offline_recharge_repository.dart';
import 'package:kfon_subscriber/features/offline_recharge/presentation/bloc/offline_recharge_event.dart';
import 'package:kfon_subscriber/features/offline_recharge/presentation/bloc/offline_recharge_state.dart';

class OfflineRechargeBloc
    extends Bloc<OfflineRechargeEvent, OfflineRechargeState> {
  final OfflineRechargeRepository repository;

  OfflineRechargeBloc({required this.repository}) : super(const Initial()) {
    on<GetData>(_onLoadData);
    on<Recharge>(_onRecharge);
  }

  Future<void> _onLoadData(
    GetData event,
    Emitter<OfflineRechargeState> emit,
  ) async {
    try {
      final result = await repository.getRechargeData(event.subscriberUuid);
      result.fold(
        (failure) {
          emit(OnFailure(errorMessage: failure.toString()));
        },
        (entity) {
          emit(GetDataSuccess(entity: entity));
        },
      );
    } catch (e) {
      emit(OnFailure(errorMessage: e.toString()));
    }
  }

  Future<void> _onRecharge(
    Recharge event,
    Emitter<OfflineRechargeState> emit,
  ) async {
    try {
      emit(OnRecharging());
      // final result = await repository.getRechargeData();
      // result.fold(
      //   (failure) {
      //     emit(OnFailure(errorMessage: failure.toString()));
      //   },
      //   (entity) {
      //     emit(RechargeSuccess(entity: entity));
      //   },
      // );
    } catch (e) {
      emit(OnFailure(errorMessage: e.toString()));
    }
  }
}
