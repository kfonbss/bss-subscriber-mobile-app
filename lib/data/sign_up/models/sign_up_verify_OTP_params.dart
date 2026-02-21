class SignUpVerifyOtpParams{
  final String mobile;
  final String otp;

  SignUpVerifyOtpParams({required this.mobile, required this.otp});

  Map<String, dynamic> toMap() {
    return {
      'mobile': mobile,
      'otp': otp
    };
  }
}