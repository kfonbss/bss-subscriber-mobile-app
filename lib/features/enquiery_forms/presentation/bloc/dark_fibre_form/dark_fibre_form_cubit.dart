import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/extensions.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/dark_fibre_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/dark_fibre_form/dark_fibre_form_state.dart';

class DarkFibreFormCubit extends Cubit<DarkFibreFormState> {
  DarkFibreFormCubit({required this.repository}) : super(ShowCompanyInfoForm());
  final EnquiryFormRepository repository;

  Future<void> submitForm({required DarkFibreEnquiryFormParams params}) async {
    try {
      emit(SubmitDarkFibreFormLoading());
      final result = await repository.submitDarkFibreEnquiryForm(params);
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

  Future<void> downloadLetterFormat({required String url}) async {
    try {
      emit(
        DarkFibreFormMessage(
          message: 'Downloading, please wait...',
          color: AppColor.kSuccessGreen,
        ),
      );
      final result = await repository.downloadLetterFormat(url);
      result.fold(
        (error) {
          emit(DarkFibreFormMessage(message: error, color: AppColor.kFailedRed));
        },
        (data) {
          emit(DarkFibreFormMessage(message: 'Success', color: AppColor.kSuccessGreen));
        },
      );
    } catch (e) {
      emit(DarkFibreFormMessage(message: e.toString(), color: AppColor.kFailedRed));
    }
  }

  Future<void> validateCompanyInfoForm({
    required DarkFibreEnquiryFormParams params,
  }) async {
    if (params.firmName.trim().isEmpty) {
      emit(
        DarkFibreFormMessage(
          message: 'Enter Name Of The Firm',
          color: AppColor.kFailedRed,
        ),
      );
    } else if (params.firmContactNumber.trim().isEmpty ||
        int.tryParse(params.firmContactNumber.trim()) == null) {
      emit(
        DarkFibreFormMessage(
          message: 'Enter Valid Firm Phone Number',
          color: AppColor.kFailedRed,
        ),
      );
    } else if (!params.email.isValidEmail) {
      emit(
        DarkFibreFormMessage(
          message: 'Enter Valid Firm Email',
          color: AppColor.kFailedRed,
        ),
      );
    } else if (params.contactPersonName.trim().isEmpty) {
      emit(
        DarkFibreFormMessage(
          message: 'Enter Contact Person Name',
          color: AppColor.kFailedRed,
        ),
      );
    } else if (params.contactPersonPhone.trim().isEmpty ||
        int.tryParse(params.contactPersonPhone.trim()) == null) {
      emit(
        DarkFibreFormMessage(
          message: 'Enter Valid Contact Person Phone Number',
          color: AppColor.kFailedRed,
        ),
      );
    } else if (!params.contactPersonEmail.isValidEmail) {
      emit(
        DarkFibreFormMessage(
          message: 'Enter Valid Contact Person  Email',
          color: AppColor.kFailedRed,
        ),
      );
    } else {
      emit(ShowDocumentCollectionForm());
    }
  }

  Future<void> validateDocumentCollectionForm({
    required DarkFibreEnquiryFormParams params,
  }) async {
    if (params.internetServiceLicenseFiles.isEmpty) {
      emit(
        DarkFibreFormMessage(
          message: 'Upload Internet Service License',
          color: AppColor.kFailedRed,
        ),
      );
    } else {
      emit(ShowPreview());
    }
  }

  Future<void> showCompanyInfoForm() async => emit(ShowCompanyInfoForm());

  Future<void> showDocumentCollectionForm() async =>
      emit(ShowDocumentCollectionForm());
}
