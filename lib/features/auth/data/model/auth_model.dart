import 'package:kfon_subscriber/features/auth/domain/entity/auth_entity.dart';

class AuthModel {
  final String otpRefId;
  final String mobile;
  final String loginSessionToken;

  AuthModel({
    required this.otpRefId,
    required this.mobile,
    required this.loginSessionToken
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      otpRefId: json['otpRefId'] as String,
      mobile: json['mobile'] as String,
      loginSessionToken: json['loginSessionToken'] as String,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otpRefId': otpRefId,
      'mobile': mobile,
      'loginSessionToken': loginSessionToken
    };
  }

  AuthEntity toEntity() {
    return AuthEntity(
        otpRefId: otpRefId,
        mobile: mobile,
        loginSessionToken: loginSessionToken
    );
  }

}
