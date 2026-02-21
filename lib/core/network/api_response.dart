import 'package:dio/dio.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:flutter/material.dart';

class APIResponse {
  final dynamic data;
  final String message;
  final String error;
  final Failure? _failure;

  APIResponse({
    this.data,
    required this.message,
    required this.error,
    Failure? failure,
  }) : _failure = failure;

  /// Returns true if the response has no error
  bool get isSuccess => error.isEmpty;

  /// Returns true if the response has an error
  bool get hasError => error.isNotEmpty;

  /// Returns the appropriate Failure type based on the error
  Failure get failure =>
      _failure ?? ServerFailure(error.isNotEmpty ? error : message);

  factory APIResponse.fromJson(Map<String, dynamic> response) {
    String error = '';
    if (response['error'] != null) {
      if (response['error'] is bool) {
        error = (response['error'] as bool)
            ? (response['message']?.toString() ?? 'An error occurred')
            : '';
      } else {
        error = response['error'].toString();
      }
    }

    return APIResponse(
      data: response['data'],
      message: response['message']?.toString() ?? '',
      error: error,
    );
  }

  factory APIResponse.fromError(dynamic error) {
    Failure failure;
    String errorMessage = 'An error occurred.';

    if (error is DioException) {
      final result = _handleDioError(error);
      errorMessage = result.message;
      failure = result.failure;
    } else {
      failure = UnknownFailure(errorMessage);
    }

    debugPrint('APIResponse Error: $errorMessage');
    return APIResponse(
      data: '',
      message: '',
      error: errorMessage,
      failure: failure,
    );
  }

  static ({String message, Failure failure}) _handleDioError(
    DioException error,
  ) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return (
          message: 'Connection timeout, please try again.',
          failure: const TimeoutFailure(
            'Connection timeout, please try again.',
          ),
        );
      case DioExceptionType.sendTimeout:
        return (
          message: 'Send timeout, please check your internet.',
          failure: const TimeoutFailure(
            'Send timeout, please check your internet.',
          ),
        );
      case DioExceptionType.receiveTimeout:
        return (
          message: 'Receive timeout, please try again.',
          failure: const TimeoutFailure('Receive timeout, please try again.'),
        );
      case DioExceptionType.badResponse:
        final result = _handleServerError(error.response);
        return (message: result.message, failure: result.failure);
      case DioExceptionType.cancel:
        return (
          message: 'Request was cancelled.',
          failure: const ServerFailure('Request was cancelled.'),
        );
      case DioExceptionType.connectionError:
        return (
          message: 'No internet connection.',
          failure: const NetworkFailure(),
        );
      default:
        return (
          message: 'Unknown error occurred',
          failure: const UnknownFailure(),
        );
    }
  }

  static ({String message, Failure failure}) _handleServerError(
    Response? response,
  ) {
    if (response == null) {
      return (
        message: 'No response from server',
        failure: const ServerFailure('No response from server'),
      );
    }

    String errorMessage = 'An error occurred.';
    int? statusCode = response.statusCode;

    if (response.data is Map<String, dynamic>) {
      final message = response.data['message'];
      final error = response.data['error'];

      if (message != null && message.toString().isNotEmpty) {
        errorMessage = message.toString();
      } else if (error != null && error.toString().isNotEmpty) {
        errorMessage = error.toString();
      }
    } else {
      errorMessage = 'Server error: ${response.statusMessage}';
    }

    // Return appropriate failure type based on status code
    if (statusCode == 401 || statusCode == 403) {
      return (message: errorMessage, failure: AuthFailure(errorMessage));
    }

    return (
      message: errorMessage,
      failure: ServerFailure(errorMessage, statusCode: statusCode),
    );
  }
}
