import 'package:kfon_subscriber/features/auth/domain/entity/auth_entity.dart';
import 'package:kfon_subscriber/features/profile/domain/entity/profile_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  const Authenticated();
}

class LoadSelectedTenantSuccess extends AuthState {
  final String tenantName;
  final String tenantId;

  const LoadSelectedTenantSuccess({
    required this.tenantName,
    required this.tenantId,
  });

  @override
  List<Object?> get props => [tenantName, tenantId];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class LoginSuccess extends AuthState {
  final AuthEntity user;

  const LoginSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class LoginFailure extends AuthState {
  final String errorMessage;

  const LoginFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class OtpSent extends AuthState {
  final String mobileNumber;

  const OtpSent({required this.mobileNumber});

  @override
  List<Object?> get props => [mobileNumber];
}

class OtpSendError extends AuthState {
  final String errorMessage;

  const OtpSendError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

/// Emitted when a *resend* succeeds on the login-OTP screen. Deliberately
/// separate from [LoginSuccess] — LoginPage listens for LoginSuccess to
/// navigate to the OTP screen, and LoginPage is still mounted underneath
/// OtpVerificationPage, so reusing LoginSuccess for resend re-triggered
/// that navigation and pushed a duplicate OtpVerificationPage.
class OtpResendSuccess extends AuthState {
  final AuthEntity user;

  const OtpResendSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Emitted when a *resend* succeeds on the forgot-password OTP screen.
/// Deliberately separate from [OtpSent] for the same reason as
/// [OtpResendSuccess] above — ForgotPasswordPage listens for OtpSent.
class ForgotPasswordOtpResent extends AuthState {
  final String mobileNumber;

  const ForgotPasswordOtpResent({required this.mobileNumber});

  @override
  List<Object?> get props => [mobileNumber];
}

class OtpVerified extends AuthState {
  const OtpVerified();
}

class ForgotPasswordOtpVerified extends AuthState {
  const ForgotPasswordOtpVerified();
}

class OtpVerificationFailed extends AuthState {
  final String errorMessage;

  const OtpVerificationFailed({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess();
}

class PasswordResetError extends AuthState {
  final String errorMessage;

  const PasswordResetError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class LogoutLoading extends AuthState {
  const LogoutLoading();
}

class LogoutSuccess extends AuthState {
  const LogoutSuccess();
}

class LogoutFailure extends AuthState {
  final String errorMessage;

  const LogoutFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
