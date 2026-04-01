import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/offline_recharge/domain/entity/offline_recharge_data_entity.dart';

abstract class OfflineRechargeState extends Equatable {
  const OfflineRechargeState();

  @override
  List<Object?> get props => [];
}

class Initial extends OfflineRechargeState {
  const Initial();
}

class OnRecharging extends OfflineRechargeState {
  const OnRecharging();
}

class GetDataSuccess extends OfflineRechargeState {
  final OfflineRechargeDataEntity entity;

  const GetDataSuccess({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class RechargeSuccess extends OfflineRechargeState {
  const RechargeSuccess();
}

class OnFailure extends OfflineRechargeState {
  final String errorMessage;

  const OnFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
