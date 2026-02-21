import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';

import 'interceptors.dart';

class DioClient {
  late final Dio _dio;

  DioClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiUrls.baseURL,
          // contentType: 'multipart/form-data',
          // headers: {'Content-Type': 'application/json; charset=UTF-8'},
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      )..interceptors.addAll([LoggerInterceptor()]);

  // GET METHOD
  Future<APIResponse> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return APIResponse.fromJson(response.data);
    } catch (e) {
      //  rethrow;
      return APIResponse.fromError(e);
    }
  }

  // POST METHOD
  Future<APIResponse> post(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.post(
        url,
        data: data,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return APIResponse.fromJson(response.data);
    } catch (e) {
      print('Remya: $e');
      return APIResponse.fromError(e);
    }
  }

  // PUT METHOD
  Future<APIResponse> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return APIResponse.fromJson(response.data);
    } catch (e) {
      //  rethrow;
      return APIResponse.fromError(e);
    }
  }

  // DELETE METHOD
  Future<dynamic> delete(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final Response response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // PATCH METHOD
  Future<APIResponse> patch(
      String url, {
        data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) async {
    try {
      final Response response = await _dio.patch(
        url,
        data: data,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return APIResponse.fromJson(response.data);
    } catch (e) {
      return APIResponse.fromError(e);
    }
  }
  // DOWNLOAD METHOD
  Future<APIResponse> download(
    String url,
    String downloadPath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await Dio().download(
        url,
        downloadPath,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': null,
          },
        ),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return APIResponse.fromJson(response.data);
    } catch (e) {
      return APIResponse.fromError(e);
    }
  }
}
