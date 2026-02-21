import 'package:equatable/equatable.dart';

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
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
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
  const TimeoutFailure([super.message = 'Request timed out']);
}

/// Unknown/Unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred']);
}
