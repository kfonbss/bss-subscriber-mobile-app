import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/bpl_form/bpl_enquiry_form_state.dart';
import 'package:kfon_subscriber/core/usercase/usecase.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/bpl_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/post_office_district_response.dart';

class BplEnquiryFormCubit extends Cubit<BplEnquiryFormState> {
  BplEnquiryFormCubit() : super(ShowPersonalInformationForm());

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
    required BplEnquiryFormParams params,
    required UseCase useCase,
  }) async {
    try {
      emit(SubmitBplFormLoading());
      await Future.delayed(const Duration(seconds: 3));
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(SubmitBplFormError(errorMessage: error));
        },
        (data) {
          emit(SubmitBplFormSuccess());
        },
      );
    } catch (e) {
      emit(SubmitBplFormError(errorMessage: e.toString()));
    }
  }

  void validatePersonalForm(BplEnquiryFormParams param) {
    if (param.rationCardHolderName.trim().isEmpty) {
      emit(
        BplFormValidationError(errorMessage: "Enter Ration Card Holder's Name"),
      );
    } else if (param.rationCardHolderMob.length != 10 ||
        int.tryParse(param.rationCardHolderMob.trim()) == null) {
      emit(
        BplFormValidationError(
          errorMessage:
              'Enter Valid Aadhar Linked Mobile Number Of The Ration card holder',
        ),
      );
    } else if (param.ksebConsumerNo.trim().isEmpty) {
      emit(BplFormValidationError(errorMessage: 'Enter KSEB Consumer No'));
    } else if (param.aadharCardNumber.trim().isEmpty ||
        int.tryParse(param.aadharCardNumber.trim()) == null) {
      emit(
        BplFormValidationError(
          errorMessage: 'Enter Valid Aadhar number of the ration card holder',
        ),
      );
    } else if (param.address.trim().isEmpty) {
      emit(BplFormValidationError(errorMessage: 'Enter Installation Address'));
    } else {
      emit(ShowAddressInformationForm());
    }
  }

  void validateAddressForm(BplEnquiryFormParams param, bool declarationStatus) {
    if (param.pinCode.trim().isEmpty ||
        int.tryParse(param.pinCode.trim()) == null) {
      emit(BplFormValidationError(errorMessage: 'Enter Pin Code'));
    } else if (param.postOffice.trim().isEmpty) {
      emit(BplFormValidationError(errorMessage: 'Select Post Office'));
    } else if (param.district.trim().isEmpty) {
      emit(BplFormValidationError(errorMessage: 'Select District'));
    } else if (!declarationStatus) {
      emit(BplFormValidationError(errorMessage: 'Please Accept Declaration'));
    } else {
      emit(ShowPreview());
    }
  }

  Future<void> showAddressInformationForm() async =>
      emit(ShowAddressInformationForm());

  Future<void> showPersonalCompanyForm() async =>
      emit(ShowPersonalInformationForm());
}
