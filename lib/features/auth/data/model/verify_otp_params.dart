class VerifyOtpParams {
  final String otpRefId;
  final String otp;

  VerifyOtpParams({required this.otpRefId, required this.otp});

  Map<String, dynamic> toMap() {
    return {'otpReferenceId': otpRefId, 'otp': otp};
  }
}
