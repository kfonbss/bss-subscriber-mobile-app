import 'package:kfon_subscriber/features/enquiery_forms/data/model/region_model.dart';

abstract class CircleState {}

class CircleLoading extends CircleState {}

/// [regions] holds only active regions; an empty list means "no data".
class CircleLoaded extends CircleState {
  final List<RegionModel> regions;
  CircleLoaded({required this.regions});
}

class CircleError extends CircleState {
  final String errorMessage;
  CircleError({required this.errorMessage});
}
