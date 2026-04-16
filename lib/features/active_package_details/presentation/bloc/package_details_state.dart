import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/entity/active_packages_details_entity.dart';

abstract class PackageDetailsState extends Equatable {
  const PackageDetailsState();

  @override
  List<Object?> get props => [];
}

class Initial extends PackageDetailsState {
  const Initial();
}

class PackageDetailsLoading extends PackageDetailsState {
  const PackageDetailsLoading();
}

class GetDataSuccess extends PackageDetailsState {
  final ActivePackagesDetailsEntity entity;

  const GetDataSuccess({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class GetDataFailure extends PackageDetailsState {
  final String errorMessage;

  const GetDataFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
