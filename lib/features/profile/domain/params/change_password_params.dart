/// Body of `mobile/change-password` (BSS portal password).
class ChangePasswordParams {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toMap() => {
    'oldPassword': oldPassword,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
}
