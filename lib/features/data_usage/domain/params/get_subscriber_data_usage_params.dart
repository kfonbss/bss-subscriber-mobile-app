import 'package:equatable/equatable.dart';

class GetSubscriberDataUsageParams extends Equatable {
  final String subscriberUuid;
  final String period;

  const GetSubscriberDataUsageParams({
    required this.subscriberUuid,
    required this.period,
  });

  Map<String, dynamic> toJson() {
    return {'subscriberUuid': subscriberUuid, 'period': period};
  }

  @override
  List<Object?> get props => [subscriberUuid, period];
}
