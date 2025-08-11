class SetNewPasswordParams{
  final String userId;
  final String password;

  SetNewPasswordParams({required this.userId, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': password
    };
  }
}