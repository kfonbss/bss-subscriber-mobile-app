import 'package:dio/dio.dart';

class APIResponse {
  final String status;
  final dynamic data;
  final String message;

  APIResponse({required this.status, this.data, required this.message});

  factory APIResponse.fromJson(Map<String, dynamic> json) => APIResponse(
    status: json['status'] ?? 'error',
    data: json['data'],
    message: json['message'] ?? '',
  );

  factory APIResponse.fromError(dynamic error) {
    if (error is DioException) {
      return APIResponse(
        status: 'error',
        data: error.response,
        message: _handleDioError(error),
      );
    } else {
      return APIResponse(status: 'error', message: 'An error occurred.');
    }
  }

  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout, please try again.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout, please check your internet.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout, please try again.';
      case DioExceptionType.badResponse:
        return _handleServerError(error.response);
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Unknown error occurred';
    }
  }

  static String _handleServerError(Response? response) {
    print(response?.data.toString());
    if (response == null) return 'No response from server';
    if (response.data is Map<String, dynamic>) {
      return response.data['message'] ?? 'An error occurred.';
    }
    return 'Server error : ${response.statusMessage}';
  }
}
