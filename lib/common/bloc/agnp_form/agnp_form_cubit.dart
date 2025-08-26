import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/agnp_form/agnp_form_state.dart';
import 'package:kfon_subscriber/core/usercase/usecase.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/agnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/util/extensions.dart';

import '../../../data/enquiry_form/model/post_office_district_response.dart';

class AGNPFormCubit extends Cubit<AGNPFormState> {
  AGNPFormCubit() : super(ShowCompanyInformationForm());

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
    required AGNPEnquiryFormParams params,
    required UseCase useCase,
  }) async {
    try {
      emit(SubmitAGNPFormLoading());
      await Future.delayed(const Duration(seconds: 3));
      Either result = await useCase.call(param: params);
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

  Future<void> validateCompanyForm({required AGNPEnquiryFormParams params}) async {
    if (params.name.trim().isEmpty) {
      emit(SubscriptionFormValidationError(errorMessage: 'Enter AGNP Name'));
    } else if (params.contactName.trim().isEmpty
    ) {
      emit(
        SubscriptionFormValidationError(
          errorMessage: 'Enter AGNP Contact Name',
        ),
      );
    }  else if (params.mobileNumber.trim().length != 10 || int.tryParse(params.mobileNumber.trim())==null) {
      emit(
        SubscriptionFormValidationError(
          errorMessage: 'Enter Valid AGNP Mobile Number',
        ),
      );
    } else if (!params.email.isValidEmail) {
      emit(SubscriptionFormValidationError(errorMessage: 'Enter Valid AGNP Email'));
    } else if (params.address.trim().isEmpty) {
      emit(SubscriptionFormValidationError(errorMessage: 'Enter AGNP Full Address'));
    }  else {
      emit(ShowGeographicInformationForm());
    }
  }

  Future<void> validateGeographicForm({required AGNPEnquiryFormParams params}) async {
     if (params.pinCode.trim().isEmpty ||
        int.tryParse(params.pinCode.trim()) == null) {
      emit(SubscriptionFormValidationError(errorMessage: 'Enter AGNP Pin Code'));
    } else if (params.postOffice.trim().isEmpty) {
      emit(SubscriptionFormValidationError(errorMessage: 'Select Post Office'));
    } else if (params.district.trim().isEmpty) {
      emit(SubscriptionFormValidationError(errorMessage: 'Select District'));
    } else {
      emit(ShowPreview());
    }
  }

  Future<void> showCompanyInformationForm() async => emit(ShowCompanyInformationForm());

  Future<void> showGeographicInformationForm() async => emit(ShowGeographicInformationForm());

}
