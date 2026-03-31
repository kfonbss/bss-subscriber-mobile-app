import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/extensions.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/agnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/agnp_form/agnp_form_state.dart';

class AGNPFormCubit extends Cubit<AGNPFormState> {
  AGNPFormCubit({required this.repository})
    : super(ShowCompanyInformationForm());
  final EnquiryFormRepository repository;

  Future<void> submitForm({required AGNPEnquiryFormParams params}) async {
    try {
      emit(SubmitAGNPFormLoading());
      final result = await repository.submitAGNPEnquiryForm(params);
      result.fold(
        (error) {
          emit(SubmitAGNPFormError(errorMessage: error));
        },
        (data) {
          emit(SubmitAGNPFormSuccess());
        },
      );
    } catch (e) {
      emit(SubmitAGNPFormError(errorMessage: e.toString()));
    }
  }

  Future<void> validateCompanyForm({
    required AGNPEnquiryFormParams params,
  }) async {
    if (params.name.trim().isEmpty) {
      emit(SubscriptionFormValidationError(errorMessage: 'Enter AGNP Name'));
    } else if (params.contactName.trim().isEmpty) {
      emit(
        SubscriptionFormValidationError(
          errorMessage: 'Enter AGNP Contact Name',
        ),
      );
    } else if (params.mobileNumber.trim().length != 10 ||
        int.tryParse(params.mobileNumber.trim()) == null) {
      emit(
        SubscriptionFormValidationError(
          errorMessage: 'Enter Valid AGNP Mobile Number',
        ),
      );
    } else if (!params.email.isValidEmail) {
      emit(
        SubscriptionFormValidationError(errorMessage: 'Enter Valid AGNP Email'),
      );
    } else if (params.address.trim().isEmpty) {
      emit(
        SubscriptionFormValidationError(
          errorMessage: 'Enter AGNP Full Address',
        ),
      );
    } else {
      emit(ShowGeographicInformationForm());
    }
  }

  Future<void> validateGeographicForm({
    required AGNPEnquiryFormParams params,
  }) async {
    if (params.pinCode.trim().isEmpty ||
        int.tryParse(params.pinCode.trim()) == null) {
      emit(
        SubscriptionFormValidationError(errorMessage: 'Enter AGNP Pin Code'),
      );
    } else if (params.postOffice.trim().isEmpty) {
      emit(SubscriptionFormValidationError(errorMessage: 'Select Post Office'));
    } else if (params.district.trim().isEmpty) {
      emit(SubscriptionFormValidationError(errorMessage: 'Select District'));
    } else {
      emit(ShowPreview());
    }
  }

  Future<void> showCompanyInformationForm() async =>
      emit(ShowCompanyInformationForm());

  Future<void> showGeographicInformationForm() async =>
      emit(ShowGeographicInformationForm());
}
