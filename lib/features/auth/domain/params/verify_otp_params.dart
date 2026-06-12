class VerifyOtpParams {
  final String otpRefId;
  final String otp;
  final String? loginSessionToken;

  const VerifyOtpParams({required this.otpRefId, required this.otp, this.loginSessionToken});

  Map<String, dynamic> toMap() {
    return {'otpRefId': otpRefId, 'otp': otp, 'loginSessionToken': loginSessionToken};
  }
}
