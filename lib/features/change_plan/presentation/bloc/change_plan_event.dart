import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/change_plan/domain/enums/subscriber_enums.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/change_plan_request_params.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/recharge_change_plan_params.dart';

abstract class ChangePlanEvent extends Equatable {
  const ChangePlanEvent();

  @override
  List<Object?> get props => [];
}

class LoadPackages extends ChangePlanEvent {
  final PlanTab tab;
  final String packageId;

  const LoadPackages({required this.tab, required this.packageId});

  @override
  List<Object?> get props => [tab, packageId];
}

class SelectPackage extends ChangePlanEvent {
  final String packageId;

  const SelectPackage(this.packageId);

  @override
  List<Object?> get props => [packageId];
}

class ChangePlan extends ChangePlanEvent {
  final String subscriberUuid;
  final ChangePlanRequestParams params;

  const ChangePlan({required this.subscriberUuid, required this.params});

  @override
  List<Object?> get props => [subscriberUuid, params];
}

class RechargeChangePlan extends ChangePlanEvent {
  final RechargeChangePlanParams params;

  const RechargeChangePlan({required this.params});

  @override
  List<Object?> get props => [params];
}

class SwitchTab extends ChangePlanEvent {
  final PlanTab tab;
  final String packageId;

  const SwitchTab({required this.tab, required this.packageId});

  @override
  List<Object?> get props => [tab, packageId];
}

class SearchPackages extends ChangePlanEvent {
  final String query;
  final String packageId;

  const SearchPackages({required this.query, required this.packageId});

  @override
  List<Object?> get props => [query, packageId];
}

class FilterBySpeed extends ChangePlanEvent {
  final int? speed;
  final String packageId;

  const FilterBySpeed({this.speed, required this.packageId});

  @override
  List<Object?> get props => [speed, packageId];
}
