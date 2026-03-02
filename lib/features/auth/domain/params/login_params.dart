class LoginParams {
  final String userName;
  final String password;

  const LoginParams({required this.userName, required this.password});

  Map<String, dynamic> toMap() {
    return {'username': userName, 'password': password};
  }
}
