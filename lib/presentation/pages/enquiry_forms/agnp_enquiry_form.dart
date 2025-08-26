import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/agnp_form/agnp_form_cubit.dart';
import 'package:kfon_subscriber/common/bloc/agnp_form/agnp_form_state.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/agnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usercases/agnp_enquiry_form_submission_user_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usercases/post_office_district_user_case.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiery_form_footer.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiry_form_header.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiry_form_preview.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/lnp_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_drop_down.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_area.dart';
import 'package:kfon_subscriber/presentation/ui_component/default_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/util/dialog_util.dart';

import '../../../core/constant/constant_colors.dart';
import '../../ui_component/common_text_field.dart';

class AGNPEnquiryForm extends StatefulWidget {
  const AGNPEnquiryForm({super.key});

  @override
  State<AGNPEnquiryForm> createState() => _AGNPEnquiryFormState();
}

class _AGNPEnquiryFormState extends State<AGNPEnquiryForm> {
  final AGNPFormCubit _agnpFormCubit = AGNPFormCubit();
  final _agnpNameTextFieldController = TextEditingController();
  final _agnpContactNameTextFieldController = TextEditingController();
  final _mobileNumberTextFieldController = TextEditingController();
  final _alternativeMobileNumberTextFieldController = TextEditingController();
  final _landlineNumberTextFieldController = TextEditingController();
  final _emailTextFieldController = TextEditingController();
  final _addressTextFieldController = TextEditingController();
  final _locationTextFieldController = TextEditingController();
  final _latitudeTextFieldController = TextEditingController();
  final _longitudeTextFieldController = TextEditingController();
  final _pinCodeTextFieldController = TextEditingController();
  final TextEditingController _postOfficeTextFieldController =
      TextEditingController();
  final TextEditingController _districtTextFieldController =
      TextEditingController();
  final ValueNotifier<SIPStatus> _ispValueNotifier = ValueNotifier<SIPStatus>(
    SIPStatus.no,
  );
  final _radioButtonTextStyle = TextStyle(
    color: AppColor.kRadioButtonTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  final DialogUtil _dialogUtil = DialogUtil();
  final int _pageCount = 3;

  AGNPEnquiryFormParams get params => AGNPEnquiryFormParams(
    contactName: _agnpContactNameTextFieldController.text,
    district: _districtTextFieldController.text,
    ispValue: _ispValueNotifier.value,
    postOffice: _postOfficeTextFieldController.text,
    pinCode: _pinCodeTextFieldController.text,
    longitude: _longitudeTextFieldController.text,
    latitude: _latitudeTextFieldController.text,
    location: _locationTextFieldController.text,
    address: _addressTextFieldController.text,
    email: _emailTextFieldController.text,
    landlineNumber: _landlineNumberTextFieldController.text,
    mobileNumber: _mobileNumberTextFieldController.text,
    name: _agnpNameTextFieldController.text,
    alternativeMobileNumber: _alternativeMobileNumberTextFieldController.text,
  );

  @override
  void dispose() {
    _agnpNameTextFieldController.dispose();
    _agnpContactNameTextFieldController.dispose();
    _mobileNumberTextFieldController.dispose();
    _alternativeMobileNumberTextFieldController.dispose();
    _landlineNumberTextFieldController.dispose();
    _emailTextFieldController.dispose();
    _addressTextFieldController.dispose();
    _locationTextFieldController.dispose();
    _latitudeTextFieldController.dispose();
    _longitudeTextFieldController.dispose();
    _pinCodeTextFieldController.dispose();
    _postOfficeTextFieldController.dispose();
    _districtTextFieldController.dispose();
    _ispValueNotifier.dispose();
    _agnpFormCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AGNPFormCubit, AGNPFormState>(
      bloc: _agnpFormCubit,
      listenWhen:
          (previousState, currentState) =>
              currentState is GetPostOfficesDistrictError ||
              currentState is SubscriptionFormValidationError ||
              currentState is SubmitAGNPFormError ||
              currentState is GetPostOfficesDistrictLoading ||
              currentState is SubmitAGNPFormSuccess,
      listener: (context, state) {
        if (state is GetPostOfficesDistrictError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is SubscriptionFormValidationError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is SubmitAGNPFormError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is GetPostOfficesDistrictLoading) {
          _districtTextFieldController.clear();
          _postOfficeTextFieldController.clear();
        } else if (state is SubmitAGNPFormSuccess) {
          Navigator.of(context).pop();
        }
      },
      buildWhen:
          (previous, current) =>
              current is ShowCompanyInformationForm ||
              current is ShowGeographicInformationForm ||
              current is ShowPreview,
      builder: (context, state) {
        return DefaultAppBar(
          showBackButton: false,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              EnquiryFormHeader(
                heading: 'AGNP Enquiry',
                pageCount: _pageCount,
                currentPage:
                    state is ShowPreview
                        ? _pageCount
                        : state is ShowCompanyInformationForm
                        ? _pageCount - 2
                        : _pageCount - 1,
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
                                  map: params.geoGraphicInfoToMap(),
                                  heading: 'Geographic Information',
                                ),
                              ],
                            )
                            : state is ShowGeographicInformationForm
                            ? Column(
                              spacing: 30,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '2. Geographic Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.kBlackHeadingColor,
                                  ),
                                ),
                                CommonTextField(
                                  label: 'AGNP Location Latitude',
                                  hintText: 'Enter AGNP Location Latitude',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _latitudeTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'AGNP Location Longitude',
                                  hintText: 'Enter AGNP Location Longitude',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _longitudeTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'AGNP Pincode*',
                                  hintText: 'Enter AGNP Pincode',
                                  textEditingController:
                                      _pinCodeTextFieldController,
                                  maxLength: 6,
                                  textInputType: TextInputType.number,
                                  onTextChanged: (pinCode) {
                                    if (pinCode.length == 6) {
                                      _agnpFormCubit.getPostOfficeDistrict(
                                        useCase:
                                            sl<PostOfficeDistrictsUserCase>(),
                                        pinCode: pinCode,
                                      );
                                    }
                                  },
                                ),
                                BlocBuilder<AGNPFormCubit, AGNPFormState>(
                                  bloc: _agnpFormCubit,
                                  buildWhen:
                                      (previousState, state) =>
                                          state
                                              is GetPostOfficesDistrictLoading ||
                                          state
                                              is GetPostOfficesDistrictSuccess ||
                                          state is GetPostOfficesDistrictError,

                                  builder:
                                      (context, state) => CommonDropDown(
                                        textEditingController:
                                            _postOfficeTextFieldController,
                                        items:
                                            state is GetPostOfficesDistrictSuccess
                                                ? state.response.postOffices!
                                                : state
                                                    is GetPostOfficesDistrictLoading
                                                ? null
                                                : [],
                                        label: 'PostOffice*',
                                        hintText: 'Choose PostOffice',
                                        onSelected: (item) {},
                                      ),
                                ),
                                BlocBuilder<AGNPFormCubit, AGNPFormState>(
                                  bloc: _agnpFormCubit,
                                  buildWhen:
                                      (previousState, state) =>
                                          state
                                              is GetPostOfficesDistrictLoading ||
                                          state
                                              is GetPostOfficesDistrictSuccess ||
                                          state is GetPostOfficesDistrictError,

                                  builder:
                                      (context, state) => CommonDropDown(
                                        textEditingController:
                                            _districtTextFieldController,
                                        items:
                                            state is GetPostOfficesDistrictSuccess
                                                ? state.response.district!
                                                : state
                                                    is GetPostOfficesDistrictLoading
                                                ? null
                                                : [],
                                        label: 'District*',
                                        hintText: 'Choose District',
                                        onSelected: (item) {},
                                      ),
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
                                  label: 'AGNP Name*',
                                  hintText: 'Enter AGNP Name',
                                  textEditingController:
                                      _agnpNameTextFieldController,
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
                                                    activeColor:
                                                        AppColor.kPrimaryColor,
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
                                                    activeColor:
                                                        AppColor.kPrimaryColor,
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
                                CommonTextField(
                                  label: 'AGNP Contact Name*',
                                  hintText: 'Enter AGNP Contact Name',
                                  textEditingController:
                                      _agnpContactNameTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'AGNP Mobile Number*',
                                  hintText: 'Enter AGNP Mobile Number',
                                  textInputType: TextInputType.number,
                                  maxLength: 10,
                                  textEditingController:
                                      _mobileNumberTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'AGNP Alternative Mobile Number',
                                  hintText:
                                      'Enter AGNP Alternative Mobile Number',
                                  textInputType: TextInputType.phone,
                                  maxLength: 10,
                                  textEditingController:
                                      _alternativeMobileNumberTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Landline Number',
                                  hintText: 'Enter Landline Number',
                                  textInputType: TextInputType.phone,
                                  textEditingController:
                                      _landlineNumberTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'AGNP Email*',
                                  hintText: 'Enter AGNP Email',
                                  textInputType: TextInputType.emailAddress,
                                  textEditingController:
                                      _emailTextFieldController,
                                ),
                                CommonTextArea(
                                  label: 'AGNP Full Address*',
                                  hintText: 'Enter AGNP Full Address',
                                  textEditingController:
                                      _addressTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'AGNP Location',
                                  hintText: 'Enter AGNP Location',
                                  textEditingController:
                                      _locationTextFieldController,
                                ),
                              ],
                            ),
                  ),
                ),
              ),
              BlocBuilder<AGNPFormCubit, AGNPFormState>(
                bloc: _agnpFormCubit,
                buildWhen:
                    (previous, current) =>
                        current is SubmitAGNPFormLoading ||
                        current is SubmitAGNPFormError ||
                        current is SubmitAGNPFormSuccess,
                builder:
                    (context, buttonState) => EnquiryFormFooter(
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
                                  ? _agnpFormCubit.submitForm(
                                    useCase:
                                        sl<AgnpEnquiryFormSubmissionUserCase>(),
                                    params: params,
                                  )
                                  : state is ShowCompanyInformationForm
                                  ? _agnpFormCubit.validateCompanyForm(
                                    params: params,
                                  )
                                  : _agnpFormCubit.validateGeographicForm(
                                    params: params,
                                  ),
                      secondaryButtonCallback:
                          () =>
                              state is ShowPreview
                                  ? _agnpFormCubit.showGeographicInformationForm()
                                  : _agnpFormCubit
                                      .showCompanyInformationForm(),
                      showLoading: buttonState is SubmitAGNPFormLoading,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
