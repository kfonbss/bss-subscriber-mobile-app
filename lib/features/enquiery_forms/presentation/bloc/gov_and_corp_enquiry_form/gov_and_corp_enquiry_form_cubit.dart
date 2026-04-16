import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/extensions.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/gov_and_corp_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/gov_and_corp_enquiry_form/gov_and_corp_enquiry_form_state.dart';

class GovAndCorpEnquiryFormCubit extends Cubit<GovAndCorpEnquiryFormState> {
  GovAndCorpEnquiryFormCubit({required this.repository})
    : super(ShowPersonalForm());
  final EnquiryFormRepository repository;

  Future<void> submitForm({required GovAndCorpEnquiryFormParams params}) async {
    try {
      emit(GovAndCorpFormSubmissionLoading());
      final result = await repository.submitGovAndCorpEnquiryForm(params);
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
