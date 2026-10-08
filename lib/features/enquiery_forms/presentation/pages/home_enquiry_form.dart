import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/home_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/region_model.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/circle/circle_cubit.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/circle/circle_state.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/home_enquiry_form/home_enquiry_form_cubit.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/mobile_check/mobile_check_cubit.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/mobile_check/mobile_check_state.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/home_enquiry_form/home_enquiry_form_state.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';
import 'package:kfon_subscriber/shared/widgets/common_drop_down.dart';
import 'package:kfon_subscriber/shared/widgets/form_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';

import '../../../../core/constant/constant_colors.dart';
import '../../../../shared/widgets/common_text_field.dart';
import '../../../../core/constant/constant_dimensions.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';

class HomeEnquiryForm extends StatefulWidget {
  const HomeEnquiryForm({super.key});

  @override
  State<HomeEnquiryForm> createState() => _HomeEnquiryFormState();
}

class _HomeEnquiryFormState extends State<HomeEnquiryForm> {
  final CircleCubit _circleCubit = CircleCubit(
    repository: sl<EnquiryFormRepository>(),
  )..fetchRegions();

  /// Region chosen in the Circle dropdown (auto-picked when the API returns
  /// a single region).
  RegionModel? _selectedRegion;

  final MobileCheckCubit _mobileCheckCubit = MobileCheckCubit(
    repository: sl<EnquiryFormRepository>(),
  );

  /// Last 10-digit number already checked, so it isn't re-checked on rebuilds.
  String? _lastCheckedMobile;

  final HomeEnquiryFormCubit _homeFormCubit = HomeEnquiryFormCubit(
    repository: sl<EnquiryFormRepository>(),
  );
  final _fullNameTextFieldController = TextEditingController();
  final _circleTextFieldController = TextEditingController();
  final _pinCodeTextFieldController = TextEditingController();
  final _locationNameTextFieldController = TextEditingController();
  final _mobileNumberTextFieldController = TextEditingController();
  final _emailTextFieldController = TextEditingController();

  final DialogUtil _dialogUtil = DialogUtil();

  /// The single "Full Name" field feeds the existing first/last name params:
  /// first word -> first name, the rest -> last name.
  String get _fullName => _fullNameTextFieldController.text.trim();

  String get _firstName {
    final i = _fullName.indexOf(RegExp(r'\s'));
    return i < 0 ? _fullName : _fullName.substring(0, i);
  }

  String get _lastName {
    final i = _fullName.indexOf(RegExp(r'\s'));
    return i < 0 ? '' : _fullName.substring(i).trim();
  }

  HomeEnquiryFormParams get params => HomeEnquiryFormParams(
    firstName: _firstName,
    lastName: _lastName,
    pinCode: _pinCodeTextFieldController.text,
    location: _locationNameTextFieldController.text,
    mobileNumber: _mobileNumberTextFieldController.text,
    email: _emailTextFieldController.text,
    cusAddress: '',
    cusCity: '',
    cusLocation: '',
    postOffice: '',
    cusState: '',
    houseNo: '',
    latitude: '',
    longitude: '',
  );

  @override
  void dispose() {
    _fullNameTextFieldController.dispose();
    _circleTextFieldController.dispose();
    _pinCodeTextFieldController.dispose();
    _locationNameTextFieldController.dispose();
    _mobileNumberTextFieldController.dispose();
    _emailTextFieldController.dispose();
    _circleCubit.close();
    _mobileCheckCubit.close();
    _homeFormCubit.close();
    super.dispose();
  }

