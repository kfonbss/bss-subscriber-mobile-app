import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class GetHomeData extends HomeEvent {
  const GetHomeData();
}

class GetActivePackageDetails extends HomeEvent {
  const GetActivePackageDetails();
}

class GetPlans extends HomeEvent {
  final String packageId;
  final String subscriberUuid;

  const GetPlans({required this.packageId, required this.subscriberUuid});

  @override
  List<Object?> get props => [packageId, subscriberUuid];
}
