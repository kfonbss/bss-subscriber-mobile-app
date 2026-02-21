class SetNewPasswordParams{
  final String userName;
  final String password;

  SetNewPasswordParams({required this.userName, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'username': userName,
      'newPassword': password
    };
  }
}