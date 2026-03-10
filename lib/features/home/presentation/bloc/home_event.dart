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

  const GetPlans({required this.packageId});

  @override
  List<Object?> get props => [packageId];
}
