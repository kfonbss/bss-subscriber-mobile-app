import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/enquiry_otp/enquiry_otp_state.dart';

/// Sends / verifies the mobile OTP for the home enquiry. The returned
/// otpRefId is kept here (in memory only) and never exposed to the UI.
class EnquiryOtpCubit extends Cubit<EnquiryOtpState> {
  EnquiryOtpCubit({required this.repository}) : super(EnquiryOtpInitial());
  final EnquiryFormRepository repository;

  String? _otpRefId;

  bool get _isBusy =>
      state is EnquiryOtpSending || state is EnquiryOtpVerifying;

  /// Returns true when an OTP was sent. Ignored while a request is running.
  Future<bool> sendOtp({
    required String mobileNumber,
    required String tenantId,
  }) async {
    if (_isBusy) return false;
    _otpRefId = null;
    emit(EnquiryOtpSending());
    try {
      final result = await repository.sendEnquiryOtp(
        mobileNumber: mobileNumber,
        tenantId: tenantId,
      );
      return result.fold<bool>(
        (error) {
          emit(EnquiryOtpSendError(errorMessage: error.toString()));
          return false;
        },
        (otpRefId) {
          _otpRefId = otpRefId as String;
          emit(EnquiryOtpSent());
          return true;
        },
      );
    } catch (_) {
      emit(
        EnquiryOtpSendError(
          errorMessage: 'Unable to send OTP. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<void> verifyOtp({
    required String otp,
    required String tenantId,
  }) async {
    if (_isBusy) return;
    final otpRefId = _otpRefId;
    if (otpRefId == null || otpRefId.isEmpty) {
      emit(
        EnquiryOtpVerifyError(
          errorMessage: 'OTP session expired. Please request a new OTP.',
        ),
      );
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      emit(EnquiryOtpVerifyError(errorMessage: 'Enter the 6-digit OTP.'));
      return;
    }
    emit(EnquiryOtpVerifying());
    try {
      final result = await repository.verifyEnquiryOtp(
        otpRefId: otpRefId,
        otp: otp,
        tenantId: tenantId,
      );
      result.fold(
        (error) => emit(EnquiryOtpVerifyError(errorMessage: error.toString())),
        (_) => emit(EnquiryOtpVerified()),
      );
    } catch (_) {
      emit(
        EnquiryOtpVerifyError(
          errorMessage: 'Unable to verify OTP. Please try again.',
        ),
      );
    }
  }
}
