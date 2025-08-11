class ForgotPasswordGetOtpParams{
  final String mobile;
  final String email;

  ForgotPasswordGetOtpParams({required this.mobile, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'mobile': mobile,
      'email': email
    };
  }
}