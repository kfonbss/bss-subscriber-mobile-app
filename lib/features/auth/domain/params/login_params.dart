class LoginParams {
  final String userName;
  final String password;
  final String tenantId;

  const LoginParams({required this.userName, required this.password, required this.tenantId});

  Map<String, dynamic> toMap() {
    return {'username': userName, 'password': password, 'tenantId': tenantId};
  }
}
