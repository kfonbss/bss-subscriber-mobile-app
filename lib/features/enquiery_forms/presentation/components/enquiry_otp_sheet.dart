import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/auth/presentation/components/auth_header.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/enquiry_otp/enquiry_otp_cubit.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/bloc/enquiry_otp/enquiry_otp_state.dart';
import 'package:kfon_subscriber/shared/widgets/otp_input_field.dart';
import 'package:kfon_subscriber/shared/widgets/white_button.dart';

/// Shows the OTP verification sheet, styled like the Login OTP screen
/// (primary background, [AuthHeader] logo/heading, [OtpInputField] boxes).
/// Completes with true once the OTP is verified, otherwise false/null
/// (closed by the user).
Future<bool?> showEnquiryOtpSheet({
  required BuildContext context,
  required EnquiryOtpCubit cubit,
  required String mobileNumber,
  required String tenantId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: AppColor.kPrimaryColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder:
        (_) => BlocProvider.value(
          value: cubit,
          child: _EnquiryOtpSheet(
            mobileNumber: mobileNumber,
            tenantId: tenantId,
          ),
        ),
  );
}

class _EnquiryOtpSheet extends StatefulWidget {
  final String mobileNumber;
  final String tenantId;
  const _EnquiryOtpSheet({required this.mobileNumber, required this.tenantId});

  @override
  State<_EnquiryOtpSheet> createState() => _EnquiryOtpSheetState();
}

class _EnquiryOtpSheetState extends State<_EnquiryOtpSheet> {
  static const int _length = 6;
  static const int _resendSeconds = 30;

  Timer? _timer;
  int _remaining = _resendSeconds;
  String _otp = '';
  int _otpWidgetKey = 0;
  String? _error;
  bool _resent = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _maskedMobile {
    final m = widget.mobileNumber;
    if (m.length < 4) return m;
    return '${'X' * (m.length - 4)}${m.substring(m.length - 4)}';
  }

  void _startTimer() {
    _timer?.cancel();
    _remaining = _resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _remaining--);
      if (_remaining <= 0) t.cancel();
    });
  }

  void _onOtpChanged(String otp) {
    setState(() {
      _otp = otp;
      _error = null;
    });
  }

  void _verify(EnquiryOtpCubit cubit) {
    if (_otp.length != _length) return;
    FocusScope.of(context).unfocus();
    cubit.verifyOtp(otp: _otp, tenantId: widget.tenantId);
  }

  Future<void> _resend(EnquiryOtpCubit cubit) async {
    setState(() => _error = null);
    final sent = await cubit.sendOtp(
      mobileNumber: widget.mobileNumber,
      tenantId: widget.tenantId,
    );
    if (!mounted || !sent) return;
    setState(() {
      _otp = '';
      _otpWidgetKey++; // rebuilds (clears) the OTP boxes, as on the login screen
      _resent = true;
    });
    _startTimer();
  }

  String _format(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
      '${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EnquiryOtpCubit>();
    return BlocConsumer<EnquiryOtpCubit, EnquiryOtpState>(
      listener: (context, state) {
        if (state is EnquiryOtpVerified) {
          Navigator.of(context).pop(true);
        } else if (state is EnquiryOtpVerifyError) {
          setState(() {
            _error = state.errorMessage;
            _resent = false;
          });
        } else if (state is EnquiryOtpSendError) {
          // Only reachable from "Resend OTP" (the first send is handled by the
          // form page before this sheet opens).
          setState(() {
            _error = state.errorMessage;
            _resent = false;
          });
        }
      },
      builder: (context, state) {
        final isVerifying = state is EnquiryOtpVerifying;
        final isResending = state is EnquiryOtpSending;
        final isBusy = isVerifying || isResending;
        final infoStyle = TextStyle(
          fontFamily: 'GeneralSans',
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          height: 1.65,
          letterSpacing: -0.14,
        );
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    AuthHeader(
                      heading: 'Verify Your Mobile Number',
                      description:
                          'Enter the 6-digit OTP sent to your mobile number '
                          '$_maskedMobile',
                      descriptionHighlight: _maskedMobile,
                      topSpacing: 24.h,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        onPressed:
                            isBusy ? null : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OtpInputField(
                        key: ValueKey(_otpWidgetKey),
                        length: _length,
                        onCompleted: _onOtpChanged,
                        onChanged: _onOtpChanged,
                      ),
                      if (_error != null || _resent) ...[
                        SizedBox(height: 12.h),
                        Text(
                          _error ?? 'A new OTP has been sent.',
                          textAlign: TextAlign.center,
                          style: infoStyle.copyWith(
                            fontSize: 12.sp,
                            color:
                                _error != null
                                    ? const Color(0xFFFFB4AB)
                                    : Colors.white,
                          ),
                        ),
                      ],
                      SizedBox(height: 24.h),
                      Text(
                        _format(_remaining < 0 ? 0 : _remaining),
                        textAlign: TextAlign.center,
                        style: infoStyle,
                      ),
                      SizedBox(height: 40.h),
                      WhiteButton(
                        isLoading: isVerifying,
                        label: 'Verify OTP',
                        borderRadius: 10,
                        height: 52.h,
                        textColor: AppColor.kPrimaryColor,
                        onClicked:
                            _otp.length == _length && !isBusy
                                ? () => _verify(cubit)
                                : null,
                      ),
                      SizedBox(height: 24.h),
                      if (_remaining <= 0)
                        Center(
                          child: TextButton(
                            onPressed: isBusy ? null : () => _resend(cubit),
                            child:
                                isResending
                                    ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
