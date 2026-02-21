import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/lnp_enquiry_form/lnp_enquiry_form_cubit.dart';
import 'package:kfon_subscriber/common/bloc/lnp_enquiry_form/lnp_enquiry_form_state.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/lnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/lnp_enquiry_form_use_case.dart';

import 'package:kfon_subscriber/presentation/page_component/enquiery_form_footer.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiry_form_header.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiry_form_preview.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_drop_down.dart';

import 'package:kfon_subscriber/presentation/ui_component/common_file_uploader.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_area.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/form_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';

enum SIPStatus { yes, no }

class LNPEnquiryForm extends StatefulWidget {
  const LNPEnquiryForm({super.key});

  @override
  State<LNPEnquiryForm> createState() => _LNPEnquiryFormState();
}

class _LNPEnquiryFormState extends State<LNPEnquiryForm> {
  final LnpEnquiryFormCubit _enquiryFormCubit = LnpEnquiryFormCubit();
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
  final _totalCableTvSubscriberCountTextFieldController =TextEditingController();
  final _totalInternetSubscriberCountTextFieldController =TextEditingController();
  final _totalFiberCountTextFieldController = TextEditingController();
  final _postOfficeTextFieldController = TextEditingController();
  final _districtTextFieldController = TextEditingController();
  final _createdByTextFieldController = TextEditingController();
  final ValueNotifier<SIPStatus> _ispValueNotifier = ValueNotifier<SIPStatus>(SIPStatus.no);
  final _radioButtonTextStyle = TextStyle(
    color: AppColor.kRadioButtonTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  final int _pageCount = 3;
  final List<String> _createdByItems = ['BDE', 'BDM', 'LNP'];
  final List<PlatformFile> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
  }

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LnpEnquiryFormCubit, LnpEnquiryFormState>(
      bloc: _enquiryFormCubit,
      listenWhen:
          (previousState, currentState) =>
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
          _dialogUtil.showMessage('Success', context,backgroundColor: Colors.green);
          Navigator.of(context).pop();
        }
      },
      buildWhen:
          (previous, current) =>
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
                heading: 'Local Connectivity Network Partner Enquiry',
                pageCount: _pageCount,
                currentPage:
                    state is ShowPreview
                        ? _pageCount
                        : state is ShowCompanyInformationForm
                        ? _pageCount - 2
                        : _pageCount - 3,
              ),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    reverse: state is ShowPreview ? true : false,
                    padding: const EdgeInsets.all(20),
                    child:
                        state is ShowPreview
                            ? Column(
                              spacing: 20,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  '3. Preview',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.kBlackHeadingColor,
                                  ),
                                ),
                                EnquiryFormPreview(
                                  map: params.companyInfoToMap(),
                                  heading: 'Company Information',
                                ),
                                EnquiryFormPreview(
                                  map: params.personalInfoToMap(),
                                  heading: 'Personal Information',
                                )
                              ],
                            )
                            : state is ShowPersonalInformationForm
                            ? Column(
                              spacing: 30,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '2. Personal Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.kBlackHeadingColor,
                                  ),
                                ),
                                CommonTextField(
                                  label: 'Partner Mobile Number*',
                                  hintText: 'Enter Mobile Number',
                                  textInputType: TextInputType.number,
                                  maxLength: 10,
                                  textEditingController:
                                      _mobileNumberTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Landline Number',
                                  hintText: 'Enter Landline Number',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _landlineNumberTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Partner Email*',
                                  hintText: 'Enter Partner Email',
                                  textInputType: TextInputType.emailAddress,
                                  textCapitalization: TextCapitalization.none,
                                  textEditingController:
                                      _emailTextFieldController,
                                ),
                                CommonTextArea(
                                  label: 'Partner Full Address*',
                                  hintText: 'Enter Partner Full Address',
                                  textEditingController:
                                      _addressTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Partner Location',
                                  hintText: 'Enter Partner Location',
                                  textEditingController:
                                      _locationTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Partner Location Latitude',
                                  hintText: 'Enter Partner Location Latitude',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _latitudeTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Partner Location Longitude',
                                  hintText: 'Enter Partner Location Longitude',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _longitudeTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Partner Pincode*',
                                  hintText: 'Enter Partner Pincode',
                                  maxLength: 6,
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _pinCodeTextFieldController,
                                ),
                                CommonFileUploader(
                                  selectedFiles: _selectedFiles,
                                  label: 'Upload CableTV Registration License*',
                                  hintText: 'Select File here'
                                ),
                                CommonTextField(
                                  label:
                                      'Total No of existing CableTV Subscriber*',
                                  hintText:
                                      'Enter Total No of existing CableTV Subscriber',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _totalCableTvSubscriberCountTextFieldController,
                                ),
                                CommonTextField(
                                  label:
                                      'Total No of existing Internet Subscriber*',
                                  hintText:
                                      'Enter Total No of existing Internet Subscribe',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _totalInternetSubscriberCountTextFieldController,
                                ),
                                CommonTextField(
                                  label:
                                      'Total quantity of Fibre Available (in KM)*',
                                  hintText:
                                      'Enter Total quantity of Fibre Available (in KM)',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _totalFiberCountTextFieldController,
                                ),
                                CommonDropDown(
                                  textEditingController:
                                      _createdByTextFieldController,
                                  items: _createdByItems,
                                  label: 'Created By*',
                                  hintText: 'Choose Created By',
                                  onSelected: (item) {},
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
                                  label: 'Partner Company Name*',
                                  hintText: 'Enter Partner Company Name',
                                  textEditingController:
                                      _companyNameTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Partner Contact Name*',
                                  hintText: 'Enter Partner Contact Name',
                                  textEditingController:
                                      _partnerNameTextFieldController,
                                ),
                                Column(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Currently associated with any other ISP?',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColor.kBlackHeadingColor,
                                      ),
                                    ),
                                    ValueListenableBuilder<SIPStatus>(
                                      valueListenable: _ispValueNotifier,
                                      builder: (context, value, child) {
                                        return SizedBox(
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
                                                  visualDensity: VisualDensity(
                                                    horizontal: 0,
                                                    vertical: -4,
                                                  ),
                                                  title: Text(
                                                    'Yes',
                                                    style:
                                                        _radioButtonTextStyle,
                                                  ),
                                                  leading: Radio<SIPStatus>(
                                                    activeColor: AppColor.kPrimaryColor,
                                                    value: SIPStatus.yes,
                                                    groupValue: value,
                                                    onChanged:
                                                        (
                                                          SIPStatus?
                                                          selectedValue,
                                                        ) =>
                                                            _ispValueNotifier
                                                                    .value =
                                                                selectedValue!,
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
                                                  visualDensity: VisualDensity(
                                                    horizontal: 0,
                                                    vertical: -4,
                                                  ),
                                                  title: Text(
                                                    'No',
                                                    style:
                                                        _radioButtonTextStyle,
                                                  ),
                                                  leading: Radio<SIPStatus>(
                                                    activeColor: AppColor.kPrimaryColor,
                                                    value: SIPStatus.no,
                                                    groupValue: value,
                                                    onChanged:
                                                        (
                                                          SIPStatus?
                                                          selectedValue,
                                                        ) =>
                                                            _ispValueNotifier
                                                                    .value =
                                                                selectedValue!,
                                                  ),
                                                ),
                                              ),
                                            ],
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
                buildWhen:
                    (previous, current) =>
                        current is SubmitLnpFormLoading ||
                        current is SubmitLnpFormError ||
                        current is SubmitLnpFormSuccess,
                builder: (context, buttonState) {
                  return EnquiryFormFooter(
                    pageCount: _pageCount,
                    currentPage:
                        state is ShowPreview
                            ? _pageCount
                            : state is ShowCompanyInformationForm
                            ? _pageCount - 2
                            : _pageCount - 1,
                    primaryButtonCallback:
                        () =>
                            state is ShowPreview
                                ? _enquiryFormCubit.submitForm(
                                  useCase:
                                      sl<LnpEnquiryFormUseCase>(),
                                  params: params,
                                )
                                : state is ShowCompanyInformationForm
                                ? _enquiryFormCubit.validateCompanyForm(params)
                                : _enquiryFormCubit.validatePersonalForm(
                                  params,
                                ),
                    secondaryButtonCallback:
                        () =>
                            state is ShowPreview
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