  /// Checks a full 10-digit number against the selected circle's tenant.
  /// Skipped while no circle is available.
  void _onMobileChanged(String value) {
    final mobile = value.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      _lastCheckedMobile = null;
      return;
    }
    final region = _selectedRegion;
    if (region == null || mobile == _lastCheckedMobile) return;
    _lastCheckedMobile = mobile;
    _mobileCheckCubit.checkMobile(mobileNumber: mobile, tenantId: region.code);
  }

  /// Yes -> keep the number and continue. No -> clear the number.
  void _showAlreadyRegisteredSheet(String? trackingId) {
    final l10n = context.bssSubL10n;
    showAppModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder:
          (sheetContext) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Mobile number already registered',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    color: AppColor.kTextSecondaryDark,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'An enquiry with this mobile number already exists. '
                  'Do you want to continue?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    color: AppColor.kTextFiledPlaceholderColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                ),
                if (trackingId != null && trackingId.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _TrackingIdTile(trackingId: trackingId),
                ],
                const SizedBox(height: 28),
                PrimaryButton(
                  label: l10n.yes,
                  isLoading: false,
                  height: 52,
                  borderRadius: 28,
                  onClicked: () => Navigator.of(sheetContext).pop(),
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: l10n.no,
                  height: 52,
                  borderRadius: 28,
                  onClicked: () {
                    Navigator.of(sheetContext).pop();
                    _mobileNumberTextFieldController.clear();
                    _lastCheckedMobile = null;
                  },
                ),
              ],
            ),
          ),
    );
  }

  /// Single-page submit: runs the existing cubit validators (stopping at the
  /// first failure, which the listener shows as a dialog) and then submits.
  Future<void> _onSubmit() async {
    final validators = [
      _homeFormCubit.validateNameForm,
      _homeFormCubit.validateContactForm,
      _homeFormCubit.validateLocationForm,
    ];
    for (final validate in validators) {
      await validate(params: params);
      if (_homeFormCubit.state is HomeFormValidationError) return;
    }
    await _homeFormCubit.submitForm(params: params);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return BlocListener<HomeEnquiryFormCubit, HomeEnquiryFormState>(
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
            l10n.successMessage,
            context,
            backgroundColor: AppColor.kSuccessGreen,
          );
          Navigator.of(context).pop();
        }
      },
      child: BlocListener<MobileCheckCubit, MobileCheckState>(
        bloc: _mobileCheckCubit,
        listenWhen: (previous, current) => current is MobileAlreadyRegistered,
        listener: (context, state) {
          // Ignore a stale answer if the number was edited meanwhile.
          if (state is MobileAlreadyRegistered &&
              state.mobileNumber ==
                  _mobileNumberTextFieldController.text.trim()) {
            _showAlreadyRegisteredSheet(state.trackingId);
          }
        },
        child: FormAppBar(
          showBackButton: false,
          body: SafeArea(
            top: false,
            // The Scaffold doesn't resize for the keyboard, so shrink the scroll
            // viewport here; focused fields then scroll into view above it.
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Get Home Wi-Fi Connection',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.kBlackHeadingColor,
                        height: 1.3,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    CommonTextField(
                      label: 'Full Name*',
                      hintText: 'Enter Full Name',
                      textEditingController: _fullNameTextFieldController,
                    ),
                    CommonTextField(
                      label: 'Mobile Number*',
                      hintText: 'Enter Mobile Number',
                      textEditingController: _mobileNumberTextFieldController,
                      onTextChanged: _onMobileChanged,
                      maxLength: 10,
                      textInputType: TextInputType.number,
                    ),
                    // Required by the existing validation; not part of the .md spec.
                    CommonTextField(
                      label: l10n.emailId,
                      hintText: l10n.enterEmailId,
                      textEditingController: _emailTextFieldController,
                    ),
                    BlocConsumer<CircleCubit, CircleState>(
                      bloc: _circleCubit,
                      listener: (context, state) {
                        if (state is CircleLoaded) {
                          // Single region -> select it automatically.
                          _selectedRegion =
                              state.regions.length == 1
                                  ? state.regions.first
                                  : null;
                          _circleTextFieldController.text =
                              _selectedRegion?.name ?? '';
                        } else {
                          _selectedRegion = null;
                          _circleTextFieldController.clear();
                        }
                      },
                      builder: (context, state) {
                        final regions =
                            state is CircleLoaded
                                ? state.regions
                                : <RegionModel>[];
                        return Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CommonDropDown(
                              // null items shows the dropdown's loading spinner.
                              items:
                                  state is CircleLoading
                                      ? null
                                      : regions.map((e) => e.name).toList(),
                              useInputStyle: true,
                              label: 'Circle*',
                              hintText: 'Choose Circle',
                              onSelected:
                                  (name) =>
                                      _selectedRegion = regions.firstWhere(
                                        (e) => e.name == name,
                                      ),
                              textEditingController: _circleTextFieldController,
                            ),
                            if (state is CircleError)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      state.errorMessage,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColor.kErrorRed,
                                        fontFamily: 'GeneralSans',
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _circleCubit.fetchRegions,
                                    child: Text(
                                      'Retry',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.kPrimaryColor,
                                        fontFamily: 'GeneralSans',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                    CommonTextField(
                      label: 'PIN Code*',
                      hintText: 'Enter PIN Code',
                      textEditingController: _pinCodeTextFieldController,
                      maxLength: 6,
                      textInputType: TextInputType.number,
                    ),
                    Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CommonTextField(
                          label: 'Installation address *',
                          hintText: 'Enter Installation address',
                          textEditingController:
                              _locationNameTextFieldController,
                        ),
                        // UI only: map selection is not implemented yet.
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 6,
                            children: [
                              Icon(
                                Icons.gps_fixed,
                                size: 18.sp,
                                color: AppColor.kPrimaryColor,
                              ),
                              Text(
                                'Select on the Map',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.kPrimaryColor,
                                  height: 1.3,
                                  fontFamily: 'GeneralSans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    BlocBuilder<HomeEnquiryFormCubit, HomeEnquiryFormState>(
                      bloc: _homeFormCubit,
                      buildWhen:
                          (previous, current) =>
                              current is HomeFormSubmissionLoading ||
                              current is HomeFormSubmissionError ||
                              current is HomeFormSubmissionSuccess,
                      builder:
                          (context, buttonState) => Row(
                            spacing: 10,
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  label: l10n.cancel,
                                  onClicked: () => Navigator.of(context).pop(),
                                  borderRadius: 28,
                                  height: 52,
                                  icon: Icon(
                                    Icons.cancel_outlined,
                                    color: AppColor.kPrimaryColor,
                                    size: AppDimensions.kButtonIconSize,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: PrimaryButton(
                                  label: 'Submit',
                                  onClicked: _onSubmit,
                                  isLoading:
                                      buttonState is HomeFormSubmissionLoading,
                                  borderRadius: 28,
                                  height: 52,
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: AppDimensions.kButtonIconSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tracking ID row with a copy action (shows a brief "Copied" confirmation).
class _TrackingIdTile extends StatefulWidget {
  final String trackingId;
  const _TrackingIdTile({required this.trackingId});

  @override
  State<_TrackingIdTile> createState() => _TrackingIdTileState();
}

class _TrackingIdTileState extends State<_TrackingIdTile> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.trackingId));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.kPrimary5,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.kinputFiledLightBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tracking ID',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    color: AppColor.kTextFiledPlaceholderColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  widget.trackingId,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    color: AppColor.kTextSecondaryDark,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _copy,
            icon: Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 18,
              color: AppColor.kPrimaryColor,
            ),
            label: Text(
              _copied ? 'Copied' : 'Copy',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                color: AppColor.kPrimaryColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
