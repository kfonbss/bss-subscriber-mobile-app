import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/dark_fibre_form/dark_fibre_form_cubit.dart';
import 'package:kfon_subscriber/common/bloc/dark_fibre_form/dark_fibre_form_state.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/dark_fibre_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usercases/dark_fibre_enquiry_form_submission_user_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usercases/download_letter_format_user_case.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiery_form_footer.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiry_form_header.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiry_form_preview.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_file_uploader.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_area.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_button.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/default_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/util/dialog_util.dart';

class DarkFibreEnquiryForm extends StatefulWidget {
  const DarkFibreEnquiryForm({super.key});

  @override
  State<DarkFibreEnquiryForm> createState() => _DarkFibreEnquiryFormState();
}

class _DarkFibreEnquiryFormState extends State<DarkFibreEnquiryForm> {
  final DarkFibreFormCubit _darkFibreFormCubit = DarkFibreFormCubit();
  final DialogUtil _dialogUtil = DialogUtil();
  final int _pageCount = 3;
  final _firmNameTextFieldController = TextEditingController();
  final _addressTextAreaController = TextEditingController();
  final _firmContactNumberTextFieldController = TextEditingController();
  final _emailTextFieldController = TextEditingController();
  final _contactPersonNameTextFieldController = TextEditingController();
  final _contactPersonPhoneNumberTextFieldController = TextEditingController();
  final _contactPersonEmailTextFieldController = TextEditingController();
  final _leasingPurposeFieldController = TextEditingController();
  final _telecomServiceProvidedTextFieldController = TextEditingController();
  final _behalfLeaseCompanyTextFieldController = TextEditingController();
  final List<PlatformFile> _internetServiceLicenseFiles = [];
  final List<PlatformFile> _experienceCertificateFiles = [];
  final List<PlatformFile> _coveringLetterFiles = [];
  final List<PlatformFile> _routeLeaseFiles = [];

  DarkFibreEnquiryFormParams get params => DarkFibreEnquiryFormParams(
    firmName: _firmNameTextFieldController.text,
    address: _addressTextAreaController.text,
    email: _emailTextFieldController.text,
    firmContactNumber: _firmContactNumberTextFieldController.text,
    contactPersonName: _contactPersonNameTextFieldController.text,
    contactPersonPhone: _contactPersonPhoneNumberTextFieldController.text,
    contactPersonEmail: _contactPersonEmailTextFieldController.text,
    leasingPurpose: _leasingPurposeFieldController.text,
    telecomServiceProvidedArea: _telecomServiceProvidedTextFieldController.text,
    internetServiceLicenseFiles: _internetServiceLicenseFiles,
    experienceCertificateFiles: _experienceCertificateFiles,
    behalfLeaseCompany: _behalfLeaseCompanyTextFieldController.text,
    coveringLetterFiles: _coveringLetterFiles,
    routeLeaseFiles: _routeLeaseFiles,
  );

