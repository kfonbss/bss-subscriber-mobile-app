import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/subscription_enquiry_form/subscription_form_state.dart';
import 'package:kfon_subscriber/core/usercase/usecase.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/subscription_enquiry_form_params.dart';

import '../../../data/enquiry_form/model/post_office_district_response.dart';

class SubscriptionFormCubit extends Cubit<SubscriptionFormState> {
  SubscriptionFormCubit() : super(ShowForm());

  Future<void> getPostOfficeDistrict({
    required String pinCode,
    required UseCase useCase,
  }) async {
    try {
      emit(GetPostOfficesDistrictLoading());
      Either result = await useCase.call(param: pinCode);
      result.fold(
        (error) {
          emit(GetPostOfficesDistrictError(errorMessage: error));
        },
        (data) {
          emit(
            GetPostOfficesDistrictSuccess(
              response: PostOfficeDistrictResponse.fromJson(data),
            ),
          );
        },
      );
    } catch (e) {
      emit(GetPostOfficesDistrictError(errorMessage: e.toString()));
    }
  }

  Future<void> submitForm({
    required SubscriptionEnquiryFormParams params,
    required UseCase useCase,
  }) async {
    try {
      emit(SubmitSubscriptionFormLoading());
      await Future.delayed(const Duration(seconds: 3));
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(SubmitSubscriptionFormError(errorMessage: error));
        },
        (data) {
          emit(SubmitSubscriptionFormSuccess());
        },
      );
    } catch (e) {
      emit(SubmitSubscriptionFormError(errorMessage: e.toString()));
    }
  }

  Future<void> validateForm({
    required SubscriptionEnquiryFormParams params,
    required bool declarationStatus,
  }) async {
    if (params.name.trim().isEmpty) {
      emit(SubscriptionFormValidationError(errorMessage: 'Enter Name'));
    } else if (params.mobileNumber.trim().length != 10 || int.tryParse(params.mobileNumber.trim()) == null) {
      emit(
        SubscriptionFormValidationError(
          errorMessage: 'Enter Valid Mobile Number',
        ),
      );
    } else if (params.address.trim().isEmpty) {
      emit(SubscriptionFormValidationError(errorMessage: 'Enter Address'));
    } else if (params.pinCode.trim().isEmpty || int.tryParse(params.pinCode.trim())==null) {
      emit(SubscriptionFormValidationError(errorMessage: 'Enter Pin Code'));
    } else if (params.district.trim().isEmpty) {
      emit(SubscriptionFormValidationError(errorMessage: 'Select District'));
    } else if (params.postOffice.trim().isEmpty) {
      emit(SubscriptionFormValidationError(errorMessage: 'Select Post Office'));
    } else if (!declarationStatus) {
      emit(
        SubscriptionFormValidationError(
          errorMessage: 'Please Accept Declaration',
        ),
      );
    } else {
      emit(ShowPreview());
    }
  }

  Future<void> showForm() async => emit(ShowForm());
}
