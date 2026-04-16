import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/repository/package_details_repository.dart';
import 'package:kfon_subscriber/features/active_package_details/presentation/bloc/package_details_event.dart';
import 'package:kfon_subscriber/features/active_package_details/presentation/bloc/package_details_state.dart';

class PackageDetailsBloc extends Bloc<PackageDetailsEvent, PackageDetailsState> {
  final PackageDetailsRepository repository;

  PackageDetailsBloc({required this.repository}) : super(const Initial()) {
    on<GetActivePackageDetails>(_onLoadPlansData);
  }

  Future<void> _onLoadPlansData(
    GetActivePackageDetails event,
    Emitter<PackageDetailsState> emit,
  ) async {
    emit(const PackageDetailsLoading());
    try {
      final result = await repository.getPackageDetails(event.subscriberUuid);
      result.fold(
        (failure) => emit(GetDataFailure(errorMessage: failure.toString())),
        (entity) => emit(GetDataSuccess(entity: entity)),
      );
    } catch (e) {
      emit(GetDataFailure(errorMessage: e.toString()));
    }
  }
}