  @override
  void dispose() {
    _firmNameTextFieldController.dispose();
    _contactPersonNameTextFieldController.dispose();
    _firmContactNumberTextFieldController.dispose();
    _emailTextFieldController.dispose();
    _addressTextAreaController.dispose();
    _contactPersonPhoneNumberTextFieldController.dispose();
    _contactPersonEmailTextFieldController.dispose();
    _leasingPurposeFieldController.dispose();
    _telecomServiceProvidedTextFieldController.dispose();
    _behalfLeaseCompanyTextFieldController.dispose();
    _darkFibreFormCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DarkFibreFormCubit, DarkFibreFormState>(
      bloc: _darkFibreFormCubit,
      listenWhen:
          (previousState, currentState) =>
              currentState is DarkFibreFormMessage ||
              currentState is SubmitDarkFibreFormError ||
              currentState is SubmitDarkFibreFormSuccess,
      listener: (context, state) {
        if (state is DarkFibreFormMessage) {
          _dialogUtil.showMessage(
            state.message,
            context,
            backgroundColor: state.color,
          );
        } else if (state is SubmitDarkFibreFormError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is SubmitDarkFibreFormSuccess) {
          Navigator.of(context).pop();
        }
      },
      buildWhen:
          (previous, current) =>
              current is ShowCompanyInfoForm ||
              current is ShowDocumentCollectionForm ||
              current is ShowPreview,
      builder: (context, state) {
        return DefaultAppBar(
          showBackButton: false,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              EnquiryFormHeader(
                heading: 'Dark Fibre Enquiry',
                pageCount: _pageCount,
                currentPage:  state is ShowPreview
                    ? _pageCount
                    : state is ShowCompanyInfoForm
                    ? _pageCount - 2
                    : _pageCount - 1,
              ),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    reverse: false,
                    padding: const EdgeInsets.all(20),
                    child:
                        state is ShowPreview
                            ? Column(
                              spacing: 20,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  '2. Preview',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.kBlackHeadingColor,
                                  ),
                                ),
                                EnquiryFormPreview(
                                  map: params.getCompanyInfoPreview(),
                                  heading: 'Company Information',
                                ),
                                EnquiryFormPreview(
                                  map: params.getDocumentInfoPreview(),
                                  heading: 'Documents Collection',
                                ),
                              ],
                            )
                            : state is ShowDocumentCollectionForm
                            ? Column(
                              spacing: 30,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '2. Documents Collection',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.kBlackHeadingColor,
                                  ),
                                ),
                                CommonFileUploader(
                                  selectedFiles: _internetServiceLicenseFiles,
                                  label: 'Upload Internet Service License *',
                                  hintText: 'Select File here',
                                ),
                                CommonTextField(
                                  label:
                                      'Area/Circle where Telecom service is provided',
                                  hintText:
                                      'Enter Area/Circle where Telecom service is provided',
                                  textEditingController:
                                      _telecomServiceProvidedTextFieldController,
                                ),
                                CommonFileUploader(
                                  selectedFiles: _experienceCertificateFiles,
                                  label:
                                      'Upload Certificate in support of Experience',
                                  hintText: 'Select File here',
                                ),
                                CommonTextField(
                                  label: 'For and on behalf Lease Company M/S',
                                  hintText:
                                      'Enter - For and on behalf Lease Company M/S',
                                  textEditingController:
                                      _behalfLeaseCompanyTextFieldController,
                                ),
                                Column(
                                  spacing: 5,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CommonFileUploader(
                                      selectedFiles: _coveringLetterFiles,
                                      label: 'Upload Covering Letter',
                                      hintText: 'Select File here',
                                    ),
                                    CommonTextButton(
                                      label: 'Download Covering Letter Format',
                                      onPressed:
                                          () => _darkFibreFormCubit
                                              .downloadLetterFormat(
                                                url:
                                                    'https://selfcare.kfon.co.in/new-Format-covering%20letter.pdf',
                                                useCase:
                                                    sl<
                                                      DownloadLetterFormatUserCase
                                                    >(),
                                              ),
                                    ),
                                  ],
                                ),
                                Column(
                                  spacing: 5,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CommonFileUploader(
                                      selectedFiles: _routeLeaseFiles,
                                      label:
                                          'Upload Details Of the RouteLease copy',
                                      hintText: 'Select File here',
                                    ),
                                    CommonTextButton(
                                      label: 'Download Route Lease Format',
                                      onPressed:
                                          () => _darkFibreFormCubit
                                              .downloadLetterFormat(
                                                url:
                                                    'https://selfcare.kfon.co.in/new-Format-route-details.pdf',
                                                useCase:
                                                    sl<
                                                      DownloadLetterFormatUserCase
                                                    >(),
                                              ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                            : Column(
                              spacing: 30,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '1. Company Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.kBlackHeadingColor,
                                  ),
                                ),
                                CommonTextField(
                                  label: 'Name Of The Firm*',
                                  hintText: 'Enter Name Of The Firm',
                                  textEditingController:
                                      _firmNameTextFieldController,
                                ),
                                CommonTextArea(
                                  label: 'Full Address',
                                  hintText: 'Enter Full Address',
                                  textEditingController:
                                      _addressTextAreaController,
                                ),
                                CommonTextField(
                                  label: 'Firm Phone Number*',
                                  hintText: 'Enter Firm Phone Number',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _firmContactNumberTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Firm Email*',
                                  hintText: 'Enter Firm Email',
                                  textInputType: TextInputType.emailAddress,
                                  textCapitalization: TextCapitalization.none,
                                  textEditingController:
                                      _emailTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Contact Person Name*',
                                  hintText: 'Enter Contact Person Name',
                                  textEditingController:
                                      _contactPersonNameTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Contact Person Phone Number*',
                                  hintText: 'Enter Contact Person Phone Number',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _contactPersonPhoneNumberTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Contact Person Email*',
                                  hintText: 'Enter Contact Person Email',
                                  textInputType: TextInputType.emailAddress,
                                  textCapitalization: TextCapitalization.none,
                                  textEditingController:
                                      _contactPersonEmailTextFieldController,
                                ),
                                CommonTextArea(
                                  label: 'Purpose Of Leasing',
                                  hintText: 'Enter Purpose Of Leasing',
                                  textEditingController:
                                      _leasingPurposeFieldController,
                                )
                              ],
                            ),
                  ),
                ),
              ),
              BlocBuilder<DarkFibreFormCubit, DarkFibreFormState>(
                bloc: _darkFibreFormCubit,
                buildWhen:
                    (previous, current) =>
                        current is SubmitDarkFibreFormLoading ||
                        current is SubmitDarkFibreFormError ||
                        current is SubmitDarkFibreFormSuccess,
                builder:
                    (context, buttonState) => EnquiryFormFooter(
                      pageCount: _pageCount,
                      currentPage:
                      state is ShowPreview
                          ? _pageCount
                          : state is ShowCompanyInfoForm
                          ? _pageCount - 2
                          : _pageCount - 1,
                      primaryButtonCallback:
                          () =>
                              state is ShowPreview
                                  ? _darkFibreFormCubit.submitForm(
                                    useCase:
                                        sl<
                                          DarkFibreEnquiryFormSubmissionUserCase
                                        >(),
                                    params: params,
                                  )
                                  : state is ShowCompanyInfoForm
                                  ? _darkFibreFormCubit.validateCompanyInfoForm(
                                    params: params,
                                  )
                                  : _darkFibreFormCubit
                                      .validateDocumentCollectionForm(
                                        params: params,
                                      ),
                      secondaryButtonCallback:
                          () =>
                          state is ShowDocumentCollectionForm
                              ? _darkFibreFormCubit.showCompanyInfoForm()
                              : _darkFibreFormCubit.showDocumentCollectionForm(),
                      showLoading: buttonState is SubmitDarkFibreFormLoading,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
