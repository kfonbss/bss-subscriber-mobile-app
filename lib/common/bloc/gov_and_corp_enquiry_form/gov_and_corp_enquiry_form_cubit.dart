import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/gov_and_corp_enquiry_form/gov_and_corp_enquiry_form_state.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/gov_and_corp_enquiry_form_params.dart';
import 'package:kfon_subscriber/core/util/extensions.dart';

class GovAndCorpEnquiryFormCubit extends Cubit<GovAndCorpEnquiryFormState> {
  GovAndCorpEnquiryFormCubit() : super(ShowPersonalForm());

  Future<void> submitForm({
    required GovAndCorpEnquiryFormParams params,
    required UseCase useCase,
  }) async {
    try {
      emit(GovAndCorpFormSubmissionLoading());
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(GovAndCorpFormSubmissionError(errorMessage: error));
        },
        (data) {
          emit(GovAndCorpFormSubmissionSuccess());
        },
      );
    } catch (e) {
      emit(GovAndCorpFormSubmissionError(errorMessage: e.toString()));
    }
  }

  Future<void> validatePersonalForm({
    required GovAndCorpEnquiryFormParams params,
  }) async {
    if (params.firstName.trim().isEmpty) {
      emit(GovAndCorpFormValidationError(errorMessage: 'Enter First Name'));
    } else if (params.lastName.trim().isEmpty) {
      emit(GovAndCorpFormValidationError(errorMessage: 'Enter Last Name'));
    } else if (params.mobileNumber.trim().length != 10 ||
        int.tryParse(params.mobileNumber.trim()) == null) {
      emit(
        GovAndCorpFormValidationError(
          errorMessage: 'Enter Valid Mobile Number',
        ),
      );
    } else if (!params.email.isValidEmail) {
      emit(GovAndCorpFormValidationError(errorMessage: 'Enter Valid Email'));
    } else {
      emit(ShowLocationForm());
    }
  }

  Future<void> validateLocationForm({
    required GovAndCorpEnquiryFormParams params,
  }) async {
    if (params.companyName.trim().isEmpty) {
      emit(GovAndCorpFormValidationError(errorMessage: 'Enter Company Name'));
    } else if (params.pinCode.trim().length != 6 ||
        int.tryParse(params.pinCode.trim()) == null) {
      emit(GovAndCorpFormValidationError(errorMessage: 'Enter Pin Code'));
    } else if (params.industry.trim().isEmpty) {
      emit(GovAndCorpFormValidationError(errorMessage: 'Select Industry'));
    } else if (params.service.trim().isEmpty) {
      emit(GovAndCorpFormValidationError(errorMessage: 'Select Service'));
    } else {
      emit(ShowPreview());
    }
  }

  Future<void> showLocationForm() async => emit(ShowLocationForm());

  Future<void> showPersonalForm() async => emit(ShowPersonalForm());
}
