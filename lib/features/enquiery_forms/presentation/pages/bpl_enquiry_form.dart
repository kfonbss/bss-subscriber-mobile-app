import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/bpl_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/bpl_form/bpl_enquiry_form_cubit.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/bpl_form/bpl_enquiry_form_state.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiery_form_footer.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiry_form_header.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiry_form_preview.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_check_box.dart';
import 'package:kfon_subscriber/shared/widgets/common_text_area.dart';
import 'package:kfon_subscriber/shared/widgets/common_text_field.dart';
import 'package:kfon_subscriber/shared/widgets/form_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';

class BPLEnquiryForm extends StatefulWidget {
  const BPLEnquiryForm({super.key});

  @override
  State<BPLEnquiryForm> createState() => _BPLEnquiryFormState();
}

class _BPLEnquiryFormState extends State<BPLEnquiryForm> {
  final BplEnquiryFormCubit _enquiryFormCubit = BplEnquiryFormCubit(
    repository: sl<EnquiryFormRepository>(),
  );
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
  static const _pageCount = 3;

  BplEnquiryFormParams get params => BplEnquiryFormParams(
    rationCardHolderName: _rationCardHolderNameTextFieldController.text,
    rationCardHolderMob: _rationCardHolderMobTextFieldController.text,
    ksebConsumerNo: _ksebConsumerNoTextFieldController.text,
    aadharCardNumber: _aadharCardNumberTextFieldController.text,
    address: _addressTextFieldController.text,
    pinCode: _pinCodeTextFieldController.text,
    postOffice: _postOfficeTextFieldController.text,
    district: _districtTextFieldController.text,
    referralCode: _referralCodeTextFieldController.text,
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
    _enquiryFormCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return BlocConsumer<BplEnquiryFormCubit, BplEnquiryFormState>(
      bloc: _enquiryFormCubit,
      listenWhen: (previousState, currentState) =>
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
          _dialogUtil.showMessage(
            l10n.successMessage,
            context,
            backgroundColor: AppColor.kSuccessGreen,
          );
          Navigator.of(context).pop();
        }
      },
      buildWhen: (previous, current) =>
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
                heading: l10n.bplSubscriptionEnquiry,
                pageCount: _pageCount,
                currentPage: state is ShowPreview
                    ? _pageCount
                    : state is ShowPersonalInformationForm
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
                          map: params.personalInfoToMap(),
                          heading: l10n.personalInformation,
                        ),
                        EnquiryFormPreview(
                          map: params.addressInfoToMap(),
                          heading: l10n.addressInformation,
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
                          label: l10n.rationCardHolderName,
                          hintText: l10n.enterRationCardHolderName,
                          textEditingController:
                          _rationCardHolderNameTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.aadharLinkedMobileNumber,
                          hintText: l10n.enterMobileNumber,
                          textInputType: TextInputType.number,
                          maxLength: 10,
                          textEditingController:
                          _rationCardHolderMobTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.ksebConsumerNo,
                          hintText: l10n.enterKsebConsumerNo,
                          textInputType: TextInputType.number,
                          textEditingController:
                          _ksebConsumerNoTextFieldController,
                        ),
                        CommonTextField(
                          label:
                          l10n.aadharNumberOfRationCardHolder,
                          hintText:
                          l10n.enterAadharNumberOfRationCardHolder,
                          textInputType: TextInputType.number,
                          textEditingController:
                          _aadharCardNumberTextFieldController,
                        ),
                        CommonTextArea(
                          label: l10n.installationAddress,
                          hintText: l10n.enterInstallationAddress,
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
                          l10n.addressInformationStep,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kBlackHeadingColor,
                          ),
                        ),
                        CommonTextField(
                          label: l10n.pincode,
                          hintText: l10n.enterPincode,
                          maxLength: 6,
                          textInputType: TextInputType.number,
                          textEditingController:
                          _pinCodeTextFieldController,
                        ),
                        CommonTextField(
                          label: l10n.referralCode,
                          hintText: l10n.enterReferralCode,
                          textEditingController:
                          _referralCodeTextFieldController,
                        ),
                        CommonCheckBox(
                          initialStatus: _declarationStatus,
                          title: l10n.declarationConsent,
                          onChanged: (isChecked) =>
                          _declarationStatus = isChecked,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              BlocBuilder<BplEnquiryFormCubit, BplEnquiryFormState>(
                bloc: _enquiryFormCubit,
                buildWhen: (previous, current) =>
                current is SubmitBplFormLoading ||
                    current is SubmitBplFormError ||
                    current is SubmitBplFormSuccess,
                builder: (context, buttonState) {
                  return EnquiryFormFooter(
                    pageCount: _pageCount,
                    currentPage: state is ShowPreview
                        ? _pageCount
                        : state is ShowPersonalInformationForm
                        ? _pageCount - 2
                        : _pageCount - 1,
                    primaryButtonCallback: () => state is ShowPreview
                        ? _enquiryFormCubit.submitForm(params: params)
                        : state is ShowAddressInformationForm
                        ? _enquiryFormCubit.validateAddressForm(
                      params,
                      _declarationStatus,
                    )
                        : _enquiryFormCubit.validatePersonalForm(params),
                    secondaryButtonCallback: () => state is ShowPreview
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
