import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/gov_and_corp_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/gov_and_corp_enquiry_form/gov_and_corp_enquiry_form_cubit.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/gov_and_corp_enquiry_form/gov_and_corp_enquiry_form_state.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiery_form_footer.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiry_form_header.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiry_form_preview.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_drop_down.dart';
import 'package:kfon_subscriber/shared/widgets/common_text_field.dart';
import 'package:kfon_subscriber/shared/widgets/form_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';

class GovAndCorpEnquiryForm extends StatefulWidget {
  final bool isGovernmentEnquiry;

  const GovAndCorpEnquiryForm({super.key, required this.isGovernmentEnquiry});

  @override
  State<GovAndCorpEnquiryForm> createState() => _GovAndCorpEnquiryFormState();
}

class _GovAndCorpEnquiryFormState extends State<GovAndCorpEnquiryForm> {
  final GovAndCorpEnquiryFormCubit _govAndCorpEnquiryFormCubit =
  GovAndCorpEnquiryFormCubit(repository: sl<EnquiryFormRepository>());
  final _firstNameTextFieldController = TextEditingController();
  final _lastNameTextFieldController = TextEditingController();
  final _pinCodeTextFieldController = TextEditingController();
  final _companyNameTextFieldController = TextEditingController();
  final _mobileNumberTextFieldController = TextEditingController();
  final _emailTextFieldController = TextEditingController();
  final _industryTextFieldController = TextEditingController();
  final _serviceTextFieldController = TextEditingController();
  static const List<String> _industries = ['Education', 'IT', 'Banking', 'Manufacturing'];
  static const List<String> _services = ['Education', 'IT', 'Banking', 'Manufacturing'];

  final DialogUtil _dialogUtil = DialogUtil();
  static const int _pageCount = 3;

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
    final l10n = context.bssSubL10n;

    return BlocConsumer<GovAndCorpEnquiryFormCubit, GovAndCorpEnquiryFormState>(
      bloc: _govAndCorpEnquiryFormCubit,
      listenWhen: (previousState, currentState) =>
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
            l10n.successMessage,
            context,
            backgroundColor: AppColor.kSuccessGreen,
          );
          Navigator.of(context).pop();
        }
      },
      buildWhen: (previous, current) =>
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
                heading: widget.isGovernmentEnquiry
                    ? l10n.governmentEnquiry
                    : l10n.corporateEnquiry,
                pageCount: _pageCount,
                currentPage: state is ShowPreview
                    ? _pageCount
                    : state is ShowLocationForm
                    ? _pageCount - 1
                    : _pageCount - 2,
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
                          map: params.getPreview(),
                          heading: l10n.personalInformation,
                        ),
                      ],
                    )
                        : state is ShowPersonalForm
                        ? Column(
                      spacing: 30,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.letsGetToKnowYouStep,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kBlackHeadingColor,
                          ),
                        ),
                        CommonTextField(
                          label: l10n.firstName,
                          hintText: l10n.enterFirstName,
                          textEditingController:
                          _firstNameTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.lastName,
                          hintText: l10n.enterLastName,
                          textEditingController:
                          _lastNameTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.mobileNumber,
                          hintText: l10n.enterMobileNumber2,
                          textEditingController:
                          _mobileNumberTextFieldController,
                          maxLength: 10,
                          textInputType: TextInputType.number,
                        ),
                        CommonTextField(
                          label: l10n.emailId,
                          hintText: l10n.enterEmailId,
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
                          l10n.whereShouldWeBringInternetStep,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kBlackHeadingColor,
                          ),
                        ),
                        CommonTextField(
                          label: l10n.companyName,
                          hintText: l10n.enterCompanyName,
                          textEditingController:
                          _companyNameTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.pincode,
                          hintText: l10n.enterPincode,
                          textEditingController:
                          _pinCodeTextFieldController,
                          maxLength: 6,
                          textInputType: TextInputType.number,
                        ),
                        CommonDropDown(
                          textEditingController:
                          _industryTextFieldController,
                          items: _industries,
                          label: l10n.industry,
                          hintText: l10n.selectIndustry,
                          onSelected: (item) {},
                        ),
                        CommonDropDown(
                          textEditingController:
                          _serviceTextFieldController,
                          items: _services,
                          label: l10n.service,
                          hintText: l10n.selectService,
                          onSelected: (item) {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              BlocBuilder<GovAndCorpEnquiryFormCubit, GovAndCorpEnquiryFormState>(
                bloc: _govAndCorpEnquiryFormCubit,
                buildWhen: (previous, current) =>
                current is GovAndCorpFormSubmissionLoading ||
                    current is GovAndCorpFormSubmissionError ||
                    current is GovAndCorpFormSubmissionSuccess,
                builder: (context, buttonState) => EnquiryFormFooter(
                  pageCount: _pageCount,
                  currentPage: state is ShowPreview
                      ? _pageCount
                      : state is ShowLocationForm
                      ? _pageCount - 1
                      : _pageCount - 2,
                  primaryButtonCallback: () => state is ShowPreview
                      ? _govAndCorpEnquiryFormCubit.submitForm(params: params)
                      : state is ShowPersonalForm
                      ? _govAndCorpEnquiryFormCubit.validatePersonalForm(
                    params: params,
                  )
                      : _govAndCorpEnquiryFormCubit.validateLocationForm(
                    params: params,
                  ),
                  secondaryButtonCallback: () => state is ShowPreview
                      ? _govAndCorpEnquiryFormCubit.showLocationForm()
                      : _govAndCorpEnquiryFormCubit.showPersonalForm(),
                  showLoading: buttonState is GovAndCorpFormSubmissionLoading,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
