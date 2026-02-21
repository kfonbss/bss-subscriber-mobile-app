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
    await Future.delayed(const Duration(seconds: 3));

   // final result = await repository.getSubscriberDataUsage(event.params);

    // result.fold(
    //   (failure) {
    //     emit(
    //       state.copyWith(
    //         status: DataUsageStatus.error,
    //         error: failure.toString(),
    //       ),
    //     );
    //   },
    //   (dataUsage) {
    //     emit(state.copyWith(status: DataUsageStatus.loaded, data: dataUsage));
    //   },
    // );
    final SubscriberDataUsageResponseEntity dataUsage =  SubscriberDataUsageResponseEntity(
      period: 'November 2025',
      dataUsage: DataUsageEntity(
        period: 'November 2025',
        uploadGb: 12.5,
        downloadGb: 48.3,
        totalGb: 60.8,
        graphData: const [
          GraphDataEntity(day: 'Mon', usageGb: 2.1),
          GraphDataEntity(day: 'Tue', usageGb: 3.4),
          GraphDataEntity(day: 'Wed', usageGb: 1.8),
          GraphDataEntity(day: 'Thu', usageGb: 5.2),
          GraphDataEntity(day: 'Fri', usageGb: 4.7),
          GraphDataEntity(day: 'Sat', usageGb: 6.3),
          GraphDataEntity(day: 'Sun', usageGb: 3.9),
        ],
      ),
      activeSession: SessionEntity(
        startTime: DateTime(2025, 11, 20, 9, 15, 0),
        endTime: null,
        sessionDuration: '02:45:30',
        uploadMb: 320.5,
        downloadMb: 980.2,
        totalMb: 1300.7,
        networkDetails: const NetworkDetailsEntity(
          mac: 'AA:BB:CC:DD:EE:01',
          framedIp: '192.168.1.101',
          framedIpv6Prefix: '2001:db8::/32',
          framedIpv6Delegated: '2001:db8:1::/48',
        ),
      ),
      sessionHistory: [
        SessionEntity(
          startTime: DateTime(2025, 11, 19, 8, 0, 0),
          endTime: DateTime(2025, 11, 19, 20, 0, 0),
          sessionDuration: '12:00:00',
          uploadMb: 512.0,
          downloadMb: 2048.0,
          totalMb: 2560.0,
          networkDetails: const NetworkDetailsEntity(
            mac: 'AA:BB:CC:DD:EE:01',
            framedIp: '192.168.1.101',
            framedIpv6Prefix: '2001:db8::/32',
            framedIpv6Delegated: '2001:db8:1::/48',
          ),
        ),
        SessionEntity(
          startTime: DateTime(2025, 11, 18, 10, 30, 0),
          endTime: DateTime(2025, 11, 18, 18, 45, 0),
          sessionDuration: '08:15:00',
          uploadMb: 256.3,
          downloadMb: 1024.6,
          totalMb: 1280.9,
          networkDetails: const NetworkDetailsEntity(
            mac: 'AA:BB:CC:DD:EE:01',
            framedIp: '192.168.1.101',
            framedIpv6Prefix: '2001:db8::/32',
            framedIpv6Delegated: '2001:db8:1::/48',
          ),
        ),
      ],
    );
    emit(state.copyWith(status: DataUsageStatus.loaded, data: dataUsage));
  }
}
