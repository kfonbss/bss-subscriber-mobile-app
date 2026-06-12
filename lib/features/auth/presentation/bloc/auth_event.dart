import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  final String tenantId;

  const LoginRequested({required this.username, required this.password, required this.tenantId});

  @override
  List<Object?> get props => [username, password];
}

class LoadSelectedTenant extends AuthEvent {
  const LoadSelectedTenant();
}
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
class ResendOTP extends AuthEvent {
  final String loginSessionToken;

  const ResendOTP({required this.loginSessionToken});

  @override
  List<Object?> get props => [loginSessionToken];
}
/// Event: User requests to send OTP for forgot password
class SendForgotPasswordOtpRequested extends AuthEvent {
  final String username;

  const SendForgotPasswordOtpRequested({required this.username});

  @override
  List<Object?> get props => [username];
}

/// Event: User requests to verify OTP both login
class VerifyOtpRequested extends AuthEvent {
  final String otp;

  const VerifyOtpRequested({required this.otp});

  @override
  List<Object?> get props => [otp];
}

/// Event: User requests to verify OTP for forgot password
class VerifyForgotPasswordOtpRequested extends AuthEvent {
  final String otp;

  const VerifyForgotPasswordOtpRequested({required this.otp});

  @override
  List<Object?> get props => [otp];
}

class ResetPasswordRequested extends AuthEvent {
  final String username;
  final String newPassword;

  const ResetPasswordRequested({
    required this.username,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [username, newPassword];
}
