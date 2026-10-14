import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

/// Base failure class for domain-level error handling
/// All specific failure types should extend this class
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

/// Server-related failures (API errors, HTTP errors)
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Network-related failures (no internet, timeout)
class NetworkFailure extends Failure {
  NetworkFailure([String? message])
    : super(message ?? appL10n.noInternetConnection);
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  CacheFailure([String? message])
    : super(message ?? appL10n.cacheErrorOccurred);
}

/// Authentication failures (invalid credentials, token expired)
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Validation failures (invalid input)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Timeout failures
class TimeoutFailure extends Failure {
  TimeoutFailure([String? message]) : super(message ?? appL10n.requestTimedOut);
}

/// Unknown/Unexpected failures
class UnknownFailure extends Failure {
  UnknownFailure([String? message])
    : super(message ?? appL10n.anUnexpectedErrorOccurred);
}
