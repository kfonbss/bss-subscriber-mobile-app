import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/bpl_form/bpl_enquiry_form_cubit.dart';
import 'package:kfon_subscriber/common/bloc/bpl_form/bpl_enquiry_form_state.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/bpl_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/bpl_enquiry_form_use_case.dart';

import 'package:kfon_subscriber/presentation/page_component/enquiery_form_footer.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiry_form_header.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiry_form_preview.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_check_box.dart';

import 'package:kfon_subscriber/presentation/ui_component/common_text_area.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/form_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';

class BPLEnquiryForm extends StatefulWidget {
  const BPLEnquiryForm({super.key});

  @override
  State<BPLEnquiryForm> createState() => _BPLEnquiryFormState();
}

class _BPLEnquiryFormState extends State<BPLEnquiryForm> {
  final BplEnquiryFormCubit _enquiryFormCubit = BplEnquiryFormCubit();
  final DialogUtil _dialogUtil = DialogUtil();
  final _rationCardHolderNameTextFieldController = TextEditingController();
  final _rationCardHolderMobTextFieldController = TextEditingController();
  final _ksebConsumerNoTextFieldController = TextEditingController();
  final _aadharCardNumberTextFieldController = TextEditingController();
  final _addressTextFieldController = TextEditingController();
  final _pinCodeTextFieldController = TextEditingController();
  final _postOfficeTextFieldController = TextEditingController();
  final _districtTextFieldController = TextEditingController();
  final _referralCodeTextFieldController = TextEditingController();
  bool _declarationStatus = false;
  final _pageCount=3;

  @override
  void initState() {
    super.initState();
  }

  BplEnquiryFormParams get params => BplEnquiryFormParams(
    rationCardHolderName: _rationCardHolderNameTextFieldController.text,
    rationCardHolderMob: _rationCardHolderMobTextFieldController.text,
    ksebConsumerNo: _ksebConsumerNoTextFieldController.text,
    aadharCardNumber: _aadharCardNumberTextFieldController.text,
    address: _addressTextFieldController.text,
    pinCode: _pinCodeTextFieldController.text,
    postOffice: _postOfficeTextFieldController.text,
    district: _districtTextFieldController.text,
    referralCode: _referralCodeTextFieldController.text
  );

  @override
  void dispose() {
    _rationCardHolderNameTextFieldController.dispose();
    _rationCardHolderMobTextFieldController.dispose();
    _ksebConsumerNoTextFieldController.dispose();
    _aadharCardNumberTextFieldController.dispose();
    _referralCodeTextFieldController.dispose();
    _addressTextFieldController.dispose();
    _pinCodeTextFieldController.dispose();
    _postOfficeTextFieldController.dispose();
    _districtTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BplEnquiryFormCubit, BplEnquiryFormState>(
      bloc: _enquiryFormCubit,
      listenWhen:
          (previousState, currentState) =>
              currentState is GetPostOfficesDistrictError ||
              currentState is BplFormValidationError ||
              currentState is SubmitBplFormError ||
              currentState is GetPostOfficesDistrictLoading ||
              currentState is SubmitBplFormSuccess,
      listener: (context, state) {
        if (state is GetPostOfficesDistrictError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is BplFormValidationError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is SubmitBplFormError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is GetPostOfficesDistrictLoading) {
          _districtTextFieldController.clear();
          _postOfficeTextFieldController.clear();
        } else if (state is SubmitBplFormSuccess) {
          _dialogUtil.showMessage('Success', context,backgroundColor: Colors.green);
          Navigator.of(context).pop();
        }
      },
      buildWhen:
          (previous, current) =>
              current is ShowAddressInformationForm ||
              current is ShowPersonalInformationForm ||
              current is ShowPreview,
      builder: (context, state) {
        return FormAppBar(
          showBackButton: false,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              EnquiryFormHeader(
                heading: 'BPL Subscription Enquiry',
                pageCount: _pageCount,
                currentPage:
                    state is ShowPreview
                        ? _pageCount
                        : state is ShowPersonalInformationForm
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
                                  map: params.personalInfoToMap(),
                                  heading: 'Personal Information',
                                ),
                                EnquiryFormPreview(
                                  map: params.addressInfoToMap(),
                                  heading: 'Address Information',
                                ),
                              ],
                            )
                            : state is ShowPersonalInformationForm
                            ? Column(
                              spacing: 30,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '1. Personal Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.kBlackHeadingColor,
                                  ),
                                ),
                                CommonTextField(
                                  label: "Ration Card Holder's Name*",
                                  hintText: "Enter Ration Card Holder's Name",
                                  textEditingController:
                                      _rationCardHolderNameTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Aadhar linked mobile number of the ration card holder*',
                                  hintText: 'Enter Mobile Number',
                                  textInputType: TextInputType.number,
                                  maxLength: 10,
                                  textEditingController:
                                      _rationCardHolderMobTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'KSEB Consumer No*',
                                  hintText: 'Enter KSEB Consumer No',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                  _ksebConsumerNoTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Aadhar number of the ration card holder*',
                                  hintText: 'Enter Aadhar number of the ration card holder',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                  _aadharCardNumberTextFieldController,
                                ),
                                CommonTextArea(
                                  label: 'Installation Address*',
                                  hintText: 'Enter Installation Address',
                                  textEditingController:
                                  _addressTextFieldController,
                                ),
                              ],
                            )
                            : Column(
                              spacing: 30,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '2. Address Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.kBlackHeadingColor,
                                  ),
                                ),
                                CommonTextField(
                                  label: 'Pincode*',
                                  hintText: 'Enter Pincode',
                                  maxLength: 6,
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _pinCodeTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Referral Code',
                                  hintText: 'Enter Referral Code',
                                  textEditingController:
                                  _referralCodeTextFieldController,
                                ),
                                CommonCheckBox(
                                  initialStatus: _declarationStatus,
                                  title:
                                  'I hereby give my consent to receive calls, texts, WhatsApp and emails regarding updates, newsletters, and other important information from or on behalf of KFON at the mobile number provided above.',
                                  onChanged:
                                      (isChecked) =>
                                  _declarationStatus = isChecked,
                                ),
                              ],
                            ),
                  ),
                ),
              ),
              BlocBuilder<BplEnquiryFormCubit, BplEnquiryFormState>(
                bloc: _enquiryFormCubit,
                buildWhen:
                    (previous, current) =>
                        current is SubmitBplFormLoading ||
                        current is SubmitBplFormError ||
                        current is SubmitBplFormSuccess,
                builder: (context, buttonState) {
                  return EnquiryFormFooter(
                    pageCount: _pageCount,
                    currentPage:
                        state is ShowPreview
                            ? _pageCount
                            : state is ShowPersonalInformationForm
                            ? _pageCount - 2
                            : _pageCount - 1,
                    primaryButtonCallback:
                        () =>
                            state is ShowPreview
                                ? _enquiryFormCubit.submitForm(
                                  useCase:
                                      sl<BplEnquiryFormUseCase>(),
                                  params: params,
                                )
                                : state is ShowAddressInformationForm
                                ? _enquiryFormCubit.validateAddressForm(params,_declarationStatus)
                                : _enquiryFormCubit.validatePersonalForm(
                                  params,
                                ),
                    secondaryButtonCallback:
                        () =>
                            state is ShowPreview
                                ? _enquiryFormCubit.showAddressInformationForm()
                                : _enquiryFormCubit.showPersonalCompanyForm(),
                    showLoading: buttonState is SubmitBplFormLoading,
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
