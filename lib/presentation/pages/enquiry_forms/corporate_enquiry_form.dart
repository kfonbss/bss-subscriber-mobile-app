import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/corporate_form/corporate_form_cubit.dart';
import 'package:kfon_subscriber/common/bloc/corporate_form/corporate_form_state.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/corporate_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usercases/corporate_enquiry_form_submission_user_case.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiery_form_footer.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiry_form_header.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiry_form_preview.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_check_box.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_drop_down.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_area.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/default_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/util/dialog_util.dart';

class CorporateEnquiryForm extends StatefulWidget {
  const CorporateEnquiryForm({super.key});

  @override
  State<CorporateEnquiryForm> createState() => _CorporateEnquiryFormState();
}

class _CorporateEnquiryFormState extends State<CorporateEnquiryForm> {
  final CorporateFormCubit _corporateFormCubit = CorporateFormCubit();
  final DialogUtil _dialogUtil = DialogUtil();
  final int _pageCount = 2;
  final List<String> _companyType = ['Private', 'Government'];
  final _companyNameTextFieldController = TextEditingController();
  final _contactNameTextFieldController = TextEditingController();
  final _contactNumberTextFieldController = TextEditingController();
  final _emailTextFieldController = TextEditingController();
  final _addressTextFieldController = TextEditingController();
  final _companyTypeFieldController = TextEditingController();
  final _latitudeTypeFieldController = TextEditingController();
  final _longitudeTypeFieldController = TextEditingController();
  final List<String> _requiredServices = [];

  CorporateEnquiryFormParams get params => CorporateEnquiryFormParams(
    companyName: _companyNameTextFieldController.text,
    contactPersonName: _contactNameTextFieldController.text,
    contactPersonPhoneNumber: _contactNumberTextFieldController.text,
    email: _emailTextFieldController.text,
    address: _addressTextFieldController.text,
    companyType: _companyTypeFieldController.text,
    latitude: _latitudeTypeFieldController.text,
    longitude: _longitudeTypeFieldController.text,
    requiredServices: _requiredServices,
  );

