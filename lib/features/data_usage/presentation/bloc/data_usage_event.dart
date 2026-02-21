import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/data_usage/domain/params/get_subscriber_data_usage_params.dart';

abstract class DataUsageEvent extends Equatable {
  const DataUsageEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscriberDataUsage extends DataUsageEvent {
  final GetSubscriberDataUsageParams params;

  const LoadSubscriberDataUsage({required this.params});

  @override
  List<Object?> get props => [params];
}
