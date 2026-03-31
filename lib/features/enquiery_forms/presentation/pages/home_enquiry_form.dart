import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/home_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/home_enquiry_form/home_enquiry_form_cubit.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/home_enquiry_form/home_enquiry_form_state.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiery_form_footer.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiry_form_header.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/components/enquiry_form_preview.dart';
import 'package:kfon_subscriber/presentation/ui_component/form_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';

import '../../../../core/constant/constant_colors.dart';
import '../../../../presentation/ui_component/common_text_field.dart';

class HomeEnquiryForm extends StatefulWidget {
  const HomeEnquiryForm({super.key});

  @override
  State<HomeEnquiryForm> createState() => _HomeEnquiryFormState();
}

class _HomeEnquiryFormState extends State<HomeEnquiryForm> {
  final HomeEnquiryFormCubit _homeFormCubit = HomeEnquiryFormCubit(
    repository: sl<EnquiryFormRepository>(),
  );
  final _firstNameTextFieldController = TextEditingController();
  final _lastNameTextFieldController = TextEditingController();
  final _pinCodeTextFieldController = TextEditingController();
  final _locationNameTextFieldController = TextEditingController();
  final _mobileNumberTextFieldController = TextEditingController();
  final _emailTextFieldController = TextEditingController();

  final DialogUtil _dialogUtil = DialogUtil();
  final int _pageCount = 4;

  // HomeEnquiryFormParams get params => HomeEnquiryFormParams(
  //   firstName: _firstNameTextFieldController.text,
  //   lastName: _lastNameTextFieldController.text,
  //   pinCode: _pinCodeTextFieldController.text,
  //   location: _locationNameTextFieldController.text,
  //   mobileNumber: _mobileNumberTextFieldController.text,
  //   email: _emailTextFieldController.text,
  //
  // );
  HomeEnquiryFormParams get params => HomeEnquiryFormParams(
    firstName: 'Ajith',
    lastName: 'Sivan',
    pinCode: '691574',
    location: 'Pampuram',
    mobileNumber: '9633200178',
    email: 'ajith@gmail.com',
    cusAddress: 'Sahadeva Vilasom',
    cusCity: 'Parippally',
    cusLocation: 'ESI juction',
    postOffice: 'Parippally PO',
    cusState: 'Kerala',
    houseNo: '1234',
    latitude: '60.123',
    longitude: '70.123',
  );

  @override
  void dispose() {
    _firstNameTextFieldController.dispose();
    _lastNameTextFieldController.dispose();
    _pinCodeTextFieldController.dispose();
    _locationNameTextFieldController.dispose();
    _mobileNumberTextFieldController.dispose();
    _emailTextFieldController.dispose();
    _homeFormCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeEnquiryFormCubit, HomeEnquiryFormState>(
      bloc: _homeFormCubit,
      listenWhen:
          (previousState, currentState) =>
              currentState is HomeFormValidationError ||
              currentState is HomeFormSubmissionError ||
              currentState is HomeFormSubmissionSuccess,
      listener: (context, state) {
        if (state is HomeFormValidationError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is HomeFormSubmissionError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is HomeFormSubmissionSuccess) {
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
              current is ShowNameForm ||
              current is ShowLocationForm ||
              current is ShowContactForm ||
              current is ShowPreview,
      builder: (context, state) {
        return FormAppBar(
          showBackButton: false,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              EnquiryFormHeader(
                heading: 'Home Enquiry',
                pageCount: _pageCount,
                currentPage:
                    state is ShowPreview
                        ? _pageCount
                        : state is ShowContactForm
                        ? _pageCount - 1
                        : state is ShowLocationForm
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
                                  '4. Preview',
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
                            : state is ShowNameForm
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
                              ],
                            )
                            : state is ShowLocationForm
                            ? Column(
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
                                  label: 'Pincode*',
                                  hintText: 'Enter Pincode',
                                  textEditingController:
                                      _pinCodeTextFieldController,
                                  maxLength: 6,
                                  textInputType: TextInputType.number,
                                ),
                                CommonTextField(
                                  label: 'Location*',
                                  hintText: 'Enter Location',
                                  textEditingController:
                                      _locationNameTextFieldController,
                                ),
                              ],
                            )
                            : Column(
                              spacing: 30,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '3. How can we reach you?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.kBlackHeadingColor,
                                  ),
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
                            ),
                  ),
                ),
              ),
              BlocBuilder<HomeEnquiryFormCubit, HomeEnquiryFormState>(
                bloc: _homeFormCubit,
                buildWhen:
                    (previous, current) =>
                        current is HomeFormSubmissionLoading ||
                        current is HomeFormSubmissionError ||
                        current is HomeFormSubmissionSuccess,
                builder:
                    (context, buttonState) => EnquiryFormFooter(
                      pageCount: _pageCount,
                      currentPage:
                          state is ShowPreview
                              ? _pageCount
                              : state is ShowContactForm
                              ? _pageCount - 1
                              : state is ShowLocationForm
                              ? _pageCount - 2
                              : _pageCount - 3,
                      primaryButtonCallback:
                          () =>
                              state is ShowPreview
                                  ? _homeFormCubit.submitForm(
                                    params: params,
                                  )
                                  : state is ShowNameForm
                                  ? _homeFormCubit.validateNameForm(
                                    params: params,
                                  )
                                  : state is ShowLocationForm
                                  ? _homeFormCubit.validateLocationForm(
                                    params: params,
                                  )
                                  : _homeFormCubit.validateContactForm(
                                    params: params,
                                  ),
                      secondaryButtonCallback:
                          () =>
                              state is ShowPreview
                                  ? _homeFormCubit.showContactForm()
                                  : state is ShowContactForm
                                  ? _homeFormCubit.showLocationForm()
                                  : _homeFormCubit.showNameForm(),
                      showLoading: buttonState is HomeFormSubmissionLoading,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
