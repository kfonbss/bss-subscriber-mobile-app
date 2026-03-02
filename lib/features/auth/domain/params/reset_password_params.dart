class ResetPasswordParams {
  final String username;
  final String newPassword;
  final String confirmPassword;
  final String token;

  const ResetPasswordParams({
    required this.username,
    required this.newPassword,
    required this.confirmPassword,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
      'token': token,
    };
  }
}
