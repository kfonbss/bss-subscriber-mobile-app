import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String otpRefId;
  final String mobile;
  final String loginSessionToken;

  const AuthEntity({
    required this.otpRefId,
    required this.mobile,
    required this.loginSessionToken
  });

  @override
  List<Object?> get props => [
    otpRefId,
    mobile,
    loginSessionToken
  ];
}