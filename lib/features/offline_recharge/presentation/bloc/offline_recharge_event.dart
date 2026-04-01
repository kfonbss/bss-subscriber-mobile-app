import 'package:equatable/equatable.dart';

abstract class OfflineRechargeEvent extends Equatable {
  const OfflineRechargeEvent();

  @override
  List<Object?> get props => [];
}

class GetData extends OfflineRechargeEvent {
  final String subscriberUuid;

  const GetData({required this.subscriberUuid});

  @override
  List<Object?> get props => [subscriberUuid];
}

class Recharge extends OfflineRechargeEvent {
  const Recharge();
}
