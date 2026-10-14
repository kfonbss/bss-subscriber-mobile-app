import 'package:dio/dio.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:flutter/foundation.dart';
import 'package:kfon_subscriber/core/error/failure.dart';

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
    final rawError = response['error'];
    // An empty object/string (e.g. `"error": {}`) means "no error".
    final isEmptyError =
        (rawError is Map && rawError.isEmpty) ||
        (rawError is String && rawError.trim().isEmpty);
    if (rawError != null && !isEmptyError) {
      if (response['error'] is bool) {
        error =
            (response['error'] as bool)
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

    return APIResponse(
      data: null,
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
          message: appL10n.connectionTimeoutPleaseTryAgain,
          failure: TimeoutFailure(appL10n.connectionTimeoutPleaseTryAgain),
        );
      case DioExceptionType.sendTimeout:
        return (
          message: appL10n.sendTimeoutPleaseCheckInternet,
          failure: TimeoutFailure(appL10n.sendTimeoutPleaseCheckInternet),
        );
      case DioExceptionType.receiveTimeout:
        return (
          message: appL10n.receiveTimeoutPleaseTryAgain,
          failure: TimeoutFailure(appL10n.receiveTimeoutPleaseTryAgain),
        );
      case DioExceptionType.badResponse:
        final result = _handleServerError(error.response);
        return (message: result.message, failure: result.failure);
      case DioExceptionType.cancel:
        return (
          message: appL10n.requestWasCancelled,
          failure: ServerFailure(appL10n.requestWasCancelled),
        );
      case DioExceptionType.connectionError:
        final message =
            kIsWeb
                ? appL10n.unableToReachServerWeb
                : appL10n.noInternetConnection;
        return (message: message, failure: NetworkFailure(message));
      default:
        return (
          message: appL10n.unknownErrorOccurred,
          failure: UnknownFailure(appL10n.unknownErrorOccurred),
        );
    }
  }

  static ({String message, Failure failure}) _handleServerError(
    Response? response,
  ) {
    if (response == null) {
      return (
        message: appL10n.noResponseFromServer,
        failure: ServerFailure(appL10n.noResponseFromServer),
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
