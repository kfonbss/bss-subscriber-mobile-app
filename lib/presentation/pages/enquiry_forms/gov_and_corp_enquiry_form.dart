import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/gov_and_corp_enquiry_form/gov_and_corp_enquiry_form_cubit.dart';
import 'package:kfon_subscriber/common/bloc/gov_and_corp_enquiry_form/gov_and_corp_enquiry_form_state.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/gov_and_corp_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/gov_and_corp_enquiry_form_use_case.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiery_form_footer.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiry_form_header.dart';
import 'package:kfon_subscriber/presentation/page_component/enquiry_form_preview.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_drop_down.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/form_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';

class GovAndCorpEnquiryForm extends StatefulWidget {
  final bool isGovernmentEnquiry;

  const GovAndCorpEnquiryForm({super.key, required this.isGovernmentEnquiry});

  @override
  State<GovAndCorpEnquiryForm> createState() => _GovAndCorpEnquiryFormState();
}

class _GovAndCorpEnquiryFormState extends State<GovAndCorpEnquiryForm> {
  final GovAndCorpEnquiryFormCubit _govAndCorpEnquiryFormCubit =
      GovAndCorpEnquiryFormCubit();
  final _firstNameTextFieldController = TextEditingController();
  final _lastNameTextFieldController = TextEditingController();
  final _pinCodeTextFieldController = TextEditingController();
  final _companyNameTextFieldController = TextEditingController();
  final _mobileNumberTextFieldController = TextEditingController();
  final _emailTextFieldController = TextEditingController();
  final _industryTextFieldController = TextEditingController();
  final _serviceTextFieldController = TextEditingController();
  final List<String> _industries = [
    'Education',
    'IT',
    'Banking',
    'Manufacturing',
  ];
  final List<String> _services = [
    'Education',
    'IT',
    'Banking',
    'Manufacturing',
  ];

  final DialogUtil _dialogUtil = DialogUtil();
  final int _pageCount = 3;

  GovAndCorpEnquiryFormParams get params => GovAndCorpEnquiryFormParams(
    firstName: _firstNameTextFieldController.text,
    lastName: _lastNameTextFieldController.text,
    mobileNumber: _mobileNumberTextFieldController.text,
    email: _emailTextFieldController.text,
    pinCode: _pinCodeTextFieldController.text,
    companyName: _companyNameTextFieldController.text,
    service: _serviceTextFieldController.text,
    industry: _industryTextFieldController.text,
  );

  @override
  void dispose() {
    _firstNameTextFieldController.dispose();
    _lastNameTextFieldController.dispose();
    _mobileNumberTextFieldController.dispose();
    _emailTextFieldController.dispose();
    _pinCodeTextFieldController.dispose();
    _companyNameTextFieldController.dispose();
    _industryTextFieldController.dispose();
    _serviceTextFieldController.dispose();
    _govAndCorpEnquiryFormCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GovAndCorpEnquiryFormCubit, GovAndCorpEnquiryFormState>(
      bloc: _govAndCorpEnquiryFormCubit,
      listenWhen:
          (previousState, currentState) =>
              currentState is GovAndCorpFormValidationError ||
              currentState is GovAndCorpFormSubmissionError ||
              currentState is GovAndCorpFormSubmissionSuccess,
      listener: (context, state) {
        if (state is GovAndCorpFormValidationError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is GovAndCorpFormSubmissionError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is GovAndCorpFormSubmissionSuccess) {
          _dialogUtil.showMessage(
            'Success',
            context,
            backgroundColor: Colors.green,
          );
          Navigator.of(context).pop();
        }
      },
      buildWhen:
          (previous, current) =>
              current is ShowLocationForm ||
              current is ShowPersonalForm ||
              current is ShowPreview,
      builder: (context, state) {
        return FormAppBar(
          showBackButton: false,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              EnquiryFormHeader(
                heading:
                    widget.isGovernmentEnquiry
                        ? 'Government Enquiry'
                        : 'Corporate Enquiry',
                pageCount: _pageCount,
                currentPage:
                    state is ShowPreview
                        ? _pageCount
                        : state is ShowLocationForm
                        ? _pageCount - 1
                        : _pageCount - 2,
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
                                  map: params.getPreview(),
                                  heading: 'Personal Information',
                                ),
                              ],
                            )
                            : state is ShowPersonalForm
                            ? Column(
                              spacing: 30,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '1. Let\'s get to know you',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.kBlackHeadingColor,
                                  ),
                                ),
                                CommonTextField(
                                  label: 'First Name*',
                                  hintText: 'Enter First Name',
                                  textEditingController:
                                      _firstNameTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Last Name*',
                                  hintText: 'Enter Last Name',
                                  textEditingController:
                                      _lastNameTextFieldController,
                                ),
                                CommonTextField(
                                  label: 'Mobile Number*',
                                  hintText: 'Enter Mobile Number',
                                  textEditingController:
                                      _mobileNumberTextFieldController,
                                  maxLength: 10,
                                  textInputType: TextInputType.number,
                                ),
                                CommonTextField(
                                  label: 'Email ID*',
                                  hintText: 'Enter Email ID',
                                  textEditingController:
                                      _emailTextFieldController,
                                ),
                              ],
                            )
                            : Column(
                              spacing: 30,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '2. Where should we bring the internet?',
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
                                  label: 'Pincode*',
                                  hintText: 'Enter Pincode',
                                  textEditingController:
                                      _pinCodeTextFieldController,
                                  maxLength: 6,
                                  textInputType: TextInputType.number,
                                ),
                                CommonDropDown(
                                  textEditingController:
                                      _industryTextFieldController,
                                  items: _industries,
                                  label: 'Industry*',
                                  hintText: 'Select Industry',
                                  onSelected: (item) {},
                                ),
                                CommonDropDown(
                                  textEditingController:
                                      _serviceTextFieldController,
                                  items: _services,
                                  label: 'Service*',
                                  hintText: 'Select Service',
                                  onSelected: (item) {},
                                ),
                              ],
                            ),
                  ),
                ),
              ),
              BlocBuilder<
                GovAndCorpEnquiryFormCubit,
                GovAndCorpEnquiryFormState
              >(
                bloc: _govAndCorpEnquiryFormCubit,
                buildWhen:
                    (previous, current) =>
                        current is GovAndCorpFormSubmissionLoading ||
                        current is GovAndCorpFormSubmissionError ||
                        current is GovAndCorpFormSubmissionSuccess,
                builder:
                    (context, buttonState) => EnquiryFormFooter(
                      pageCount: _pageCount,
                      currentPage:
                          state is ShowPreview
                              ? _pageCount
                              : state is ShowLocationForm
                              ? _pageCount - 1
                              : _pageCount - 2,
                      primaryButtonCallback:
                          () =>
                              state is ShowPreview
                                  ? _govAndCorpEnquiryFormCubit.submitForm(
                                    useCase: sl<GovAndCorpEnquiryFormUseCase>(),
                                    params: params,
                                  )
                                  : state is ShowPersonalForm
                                  ? _govAndCorpEnquiryFormCubit
                                      .validatePersonalForm(params: params)
                                  : _govAndCorpEnquiryFormCubit
                                      .validateLocationForm(params: params),
                      secondaryButtonCallback:
                          () =>
                              state is ShowPreview
                                  ? _govAndCorpEnquiryFormCubit
                                      .showLocationForm()
                                  : _govAndCorpEnquiryFormCubit
                                      .showPersonalForm(),
                      showLoading:
                          buttonState is GovAndCorpFormSubmissionLoading,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
