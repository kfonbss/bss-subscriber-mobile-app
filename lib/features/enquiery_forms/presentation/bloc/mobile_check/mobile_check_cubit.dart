import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/mobile_check/mobile_check_state.dart';

class MobileCheckCubit extends Cubit<MobileCheckState> {
  MobileCheckCubit({required this.repository}) : super(MobileCheckInitial());
  final EnquiryFormRepository repository;

  Future<void> checkMobile({
    required String mobileNumber,
    required String tenantId,
  }) async {
    try {
      emit(MobileCheckLoading());
      final result = await repository.checkMobileRegistered(
        mobileNumber: mobileNumber,
        tenantId: tenantId,
      );
      result.fold(
        (error) => emit(MobileCheckError(errorMessage: error.toString())),
        (data) => emit(
          data == null
              ? MobileNotRegistered()
              : MobileAlreadyRegistered(
                mobileNumber: mobileNumber,
                trackingId: data is Map ? data['trackingId']?.toString() : null,
              ),
        ),
      );
    } catch (e) {
      emit(MobileCheckError(errorMessage: e.toString()));
    }
  }
}
