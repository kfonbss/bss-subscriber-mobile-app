import 'dart:developer' as dev;
import 'package:dio/dio.dart';

/// This interceptor is used to show request and response logs
class LoggerInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';

    // Log Error
    _log('❌ ${options.method} request failed ==> $requestPath');
    _log('Error type: ${err.error}');
    _log('Error message: ${err.message}');
    if (err.response != null) {
      _log('Error Response data: ${err.response?.data}');
    }

    handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';

    // Log Request
    _log('🚀 ${options.method} request ==> $requestPath');

    // Log Headers (optional, but sometimes useful. Keep it minimal or remove if "unwanted" implies this)
    // _log('Headers: ${options.headers}');

    // Log Query Parameters
    if (options.queryParameters.isNotEmpty) {
      _log('Query Parameters: ${options.queryParameters}');
    }

    // Log Request Body
    if (options.data != null) {
      // Handle Form Data specifically if needed, but often toString() is enough or jsonEncode
      try {
        if (options.data is FormData) {
          _log('Request Body (FormData): ${options.data.fields}');
        } else {
          _log('Request Body: ${options.data}');
        }
      } catch (e) {
        _log('Request Body: ${options.data}');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';

    // Log Response
    _log('✅ ${response.statusCode} ${options.method} ==> $requestPath');

    // Log Response Data
    _log('Response Data: ${response.data}');

    handler.next(response);
  }

  void _log(String message) {
    // using dart:developer log for standard console output without 3rd party formatting noise if that was the "unwanted" part.
    // However, the previous code used `package:logger`.
    // The user said "remove unwanted logges". The PrettyPrinter in previous code creates box borders.
    // If they want "clean", standard print or developer log is often better than heavy ascii art boxes if the content is large.
    // But sticking to the existing Logger package but configuring it simpler might be safer,
    // OR just simple prints.
    // Given "LoggerInterceptor not properly giving log", maybe the ascii art was truncating or making it hard to read.
    // I will use `print` or `dev.log` to be safe and clean.
    dev.log(message, name: 'DioClient');
    // Or just strictly follow the requested structure.
  }
}
