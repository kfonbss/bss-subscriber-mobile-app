import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/self_care/domain/entity/speed_test_entity.dart';
import 'package:kfon_subscriber/features/self_care/domain/repository/speed_test_repository.dart';

// ── Events ───────────────────────────────────────────────────────────────────
abstract class SpeedTestEvent extends Equatable {
  const SpeedTestEvent();

  @override
  List<Object?> get props => [];
}

class RunSpeedTest extends SpeedTestEvent {
  const RunSpeedTest();
}

// ── State ────────────────────────────────────────────────────────────────────
enum SpeedTestStatus { initial, loading, loaded, error }

class SpeedTestState extends Equatable {
  final SpeedTestStatus status;
  final SpeedTestEntity? result;
  final String? error;

  const SpeedTestState({
    this.status = SpeedTestStatus.initial,
    this.result,
    this.error,
  });

  SpeedTestState copyWith({
    SpeedTestStatus? status,
    SpeedTestEntity? result,
    String? error,
  }) {
    return SpeedTestState(
      status: status ?? this.status,
      result: result ?? this.result,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, result, error];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────
class SpeedTestBloc extends Bloc<SpeedTestEvent, SpeedTestState> {
  final SpeedTestRepository repository;

  SpeedTestBloc({required this.repository}) : super(const SpeedTestState()) {
    on<RunSpeedTest>(_onRunSpeedTest);
  }

  Future<void> _onRunSpeedTest(
    RunSpeedTest event,
    Emitter<SpeedTestState> emit,
  ) async {
    if (state.status == SpeedTestStatus.loading) return;
    emit(state.copyWith(status: SpeedTestStatus.loading));
    try {
      final result = await repository.runSpeedTest();
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: SpeedTestStatus.error,
            error: failure.toString(),
          ),
        ),
        (data) =>
            emit(state.copyWith(status: SpeedTestStatus.loaded, result: data)),
      );
    } catch (e) {
      emit(state.copyWith(status: SpeedTestStatus.error, error: e.toString()));
    }
  }
}
