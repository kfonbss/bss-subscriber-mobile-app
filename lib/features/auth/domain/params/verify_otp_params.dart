class VerifyOtpParams {
  final String otpRefId;
  final String otp;

  const VerifyOtpParams({required this.otpRefId, required this.otp});

  Map<String, dynamic> toMap() {
    return {'otpReferenceId': otpRefId, 'otp': otp};
  }
}
