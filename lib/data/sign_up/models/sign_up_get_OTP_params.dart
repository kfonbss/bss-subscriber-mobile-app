class SignUpGetOtpParams{
  final String mobile;
  final String name;
  final String password;

  SignUpGetOtpParams({required this.name, required this.mobile, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'mobile': mobile,
      'name': name,
      'password': password
    };
  }
}