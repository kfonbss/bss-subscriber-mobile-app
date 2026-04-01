import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/extensions.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/lnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/lnp_enquiry_form/lnp_enquiry_form_state.dart';

class LnpEnquiryFormCubit extends Cubit<LnpEnquiryFormState> {
  LnpEnquiryFormCubit({required this.repository})
    : super(ShowCompanyInformationForm());
  final EnquiryFormRepository repository;

  Future<void> submitForm({required LNPEnquiryFormParams params}) async {
    try {
      emit(SubmitLnpFormLoading());
      final result = await repository.submitLNPEnquiryForm(params);
      result.fold(
        (error) {
          emit(SubmitLnpFormError(errorMessage: error));
        },
        (data) {
          emit(SubmitLnpFormSuccess());
        },
      );
    } catch (e) {
      emit(SubmitLnpFormError(errorMessage: e.toString()));
    }
  }

  void validatePersonalForm(LNPEnquiryFormParams param) {
    if (param.mobileNumber.trim().length != 10 ||
        int.tryParse(param.mobileNumber.trim()) == null) {
      emit(LnpFormValidationError(errorMessage: 'Enter Valid Mobile Number'));
    } else if (!param.email.isValidEmail) {
      emit(LnpFormValidationError(errorMessage: 'Enter Valid Email'));
    } else if (param.address.trim().isEmpty) {
      emit(LnpFormValidationError(errorMessage: 'Enter Address'));
    } else if (param.pinCode.trim().isEmpty ||
        int.tryParse(param.pinCode.trim()) == null) {
      emit(LnpFormValidationError(errorMessage: 'Enter Pin Code'));
    } else if (param.postOffice.trim().isEmpty) {
      emit(LnpFormValidationError(errorMessage: 'Select Post Office'));
    } else if (param.district.trim().isEmpty) {
      emit(LnpFormValidationError(errorMessage: 'Select District'));
    } else if (param.selectedFiles.isEmpty) {
      emit(
        LnpFormValidationError(
          errorMessage: 'Upload CableTV Registration license copy',
        ),
      );
    } else if (param.totalCableTvSubscriberCount.isEmpty ||
        int.tryParse(param.totalCableTvSubscriberCount.trim()) == null) {
      emit(
        LnpFormValidationError(
          errorMessage: 'Enter Total No of existing CableTV Subscriber',
        ),
      );
    } else if (param.totalInternetSubscriberCount.isEmpty ||
        int.tryParse(param.totalInternetSubscriberCount.trim()) == null) {
      emit(
        LnpFormValidationError(
          errorMessage: 'Enter Total No of existing Internet Subscriber',
        ),
      );
    } else if (param.totalFiberCount.isEmpty ||
        int.tryParse(param.totalFiberCount.trim()) == null) {
      emit(
        LnpFormValidationError(
          errorMessage: 'Enter Total quantity of Fibre Available',
        ),
      );
    } else if (param.createdBy.isEmpty) {
      emit(LnpFormValidationError(errorMessage: 'Choose Created By'));
    } else {
      emit(ShowPreview());
    }
  }

  void validateCompanyForm(LNPEnquiryFormParams param) {
    if (param.companyName.trim().isEmpty) {
      emit(LnpFormValidationError(errorMessage: 'Enter Company Name'));
    } else if (param.partnerName.trim().isEmpty) {
      emit(LnpFormValidationError(errorMessage: 'Enter Partner Name'));
    } else {
      emit(ShowPersonalInformationForm());
    }
  }

  Future<void> showCompanyForm() async => emit(ShowCompanyInformationForm());

  Future<void> showPersonalCompanyForm() async =>
      emit(ShowPersonalInformationForm());
}
