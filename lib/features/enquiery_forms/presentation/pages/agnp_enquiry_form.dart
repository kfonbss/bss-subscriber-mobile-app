import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/agnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/agnp_form/agnp_form_cubit.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/agnp_form/agnp_form_state.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiery_form_footer.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiry_form_header.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiry_form_preview.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/pages/lnp_enquiry_form.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_text_area.dart';
import 'package:kfon_subscriber/shared/widgets/form_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';

import '../../../../core/constant/constant_colors.dart';
import '../../../../shared/widgets/common_text_field.dart';

class AGNPEnquiryForm extends StatefulWidget {
  const AGNPEnquiryForm({super.key});

  @override
  State<AGNPEnquiryForm> createState() => _AGNPEnquiryFormState();
}

class _AGNPEnquiryFormState extends State<AGNPEnquiryForm> {
  final AGNPFormCubit _agnpFormCubit = AGNPFormCubit(
    repository: sl<EnquiryFormRepository>(),
  );
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
  static const _radioButtonTextStyle = TextStyle(
    color: AppColor.kRadioButtonTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  final DialogUtil _dialogUtil = DialogUtil();
  static const int _pageCount = 3;

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
    alternativeMobileNumber:
    _alternativeMobileNumberTextFieldController.text,
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
    final l10n = context.bssSubL10n;

    return BlocConsumer<AGNPFormCubit, AGNPFormState>(
      bloc: _agnpFormCubit,
      listenWhen: (previousState, currentState) =>
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
          current is ShowGeographicInformationForm ||
          current is ShowPreview,
      builder: (context, state) {
        return FormAppBar(
          showBackButton: false,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              EnquiryFormHeader(
                heading: l10n.agnpEnquiry,
                pageCount: _pageCount,
                currentPage: state is ShowPreview
                    ? _pageCount
                    : state is ShowCompanyInformationForm
                    ? _pageCount - 2
                    : _pageCount - 1,
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
                          map: params.geoGraphicInfoToMap(),
                          heading: l10n.geographicInformation,
                        ),
                      ],
                    )
                        : state is ShowGeographicInformationForm
                        ? Column(
                      spacing: 30,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.geographicInformationStep,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kBlackHeadingColor,
                          ),
                        ),
                        CommonTextField(
                          label: l10n.agnpLocationLatitude,
                          hintText: l10n.enterAgnpLocationLatitude,
                          textInputType: TextInputType.number,
                          textEditingController:
                          _latitudeTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.agnpLocationLongitude,
                          hintText: l10n.enterAgnpLocationLongitude,
                          textInputType: TextInputType.number,
                          textEditingController:
                          _longitudeTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.agnpPincode,
                          hintText: l10n.enterAgnpPincode,
                          textEditingController:
                          _pinCodeTextFieldController,
                          maxLength: 6,
                          textInputType: TextInputType.number,
                          onTextChanged: (pinCode) {
                            if (pinCode.length == 6) {}
                          },
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
                          label: l10n.agnpName,
                          hintText: l10n.enterAgnpName,
                          textEditingController:
                          _agnpNameTextFieldController,
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
                        CommonTextField(
                          label: l10n.agnpContactName,
                          hintText: l10n.enterAgnpContactName,
                          textEditingController:
                          _agnpContactNameTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.agnpMobileNumber,
                          hintText: l10n.enterAgnpMobileNumber,
                          textInputType: TextInputType.number,
                          maxLength: 10,
                          textEditingController:
                          _mobileNumberTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.agnpAlternativeMobileNumber,
                          hintText:
                          l10n.enterAgnpAlternativeMobileNumber,
                          textInputType: TextInputType.phone,
                          maxLength: 10,
                          textEditingController:
                          _alternativeMobileNumberTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.landlineNumber,
                          hintText: l10n.enterLandlineNumber,
                          textInputType: TextInputType.phone,
                          textEditingController:
                          _landlineNumberTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.agnpEmail,
                          hintText: l10n.enterAgnpEmail,
                          textInputType: TextInputType.emailAddress,
                          textEditingController:
                          _emailTextFieldController,
                        ),
                        CommonTextArea(
                          label: l10n.agnpFullAddress,
                          hintText: l10n.enterAgnpFullAddress,
                          textEditingController:
                          _addressTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.agnpLocation,
                          hintText: l10n.enterAgnpLocation,
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
                buildWhen: (previous, current) =>
                current is SubmitAGNPFormLoading ||
                    current is SubmitAGNPFormError ||
                    current is SubmitAGNPFormSuccess,
                builder: (context, buttonState) => EnquiryFormFooter(
                  pageCount: _pageCount,
                  currentPage: state is ShowPreview
                      ? _pageCount
                      : state is ShowCompanyInformationForm
                      ? _pageCount - 2
                      : _pageCount - 1,
                  primaryButtonCallback: () => state is ShowPreview
                      ? _agnpFormCubit.submitForm(params: params)
                      : state is ShowCompanyInformationForm
                      ? _agnpFormCubit.validateCompanyForm(params: params)
                      : _agnpFormCubit.validateGeographicForm(
                    params: params,
                  ),
                  secondaryButtonCallback: () => state is ShowPreview
                      ? _agnpFormCubit.showGeographicInformationForm()
                      : _agnpFormCubit.showCompanyInformationForm(),
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
