import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/dark_fibre_form/dark_fibre_form_state.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/dark_fibre_enquiry_form_params.dart';
import 'package:kfon_subscriber/core/util/extensions.dart';

class DarkFibreFormCubit extends Cubit<DarkFibreFormState> {
  DarkFibreFormCubit() : super(ShowCompanyInfoForm());

  Future<void> submitForm({
    required DarkFibreEnquiryFormParams params,
    required UseCase useCase,
  }) async {
    try {
      emit(SubmitDarkFibreFormLoading());
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(SubmitDarkFibreFormError(errorMessage: error));
        },
        (data) {
          emit(SubmitDarkFibreFormSuccess());
        },
      );
    } catch (e) {
      emit(SubmitDarkFibreFormError(errorMessage: e.toString()));
    }
  }

  Future<void> downloadLetterFormat({
    required String url,
    required UseCase useCase,
  }) async {
    try {
      emit(DarkFibreFormMessage(message: 'Downloading, please wait...',color: Colors.green));
      Either result = await useCase.call(param: url);
      result.fold(
            (error) {
          emit(DarkFibreFormMessage(message: error,color: Colors.red));
        },
            (data) {
              emit(DarkFibreFormMessage(message: 'Success',color: Colors.green));
        },
      );
    } catch (e) {
      emit(DarkFibreFormMessage(message: e.toString(),color: Colors.red));
    }
  }

  Future<void> validateCompanyInfoForm({
    required DarkFibreEnquiryFormParams params,
  }) async {
    if (params.firmName.trim().isEmpty) {
      emit(
        DarkFibreFormMessage(message: 'Enter Name Of The Firm',color: Colors.red),
      );
    } else if (params.firmContactNumber.trim().isEmpty ||
        int.tryParse(params.firmContactNumber.trim()) == null) {
      emit(
        DarkFibreFormMessage(
          message: 'Enter Valid Firm Phone Number',color: Colors.red
        ),
      );
    }
    else if (!params.email.isValidEmail) {
      emit(
        DarkFibreFormMessage(message: 'Enter Valid Firm Email',color: Colors.red),
      );
    } else if (params.contactPersonName.trim().isEmpty) {
      emit(
        DarkFibreFormMessage(message: 'Enter Contact Person Name',color: Colors.red),
      );
    } else if (params.contactPersonPhone.trim().isEmpty ||
        int.tryParse(params.contactPersonPhone.trim()) == null) {
      emit(
        DarkFibreFormMessage(
          message: 'Enter Valid Contact Person Phone Number',color: Colors.red
        ),
      );
    }else if (!params.contactPersonEmail.isValidEmail) {
      emit(
        DarkFibreFormMessage(message: 'Enter Valid Contact Person  Email',color: Colors.red),
      );
    }  else {
      emit(ShowDocumentCollectionForm());
    }
  }

  Future<void> validateDocumentCollectionForm({
    required DarkFibreEnquiryFormParams params,
  }) async {
  if (params.internetServiceLicenseFiles.isEmpty) {
      emit(
        DarkFibreFormMessage(
            message: 'Upload Internet Service License',color: Colors.red
        ),
      );
    } else {
      emit(ShowPreview());
    }
  }

  Future<void> showCompanyInfoForm() async => emit(ShowCompanyInfoForm());

  Future<void> showDocumentCollectionForm() async => emit(ShowDocumentCollectionForm());


}
