import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/subscription_enquiry_form/subscription_form_state.dart';
import 'package:kfon_subscriber/common/bloc/subscription_enquiry_form/subscription_form_cubit.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/subscription_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usercases/post_office_district_user_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usercases/subscription_enquiry_form_submission_user_case.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiery_form_footer.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiry_form_header.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiry_form_preview.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_check_box.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_drop_down.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_area.dart';
import 'package:kfon_subscriber/presentation/ui_component/default_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/util/dialog_util.dart';

import '../../../core/constant/constant_colors.dart';
import '../../ui_component/common_text_field.dart';

class SubscriptionEnquiryForm extends StatefulWidget {
  const SubscriptionEnquiryForm({super.key});

  @override
  State<SubscriptionEnquiryForm> createState() =>
      _SubscriptionEnquiryFormState();
}

class _SubscriptionEnquiryFormState extends State<SubscriptionEnquiryForm> {
  final SubscriptionFormCubit _subscriptionFormCubit = SubscriptionFormCubit();
  final _nameTextFieldController = TextEditingController();
  final _mobileNumberTextFieldController = TextEditingController();
  final _ksebConsumerNoTextFieldController = TextEditingController();
  final _addressTextFieldController = TextEditingController();
  final _pinCodeTextFieldController = TextEditingController();
  final _referralCodeTextFieldController = TextEditingController();
  final TextEditingController _postOfficeTextFieldController =
      TextEditingController();
  final TextEditingController _districtTextFieldController =
      TextEditingController();
  final DialogUtil _dialogUtil = DialogUtil();
  final int _pageCount = 2;
  bool _declarationStatus = false;

  SubscriptionEnquiryFormParams get params => SubscriptionEnquiryFormParams(
    name: _nameTextFieldController.text,
    mobileNumber: _mobileNumberTextFieldController.text,
    ksebConsumerNo: _ksebConsumerNoTextFieldController.text,
    address: _addressTextFieldController.text,
    pinCode: _pinCodeTextFieldController.text,
    postOffice: _postOfficeTextFieldController.text,
    district: _districtTextFieldController.text,
    referralCode: _referralCodeTextFieldController.text,
  );

  @override
  void dispose() {
    _nameTextFieldController.dispose();
    _mobileNumberTextFieldController.dispose();
    _ksebConsumerNoTextFieldController.dispose();
    _addressTextFieldController.dispose();
    _referralCodeTextFieldController.dispose();
    _districtTextFieldController.dispose();
    _pinCodeTextFieldController.dispose();
    _subscriptionFormCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionFormCubit, SubscriptionFormState>(
      bloc: _subscriptionFormCubit,
      listenWhen:
          (previousState, currentState) =>
              currentState is GetPostOfficesDistrictError ||
              currentState is SubscriptionFormValidationError ||
              currentState is SubmitSubscriptionFormError ||
              currentState is GetPostOfficesDistrictLoading ||
              currentState is SubmitSubscriptionFormSuccess,
      listener: (context, state) {
        if (state is GetPostOfficesDistrictError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is SubscriptionFormValidationError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is SubmitSubscriptionFormError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is GetPostOfficesDistrictLoading) {
          _districtTextFieldController.clear();
          _postOfficeTextFieldController.clear();
        } else if (state is SubmitSubscriptionFormSuccess) {
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
                heading: 'Subscription Enquiry',
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
                                  heading: 'Personal Information',
                                ),
                              ],
                            )
                            : Column(
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
                                  label: 'Name*',
                                  hintText: 'Enter Name',
                                  textEditingController:
                                      _nameTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Mobile Number*',
                                  hintText: 'Enter Mobile Number',
                                  textInputType: TextInputType.number,
                                  maxLength: 10,
                                  textEditingController:
                                      _mobileNumberTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'KSEB Consumer No',
                                  hintText: 'Enter KSEB Consumer No',
                                  textInputType: TextInputType.number,
                                  textEditingController:
                                      _ksebConsumerNoTextFieldController,
                                ),
                                CommonTextArea(
                                  label: 'Installation Address*',
                                  hintText: 'Enter Address Here',
                                  textEditingController:
                                      _addressTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Pincode*',
                                  hintText: 'Enter Pincode',
                                  textEditingController:
                                      _pinCodeTextFieldController,
                                  maxLength: 6,
                                  textInputType: TextInputType.number,
                                  onTextChanged: (pinCode) {
                                    if (pinCode.length == 6) {
                                      _subscriptionFormCubit
                                          .getPostOfficeDistrict(
                                            useCase:
                                                sl<
                                                  PostOfficeDistrictsUserCase
                                                >(),
                                            pinCode: pinCode,
                                          );
                                    }
                                  },
                                ),
                                BlocBuilder<
                                  SubscriptionFormCubit,
                                  SubscriptionFormState
                                >(
                                  bloc: _subscriptionFormCubit,
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
                                BlocBuilder<
                                  SubscriptionFormCubit,
                                  SubscriptionFormState
                                >(
                                  bloc: _subscriptionFormCubit,
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
              BlocBuilder<SubscriptionFormCubit, SubscriptionFormState>(
                bloc: _subscriptionFormCubit,
                buildWhen:
                    (previous, current) =>
                        current is SubmitSubscriptionFormLoading ||
                        current is SubmitSubscriptionFormError ||
                        current is SubmitSubscriptionFormSuccess,
                builder:
                    (context, buttonState) => EnquiryFormFooter(
                      pageCount: _pageCount,
                      currentPage:
                          state is ShowPreview ? _pageCount : _pageCount - 1,
                      primaryButtonCallback:
                          () =>
                              state is ShowPreview
                                  ? _subscriptionFormCubit.submitForm(
                                    useCase:
                                        sl<
                                          SubscriptionEnquiryFormSubmissionUserCase
                                        >(),
                                    params: params,
                                  )
                                  : _subscriptionFormCubit.validateForm(
                                    params: params,
                                    declarationStatus: _declarationStatus,
                                  ),
                      secondaryButtonCallback:
                          () => _subscriptionFormCubit.showForm(),
                      showLoading: buttonState is SubmitSubscriptionFormLoading,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
