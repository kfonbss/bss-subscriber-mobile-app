class ForgotPasswordVerifyOtpParams{
  final String mobile;
  final String email;
  final String otp;

  ForgotPasswordVerifyOtpParams({required this.mobile, required this.email, required this.otp});

  Map<String, dynamic> toMap() {
    return {
      'mobile': mobile,
      'email': email,
      'otp': otp
    };
  }
}