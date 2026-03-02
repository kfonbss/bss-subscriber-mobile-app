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

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Event: User requests to send OTP for login verification
class SendOtpRequested extends AuthEvent {
  final String mobileNumber;

  const SendOtpRequested({required this.mobileNumber});

  @override
  List<Object?> get props => [mobileNumber];
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
