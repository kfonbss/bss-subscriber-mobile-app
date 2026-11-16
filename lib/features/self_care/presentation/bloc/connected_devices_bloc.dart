import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/self_care/domain/entity/connected_device_entity.dart';
import 'package:kfon_subscriber/features/self_care/domain/repository/connected_devices_repository.dart';

// ── Events ───────────────────────────────────────────────────────────────────
abstract class ConnectedDevicesEvent extends Equatable {
  const ConnectedDevicesEvent();

  @override
  List<Object?> get props => [];
}

/// First load, the refresh icon and pull-to-refresh all use this.
class LoadConnectedDevices extends ConnectedDevicesEvent {
  const LoadConnectedDevices();
}

// ── State ────────────────────────────────────────────────────────────────────
enum ConnectedDevicesStatus { initial, loading, loaded, error }

class ConnectedDevicesState extends Equatable {
  final ConnectedDevicesStatus status;
  final List<ConnectedDeviceEntity> devices;
  final String? error;

  const ConnectedDevicesState({
    this.status = ConnectedDevicesStatus.initial,
    this.devices = const [],
    this.error,
  });

  ConnectedDevicesState copyWith({
    ConnectedDevicesStatus? status,
    List<ConnectedDeviceEntity>? devices,
    String? error,
  }) {
    return ConnectedDevicesState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, devices, error];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────
class ConnectedDevicesBloc
    extends Bloc<ConnectedDevicesEvent, ConnectedDevicesState> {
  final ConnectedDevicesRepository repository;

  ConnectedDevicesBloc({required this.repository})
    : super(const ConnectedDevicesState()) {
    on<LoadConnectedDevices>(_onLoad);
  }

  Future<void> _onLoad(
    LoadConnectedDevices event,
    Emitter<ConnectedDevicesState> emit,
  ) async {
    if (state.status == ConnectedDevicesStatus.loading) return;
    emit(state.copyWith(status: ConnectedDevicesStatus.loading));
    try {
      final result = await repository.getConnectedDevices();
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: ConnectedDevicesStatus.error,
            error: failure.toString(),
          ),
        ),
        (devices) => emit(
          state.copyWith(
            status: ConnectedDevicesStatus.loaded,
            devices: devices,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConnectedDevicesStatus.error,
          error: e.toString(),
        ),
      );
    }
  }
}
