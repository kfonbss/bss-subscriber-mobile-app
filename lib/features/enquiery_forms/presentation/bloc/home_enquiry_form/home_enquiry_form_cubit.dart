import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/extensions.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/home_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/home_enquiry_form/home_enquiry_form_state.dart';

class HomeEnquiryFormCubit extends Cubit<HomeEnquiryFormState> {
  HomeEnquiryFormCubit({required this.repository}) : super(ShowNameForm());
  final EnquiryFormRepository repository;

  Future<void> submitForm({required HomeEnquiryFormParams params}) async {
    try {
      emit(HomeFormSubmissionLoading());
      final result = await repository.submitHomeEnquiryForm(params);
      result.fold(
        (error) {
          emit(HomeFormSubmissionError(errorMessage: error));
        },
        (data) {
          emit(HomeFormSubmissionSuccess());
        },
      );
    } catch (e) {
      emit(HomeFormSubmissionError(errorMessage: e.toString()));
    }
  }

  Future<void> validateNameForm({required HomeEnquiryFormParams params}) async {
    if (params.firstName.trim().isEmpty) {
      emit(HomeFormValidationError(errorMessage: 'Enter First Name'));
    } else if (params.lastName.trim().isEmpty) {
      emit(HomeFormValidationError(errorMessage: 'Enter Last Name'));
    } else {
      emit(ShowLocationForm());
    }
  }

  Future<void> validateLocationForm({
    required HomeEnquiryFormParams params,
  }) async {
    if (params.pinCode.trim().length != 6 ||
        int.tryParse(params.pinCode.trim()) == null) {
      emit(HomeFormValidationError(errorMessage: 'Enter Pin Code'));
    } else if (params.location.trim().isEmpty) {
      emit(HomeFormValidationError(errorMessage: 'Enter Location'));
    } else {
      emit(ShowContactForm());
    }
  }

  Future<void> validateContactForm({
    required HomeEnquiryFormParams params,
  }) async {
    if (params.mobileNumber.trim().length != 10 ||
        int.tryParse(params.mobileNumber.trim()) == null) {
      emit(HomeFormValidationError(errorMessage: 'Enter Valid Mobile Number'));
    } else if (!params.email.isValidEmail) {
      emit(HomeFormValidationError(errorMessage: 'Enter Valid Email'));
    } else {
      emit(ShowPreview());
    }
  }

  Future<void> showNameForm() async => emit(ShowNameForm());

  Future<void> showLocationForm() async => emit(ShowLocationForm());

  Future<void> showContactForm() async => emit(ShowContactForm());
}
