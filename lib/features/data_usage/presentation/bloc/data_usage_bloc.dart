import 'package:kfon_subscriber/features/data_usage/domain/entity/data_usage_entity.dart';
import 'package:kfon_subscriber/features/data_usage/domain/repository/data_usage_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/bloc/data_usage_event.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/bloc/data_usage_state.dart';

class DataUsageBloc
    extends Bloc<DataUsageEvent, DataUsageState> {
  final DataUsageRepository repository;

  DataUsageBloc({required this.repository})
    : super(DataUsageState.initial()) {
    on<LoadSubscriberDataUsage>(_onLoadSubscriberDataUsage);
  }

  Future<void> _onLoadSubscriberDataUsage(
    LoadSubscriberDataUsage event,
    Emitter<DataUsageState> emit,
  ) async {
    emit(state.copyWith(status: DataUsageStatus.loading));

   final result = await repository.getSubscriberDataUsage(event.params);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: DataUsageStatus.error,
            error: failure.toString(),
          ),
        );
      },
      (dataUsage) {
        emit(state.copyWith(status: DataUsageStatus.loaded, data: dataUsage));
      },
    );

  }
}
