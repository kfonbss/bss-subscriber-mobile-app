import 'package:kfon_subscriber/data/home/model/home_response.dart';

abstract class HomeState {}

class HomePageLoading extends HomeState {}

class GetDataSuccess extends HomeState {
  final HomeResponse response;

  GetDataSuccess({required this.response});
}

class GetDataError extends HomeState {
  final String errorMessage;

  GetDataError({required this.errorMessage});
}
