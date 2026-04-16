import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/dark_fibre_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/dark_fibre_form/dark_fibre_form_cubit.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/dark_fibre_form/dark_fibre_form_state.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiery_form_footer.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiry_form_header.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiry_form_preview.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_file_uploader.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_area.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_button.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/form_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';

class DarkFibreEnquiryForm extends StatefulWidget {
  const DarkFibreEnquiryForm({super.key});

  @override
  State<DarkFibreEnquiryForm> createState() => _DarkFibreEnquiryFormState();
}

class _DarkFibreEnquiryFormState extends State<DarkFibreEnquiryForm> {
  final DarkFibreFormCubit _darkFibreFormCubit = DarkFibreFormCubit(
    repository: sl<EnquiryFormRepository>(),
  );
  final DialogUtil _dialogUtil = DialogUtil();
  static const int _pageCount = 3;
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
    telecomServiceProvidedArea:
    _telecomServiceProvidedTextFieldController.text,
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
    final l10n = context.bssSubL10n;

    return BlocConsumer<DarkFibreFormCubit, DarkFibreFormState>(
      bloc: _darkFibreFormCubit,
      listenWhen: (previousState, currentState) =>
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
          _dialogUtil.showMessage(
            l10n.successMessage,
            context,
            backgroundColor: AppColor.kSuccessGreen,
          );
          Navigator.of(context).pop();
        }
      },
      buildWhen: (previous, current) =>
      current is ShowCompanyInfoForm ||
          current is ShowDocumentCollectionForm ||
          current is ShowPreview,
      builder: (context, state) {
        return FormAppBar(
          showBackButton: false,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              EnquiryFormHeader(
                heading: l10n.darkFibreEnquiry,
                pageCount: _pageCount,
                currentPage: state is ShowPreview
                    ? _pageCount
                    : state is ShowCompanyInfoForm
                    ? _pageCount - 2
                    : _pageCount - 1,
              ),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: state is ShowPreview
                        ? Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.darkFibrePreviewStep,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kBlackHeadingColor,
                          ),
                        ),
                        EnquiryFormPreview(
                          map: params.getCompanyInfoPreview(),
                          heading: l10n.companyInformation,
                        ),
                        EnquiryFormPreview(
                          map: params.getDocumentInfoPreview(),
                          heading: l10n.documentsCollection,
                        ),
                      ],
                    )
                        : state is ShowDocumentCollectionForm
                        ? Column(
                      spacing: 30,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.documentsCollectionStep,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kBlackHeadingColor,
                          ),
                        ),
                        CommonFileUploader(
                          selectedFiles: _internetServiceLicenseFiles,
                          label: l10n.uploadInternetServiceLicense,
                          hintText: l10n.selectFileHere,
                        ),
                        CommonTextField(
                          label: l10n.areaTelecomServiceProvided,
                          hintText:
                          l10n.enterAreaTelecomServiceProvided,
                          textEditingController:
                          _telecomServiceProvidedTextFieldController,
                        ),
                        CommonFileUploader(
                          selectedFiles: _experienceCertificateFiles,
                          label: l10n.uploadExperienceCertificate,
                          hintText: l10n.selectFileHere,
                        ),
                        CommonTextField(
                          label: l10n.behalfLeaseCompany,
                          hintText: l10n.enterBehalfLeaseCompany,
                          textEditingController:
                          _behalfLeaseCompanyTextFieldController,
                        ),
                        Column(
                          spacing: 5,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            CommonFileUploader(
                              selectedFiles: _coveringLetterFiles,
                              label: l10n.uploadCoveringLetter,
                              hintText: l10n.selectFileHere,
                            ),
                            CommonTextButton(
                              label: l10n.downloadCoveringLetterFormat,
                              onPressed: () => _darkFibreFormCubit
                                  .downloadLetterFormat(
                                url:
                                'https://selfcare.kfon.co.in/new-Format-covering%20letter.pdf',
                              ),
                            ),
                          ],
                        ),
                        Column(
                          spacing: 5,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            CommonFileUploader(
                              selectedFiles: _routeLeaseFiles,
                              label: l10n.uploadRouteLeaseCopy,
                              hintText: l10n.selectFileHere,
                            ),
                            CommonTextButton(
                              label: l10n.downloadRouteLeaseFormat,
                              onPressed: () => _darkFibreFormCubit
                                  .downloadLetterFormat(
                                url:
                                'https://selfcare.kfon.co.in/new-Format-route-details.pdf',
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
                          l10n.companyInformationStep,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kBlackHeadingColor,
                          ),
                        ),
                        CommonTextField(
                          label: l10n.nameOfTheFirm,
                          hintText: l10n.enterNameOfTheFirm,
                          textEditingController:
                          _firmNameTextFieldController,
                        ),
                        CommonTextArea(
                          label: l10n.fullAddress,
                          hintText: l10n.enterFullAddress,
                          textEditingController:
                          _addressTextAreaController,
                        ),
                        CommonTextField(
                          label: l10n.firmPhoneNumber,
                          hintText: l10n.enterFirmPhoneNumber,
                          textInputType: TextInputType.number,
                          textEditingController:
                          _firmContactNumberTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.firmEmail,
                          hintText: l10n.enterFirmEmail,
                          textInputType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          textEditingController:
                          _emailTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.contactPersonName,
                          hintText: l10n.enterContactPersonName,
                          textEditingController:
                          _contactPersonNameTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.contactPersonPhoneNumber,
                          hintText:
                          l10n.enterContactPersonPhoneNumber,
                          textInputType: TextInputType.number,
                          textEditingController:
                          _contactPersonPhoneNumberTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.contactPersonEmail,
                          hintText: l10n.enterContactPersonEmail,
                          textInputType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          textEditingController:
                          _contactPersonEmailTextFieldController,
                        ),
                        CommonTextArea(
                          label: l10n.purposeOfLeasing,
                          hintText: l10n.enterPurposeOfLeasing,
                          textEditingController:
                          _leasingPurposeFieldController,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              BlocBuilder<DarkFibreFormCubit, DarkFibreFormState>(
                bloc: _darkFibreFormCubit,
                buildWhen: (previous, current) =>
                current is SubmitDarkFibreFormLoading ||
                    current is SubmitDarkFibreFormError ||
                    current is SubmitDarkFibreFormSuccess,
                builder: (context, buttonState) => EnquiryFormFooter(
                  pageCount: _pageCount,
                  currentPage: state is ShowPreview
                      ? _pageCount
                      : state is ShowCompanyInfoForm
                      ? _pageCount - 2
                      : _pageCount - 1,
                  primaryButtonCallback: () => state is ShowPreview
                      ? _darkFibreFormCubit.submitForm(params: params)
                      : state is ShowCompanyInfoForm
                      ? _darkFibreFormCubit.validateCompanyInfoForm(
                    params: params,
                  )
                      : _darkFibreFormCubit.validateDocumentCollectionForm(
                    params: params,
                  ),
                  secondaryButtonCallback: () =>
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
