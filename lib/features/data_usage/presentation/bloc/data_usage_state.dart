import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/data_usage/domain/entity/data_usage_entity.dart';


/// Status for data usage sub-feature
enum DataUsageStatus { initial, loading, loaded, error }
/// Sub-state for data usage feature
class DataUsageState extends Equatable {
  final DataUsageStatus status;
  final SubscriberDataUsageResponseEntity? data;
  final String? error;

  factory DataUsageState.initial() => const DataUsageState();

  const DataUsageState({
    this.status = DataUsageStatus.initial,
    this.data,
    this.error,
  });

  DataUsageState copyWith({
    DataUsageStatus? status,
    SubscriberDataUsageResponseEntity? data,
    String? error,
  }) {
    return DataUsageState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}

