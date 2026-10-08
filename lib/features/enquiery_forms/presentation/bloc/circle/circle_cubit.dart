import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/region_model.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/circle/circle_state.dart';

class CircleCubit extends Cubit<CircleState> {
  CircleCubit({required this.repository}) : super(CircleLoading());
  final EnquiryFormRepository repository;

  Future<void> fetchRegions() async {
    try {
      emit(CircleLoading());
      final result = await repository.fetchRegions();
      result.fold(
        (error) => emit(CircleError(errorMessage: error.toString())),
        (data) => emit(CircleLoaded(regions: List<RegionModel>.from(data))),
      );
    } catch (e) {
      emit(CircleError(errorMessage: e.toString()));
    }
  }
}
