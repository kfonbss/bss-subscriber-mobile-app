import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/corporate_form/corporate_form_state.dart';
import 'package:kfon_subscriber/core/usercase/usecase.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/corporate_enquiry_form_params.dart';
import 'package:kfon_subscriber/util/extensions.dart';

class CorporateFormCubit extends Cubit<CorporateFormState> {
  CorporateFormCubit() : super(ShowForm());

  Future<void> submitForm({
    required CorporateEnquiryFormParams params,
    required UseCase useCase,
  }) async {
    try {
      emit(SubmitCorporateFormLoading());
      await Future.delayed(const Duration(seconds: 3));
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(SubmitCorporateFormError(errorMessage: error));
        },
        (data) {
          emit(SubmitCorporateFormSuccess());
        },
      );
    } catch (e) {
      emit(SubmitCorporateFormError(errorMessage: e.toString()));
    }
  }

  Future<void> validateForm({
    required CorporateEnquiryFormParams params,
  }) async {
    if (params.companyName.trim().isEmpty) {
      emit(CorporateFormValidationError(errorMessage: 'Enter Company Name'));
    }else if (params.contactPersonName.trim().isEmpty) {
      emit(CorporateFormValidationError(errorMessage: 'Enter Contact Name'));
    } else if (params.contactPersonPhoneNumber.trim().isEmpty ||
        int.tryParse(params.contactPersonPhoneNumber.trim()) == null) {
      emit(
        CorporateFormValidationError(
          errorMessage: 'Enter Valid Contact Number',
        ),
      );
    } else if (!params.email.isValidEmail) {
      emit(CorporateFormValidationError(errorMessage: 'Enter Valid Email'));
    } else if (params.address.trim().isEmpty) {
      emit(
        CorporateFormValidationError(
          errorMessage: 'Enter Company Location/Address',
        ),
      );
    } else if (params.companyType.trim().isEmpty) {
      emit(CorporateFormValidationError(errorMessage: 'Select Company Type'));
    } else if (params.requiredServices.isEmpty) {
      emit(
        CorporateFormValidationError(errorMessage: 'Select Required Services'),
      );
    } else {
      emit(ShowPreview());
    }
  }

  Future<void> showForm() async => emit(ShowForm());

}
