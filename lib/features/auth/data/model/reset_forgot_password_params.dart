class ResetForgotPasswordParams {
  final String username;
  final String newPassword;
  final String confirmPassword;

  ResetForgotPasswordParams({
    required this.username,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
