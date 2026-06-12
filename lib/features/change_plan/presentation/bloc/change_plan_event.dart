import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/change_plan/domain/enums/subscriber_enums.dart';

abstract class ChangePlanEvent extends Equatable {
  const ChangePlanEvent();

  @override
  List<Object?> get props => [];
}

class LoadPackages extends ChangePlanEvent {
  final PlanTab tab;
  final String packageId;
  final String subscriberUuid;

  const LoadPackages({
    required this.tab,
    required this.packageId,
    required this.subscriberUuid,
  });

  @override
  List<Object?> get props => [tab, packageId, subscriberUuid];
}
class LoadMorePackages extends ChangePlanEvent {
  final PlanTab tab;
  final String packageId;
  final String subscriberUuid;

  const LoadMorePackages({
    required this.tab,
    required this.packageId,
    required this.subscriberUuid,
  });

  @override
  List<Object?> get props => [tab, packageId, subscriberUuid];
}

class SelectPackage extends ChangePlanEvent {
  final String packageId;

  const SelectPackage(this.packageId);

  @override
  List<Object?> get props => [packageId];
}

class SwitchTab extends ChangePlanEvent {
  final PlanTab tab;
  final String packageId;
  final String subscriberUuid;

  const SwitchTab({
    required this.tab,
    required this.packageId,
    required this.subscriberUuid,
  });

  @override
  List<Object?> get props => [tab, packageId, subscriberUuid];
}

class SearchPackages extends ChangePlanEvent {
  final String query;
  final String packageId;
  final String subscriberUuid;

  const SearchPackages({
    required this.query,
    required this.packageId,
    required this.subscriberUuid,
  });

  @override
  List<Object?> get props => [query, packageId, subscriberUuid];
}

class FilterBySpeed extends ChangePlanEvent {
  final int? speed;
  final String packageId;
  final String subscriberUuid;

  const FilterBySpeed({
    this.speed,
    required this.packageId,
    required this.subscriberUuid,
  });

  @override
  List<Object?> get props => [speed, packageId, subscriberUuid];
}
