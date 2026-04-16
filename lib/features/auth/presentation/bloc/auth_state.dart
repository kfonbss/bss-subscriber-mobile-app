import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/auth_entity.dart';

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

class OtpVerified extends AuthState {
  const OtpVerified();
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
