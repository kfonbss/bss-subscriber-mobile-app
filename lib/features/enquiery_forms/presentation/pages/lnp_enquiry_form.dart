import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/lnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/lnp_enquiry_form/lnp_enquiry_form_cubit.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/lnp_enquiry_form/lnp_enquiry_form_state.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiery_form_footer.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiry_form_header.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiry_form_preview.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_drop_down.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_file_uploader.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_area.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/form_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';

enum SIPStatus { yes, no }

class LNPEnquiryForm extends StatefulWidget {
  const LNPEnquiryForm({super.key});

  @override
  State<LNPEnquiryForm> createState() => _LNPEnquiryFormState();
}

class _LNPEnquiryFormState extends State<LNPEnquiryForm> {
  final LnpEnquiryFormCubit _enquiryFormCubit = LnpEnquiryFormCubit(
    repository: sl<EnquiryFormRepository>(),
  );
  final DialogUtil _dialogUtil = DialogUtil();
  final _companyNameTextFieldController = TextEditingController();
  final _partnerNameTextFieldController = TextEditingController();
  final _mobileNumberTextFieldController = TextEditingController();
  final _landlineNumberTextFieldController = TextEditingController();
  final _emailTextFieldController = TextEditingController();
  final _addressTextFieldController = TextEditingController();
  final _locationTextFieldController = TextEditingController();
  final _latitudeTextFieldController = TextEditingController();
  final _longitudeTextFieldController = TextEditingController();
  final _pinCodeTextFieldController = TextEditingController();
  final _totalCableTvSubscriberCountTextFieldController = TextEditingController();
  final _totalInternetSubscriberCountTextFieldController = TextEditingController();
  final _totalFiberCountTextFieldController = TextEditingController();
  final _postOfficeTextFieldController = TextEditingController();
  final _districtTextFieldController = TextEditingController();
  final _createdByTextFieldController = TextEditingController();
  final ValueNotifier<SIPStatus> _ispValueNotifier = ValueNotifier<SIPStatus>(SIPStatus.no);
  static const _radioButtonTextStyle = TextStyle(
    color: AppColor.kRadioButtonTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static const int _pageCount = 3;
  static const List<String> _createdByItems = ['BDE', 'BDM', 'LNP'];
  final List<PlatformFile> _selectedFiles = [];

  LNPEnquiryFormParams get params => LNPEnquiryFormParams(
    companyName: _companyNameTextFieldController.text,
    partnerName: _partnerNameTextFieldController.text,
    ispValue: _ispValueNotifier.value,
    mobileNumber: _mobileNumberTextFieldController.text,
    landlineNumber: _landlineNumberTextFieldController.text,
    email: _emailTextFieldController.text,
    address: _addressTextFieldController.text,
    location: _locationTextFieldController.text,
    latitude: _latitudeTextFieldController.text,
    longitude: _longitudeTextFieldController.text,
    pinCode: _pinCodeTextFieldController.text,
    postOffice: _postOfficeTextFieldController.text,
    district: _districtTextFieldController.text,
    selectedFiles: _selectedFiles,
    totalCableTvSubscriberCount:
    _totalCableTvSubscriberCountTextFieldController.text,
    totalInternetSubscriberCount:
    _totalInternetSubscriberCountTextFieldController.text,
    totalFiberCount: _totalFiberCountTextFieldController.text,
    createdBy: _createdByTextFieldController.text,
  );

  @override
  void dispose() {
    _companyNameTextFieldController.dispose();
    _partnerNameTextFieldController.dispose();
    _mobileNumberTextFieldController.dispose();
    _landlineNumberTextFieldController.dispose();
    _totalCableTvSubscriberCountTextFieldController.dispose();
    _totalInternetSubscriberCountTextFieldController.dispose();
    _totalFiberCountTextFieldController.dispose();
    _emailTextFieldController.dispose();
    _addressTextFieldController.dispose();
    _locationTextFieldController.dispose();
    _latitudeTextFieldController.dispose();
    _longitudeTextFieldController.dispose();
    _pinCodeTextFieldController.dispose();
    _postOfficeTextFieldController.dispose();
    _districtTextFieldController.dispose();
    _createdByTextFieldController.dispose();
    _ispValueNotifier.dispose();
    _enquiryFormCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return BlocConsumer<LnpEnquiryFormCubit, LnpEnquiryFormState>(
      bloc: _enquiryFormCubit,
      listenWhen: (previousState, currentState) =>
      currentState is GetPostOfficesDistrictError ||
          currentState is LnpFormValidationError ||
          currentState is SubmitLnpFormError ||
          currentState is GetPostOfficesDistrictLoading ||
          currentState is SubmitLnpFormSuccess,
      listener: (context, state) {
        if (state is GetPostOfficesDistrictError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is LnpFormValidationError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is SubmitLnpFormError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is GetPostOfficesDistrictLoading) {
          _districtTextFieldController.clear();
          _postOfficeTextFieldController.clear();
        } else if (state is SubmitLnpFormSuccess) {
          _dialogUtil.showMessage(
            l10n.successMessage,
            context,
            backgroundColor: AppColor.kSuccessGreen,
          );
          Navigator.of(context).pop();
        }
      },
      buildWhen: (previous, current) =>
      current is ShowCompanyInformationForm ||
          current is ShowPersonalInformationForm ||
          current is ShowPreview,
      builder: (context, state) {
        return FormAppBar(
          showBackButton: false,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              EnquiryFormHeader(
                heading: l10n.lnpEnquiryHeading,
                pageCount: _pageCount,
                currentPage: state is ShowPreview
                    ? _pageCount
                    : state is ShowCompanyInformationForm
                    ? _pageCount - 2
                    : _pageCount - 3,
              ),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    reverse: state is ShowPreview,
                    padding: const EdgeInsets.all(20),
                    child: state is ShowPreview
                        ? Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.previewStep,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kBlackHeadingColor,
                          ),
                        ),
                        EnquiryFormPreview(
                          map: params.companyInfoToMap(),
                          heading: l10n.companyInformation,
                        ),
                        EnquiryFormPreview(
                          map: params.personalInfoToMap(),
                          heading: l10n.personalInformation,
                        ),
                      ],
                    )
                        : state is ShowPersonalInformationForm
                        ? Column(
                      spacing: 30,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.personalInformationStep,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kBlackHeadingColor,
                          ),
                        ),
                        CommonTextField(
                          label: l10n.partnerMobileNumber,
                          hintText: l10n.enterMobileNumber,
                          textInputType: TextInputType.number,
                          maxLength: 10,
                          textEditingController:
                          _mobileNumberTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.landlineNumber,
                          hintText: l10n.enterLandlineNumber,
                          textInputType: TextInputType.number,
                          textEditingController:
                          _landlineNumberTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.partnerEmail,
                          hintText: l10n.enterPartnerEmail,
                          textInputType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          textEditingController:
                          _emailTextFieldController,
                        ),
                        CommonTextArea(
                          label: l10n.partnerFullAddress,
                          hintText: l10n.enterPartnerFullAddress,
                          textEditingController:
                          _addressTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.partnerLocation,
                          hintText: l10n.enterPartnerLocation,
                          textEditingController:
                          _locationTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.partnerLocationLatitude,
                          hintText: l10n.enterPartnerLocationLatitude,
                          textInputType: TextInputType.number,
                          textEditingController:
                          _latitudeTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.partnerLocationLongitude,
                          hintText:
                          l10n.enterPartnerLocationLongitude,
                          textInputType: TextInputType.number,
                          textEditingController:
                          _longitudeTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.partnerPincode,
                          hintText: l10n.enterPartnerPincode,
                          maxLength: 6,
                          textInputType: TextInputType.number,
                          textEditingController:
                          _pinCodeTextFieldController,
                        ),
                        CommonFileUploader(
                          selectedFiles: _selectedFiles,
                          label: l10n.uploadCableTvRegistrationLicense,
                          hintText: l10n.selectFileHere,
                        ),
                        CommonTextField(
                          label: l10n.totalCableTvSubscriber,
                          hintText: l10n.enterTotalCableTvSubscriber,
                          textInputType: TextInputType.number,
                          textEditingController:
                          _totalCableTvSubscriberCountTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.totalInternetSubscriber,
                          hintText:
                          l10n.enterTotalInternetSubscriber,
                          textInputType: TextInputType.number,
                          textEditingController:
                          _totalInternetSubscriberCountTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.totalFibreAvailable,
                          hintText: l10n.enterTotalFibreAvailable,
                          textInputType: TextInputType.number,
                          textEditingController:
                          _totalFiberCountTextFieldController,
                        ),
                        CommonDropDown(
                          textEditingController:
                          _createdByTextFieldController,
                          items: _createdByItems,
                          label: l10n.createdBy,
                          hintText: l10n.chooseCreatedBy,
                          onSelected: (item) {},
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
                          label: l10n.partnerCompanyName,
                          hintText: l10n.enterPartnerCompanyName,
                          textEditingController:
                          _companyNameTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.partnerContactName,
                          hintText: l10n.enterPartnerContactName,
                          textEditingController:
                          _partnerNameTextFieldController,
                        ),
                        Column(
                          spacing: 10,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.currentlyAssociatedWithISP,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColor.kBlackHeadingColor,
                              ),
                            ),
                            ValueListenableBuilder<SIPStatus>(
                              valueListenable: _ispValueNotifier,
                              builder: (context, value, child) {
                                return RadioGroup<SIPStatus>(
                                  groupValue: value,
                                  onChanged: (SIPStatus? sv) =>
                                      _ispValueNotifier.value = sv!,
                                  child: SizedBox(
                                    width: 150,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: ListTile(
                                            horizontalTitleGap: 0,
                                            contentPadding:
                                            EdgeInsets.zero,
                                            dense: true,
                                            minVerticalPadding: 0,
                                            visualDensity:
                                            const VisualDensity(
                                              horizontal: 0,
                                              vertical: -4,
                                            ),
                                            title: Text(
                                              l10n.yes,
                                              style:
                                              _radioButtonTextStyle,
                                            ),
                                            leading: Radio<SIPStatus>(
                                              activeColor:
                                              AppColor.kPrimaryColor,
                                              value: SIPStatus.yes,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListTile(
                                            horizontalTitleGap: 0,
                                            contentPadding:
                                            EdgeInsets.zero,
                                            dense: true,
                                            minVerticalPadding: 0,
                                            visualDensity:
                                            const VisualDensity(
                                              horizontal: 0,
                                              vertical: -4,
                                            ),
                                            title: Text(
                                              l10n.no,
                                              style:
                                              _radioButtonTextStyle,
                                            ),
                                            leading: Radio<SIPStatus>(
                                              activeColor:
                                              AppColor.kPrimaryColor,
                                              value: SIPStatus.no,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              BlocBuilder<LnpEnquiryFormCubit, LnpEnquiryFormState>(
                bloc: _enquiryFormCubit,
                buildWhen: (previous, current) =>
                current is SubmitLnpFormLoading ||
                    current is SubmitLnpFormError ||
                    current is SubmitLnpFormSuccess,
                builder: (context, buttonState) {
                  return EnquiryFormFooter(
                    pageCount: _pageCount,
                    currentPage: state is ShowPreview
                        ? _pageCount
                        : state is ShowCompanyInformationForm
                        ? _pageCount - 2
                        : _pageCount - 1,
                    primaryButtonCallback: () => state is ShowPreview
                        ? _enquiryFormCubit.submitForm(params: params)
                        : state is ShowCompanyInformationForm
                        ? _enquiryFormCubit.validateCompanyForm(params)
                        : _enquiryFormCubit.validatePersonalForm(params),
                    secondaryButtonCallback: () => state is ShowPreview
                        ? _enquiryFormCubit.showPersonalCompanyForm()
                        : _enquiryFormCubit.showCompanyForm(),
                    showLoading: buttonState is SubmitLnpFormLoading,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