  @override
  void dispose() {
    _companyNameTextFieldController.dispose();
    _contactNameTextFieldController.dispose();
    _contactNumberTextFieldController.dispose();
    _emailTextFieldController.dispose();
    _addressTextFieldController.dispose();
    _companyTypeFieldController.dispose();
    _latitudeTypeFieldController.dispose();
    _longitudeTypeFieldController.dispose();
    _corporateFormCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CorporateFormCubit, CorporateFormState>(
      bloc: _corporateFormCubit,
      listenWhen:
          (previousState, currentState) =>
              currentState is CorporateFormValidationError ||
              currentState is SubmitCorporateFormError ||
              currentState is SubmitCorporateFormSuccess,
      listener: (context, state) {
        if (state is CorporateFormValidationError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is SubmitCorporateFormError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is SubmitCorporateFormSuccess) {
          Navigator.of(context).pop();
        }
      },
      buildWhen:
          (previous, current) => current is ShowForm || current is ShowPreview,
      builder: (context, state) {
        return DefaultAppBar(
          showBackButton: false,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              EnquiryFormHeader(
                heading: 'Corporate Enquiry',
                pageCount: _pageCount,
                currentPage: state is ShowPreview ? _pageCount : _pageCount - 1,
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
                                  '2. Preview',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.kBlackHeadingColor,
                                  ),
                                ),
                                EnquiryFormPreview(
                                  map: params.getPreview(),
                                  heading: 'Company Information',
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
                                  label: 'Company Name',
                                  hintText: 'Enter Company Name',
                                  textEditingController:
                                      _companyNameTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Contact Name*',
                                  hintText: 'Enter Contact Name',
                                  textEditingController:
                                      _contactNameTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Contact Number*',
                                  hintText: 'Enter Contact Number',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _contactNumberTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Email ID*',
                                  hintText: 'Enter Email ID',
                                  textInputType: TextInputType.emailAddress,
                                  textCapitalization: TextCapitalization.none,
                                  textEditingController:
                                      _emailTextFieldController,
                                ),
                                CommonTextArea(
                                  label: 'Company Location/Address*',
                                  hintText: 'Enter Company Location/Address',
                                  textEditingController:
                                      _addressTextFieldController,
                                ),
                                CommonDropDown(
                                  textEditingController:
                                      _companyTypeFieldController,
                                  items: _companyType,
                                  label: 'Company Type*',
                                  hintText: 'Select Company Type',
                                  onSelected: (item) {},
                                ),
                                Column(
                                  spacing: 6,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Services required*',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColor.kTextFiledLabelColor,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        CommonCheckBox(
                                          initialStatus:
                                              _requiredServices.contains(
                                                    'Internet Leased Line 1: 1',
                                                  )
                                                  ? true
                                                  : false,
                                          title: 'Internet Leased Line 1: 1',
                                          onChanged: (isChecked) {
                                            if (isChecked) {
                                              _requiredServices.add(
                                                'Internet Leased Line 1: 1',
                                              );
                                            } else {
                                              _requiredServices.remove(
                                                'Internet Leased Line 1: 1',
                                              );
                                            }
                                          },
                                        ),
                                        CommonCheckBox(
                                          initialStatus:
                                          _requiredServices.contains(
                                            'Point to Point Services',
                                          )
                                              ? true
                                              : false,
                                          title: 'Point to Point Services',
                                          onChanged: (isChecked) {
                                            if (isChecked) {
                                              _requiredServices.add(
                                                'Point to Point Services',
                                              );
                                            } else {
                                              _requiredServices.remove(
                                                'Point to Point Services',
                                              );
                                            }
                                          },
                                        ),
                                        CommonCheckBox(
                                          initialStatus:
                                          _requiredServices.contains('VPN')
                                              ? true
                                              : false,
                                          title: 'VPN',
                                          onChanged: (isChecked) {
                                            if (isChecked) {
                                              _requiredServices.add('VPN');
                                            } else {
                                              _requiredServices.remove('VPN');
                                            }
                                          },
                                        ),
                                        CommonCheckBox(
                                          initialStatus:
                                          _requiredServices.contains(
                                            'Server Co-Location',
                                          )
                                              ? true
                                              : false,
                                          title: 'Server Co-Location',
                                          onChanged: (isChecked) {
                                            if (isChecked) {
                                              _requiredServices.add(
                                                'Server Co-Location',
                                              );
                                            } else {
                                              _requiredServices.remove(
                                                'Server Co-Location',
                                              );
                                            }
                                          },
                                        ),
                                        CommonCheckBox(
                                          initialStatus:
                                          _requiredServices.contains(
                                            'Other Managed Services',
                                          )
                                              ? true
                                              : false,
                                          title: 'Other Managed Services',
                                          onChanged: (isChecked) {
                                            if (isChecked) {
                                              _requiredServices.add(
                                                'Other Managed Services',
                                              );
                                            } else {
                                              _requiredServices.remove(
                                                'Other Managed Services',
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                CommonTextField(
                                  label: 'Latitude',
                                  hintText: 'Enter Latitude',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _latitudeTypeFieldController,
                                ),
                                CommonTextField(
                                  label: 'Longitude',
                                  hintText: 'Enter Longitude',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _longitudeTypeFieldController,
                                ),
                              ],
                            ),
                  ),
                ),
              ),
              BlocBuilder<CorporateFormCubit, CorporateFormState>(
                bloc: _corporateFormCubit,
                buildWhen:
                    (previous, current) =>
                        current is SubmitCorporateFormLoading ||
                        current is SubmitCorporateFormError ||
                        current is SubmitCorporateFormSuccess,
                builder:
                    (context, buttonState) => EnquiryFormFooter(
                      pageCount: _pageCount,
                      currentPage:
                          state is ShowPreview ? _pageCount : _pageCount - 1,
                      primaryButtonCallback:
                          () =>
                              state is ShowPreview
                                  ? _corporateFormCubit.submitForm(
                                    useCase:
                                        sl<
                                          CorporateEnquiryFormSubmissionUserCase
                                        >(),
                                    params: params,
                                  )
                                  : _corporateFormCubit.validateForm(
                                    params: params,
                                  ),
                      secondaryButtonCallback:
                          () => _corporateFormCubit.showForm(),
                      showLoading: buttonState is SubmitCorporateFormLoading,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
