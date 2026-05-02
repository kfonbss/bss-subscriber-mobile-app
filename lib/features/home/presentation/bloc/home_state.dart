import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/home/domain/entity/home_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class GetDataSuccess extends HomeState {
  final HomeEntity homeEntity;
  final bool loadPackage;

  const GetDataSuccess({required this.homeEntity, required this.loadPackage});

  @override
  List<Object?> get props => [homeEntity, loadPackage];
}

class GetPlansSuccess extends HomeState {
  final List<PackageItemEntity> packageEntities;

  const GetPlansSuccess({required this.packageEntities});

  @override
  List<Object?> get props => [packageEntities];
}

class GetDataFailure extends HomeState {
  final String errorMessage;

  const GetDataFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class GetPlansFailure extends HomeState {
  final String errorMessage;

  const GetPlansFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
