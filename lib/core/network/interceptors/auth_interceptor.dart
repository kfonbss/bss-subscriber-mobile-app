import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/routes/navigator_key.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/auth/domain/repository/auth_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

/// Interceptor that handles authentication token management
/// and automatically refreshes token before expiry.
class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  /// Cached repository — resolved lazily to avoid circular dependency
  /// (DioClient → AuthInterceptor → AuthRepository → DioClient).
  AuthRepository? _authRepository;

  AuthRepository get _repository => _authRepository ??= sl<AuthRepository>();

  static List<String> get _publicEndpoints => [
    ApiUrls.tenantsURL,
    ApiUrls.loginURL,
    ApiUrls.resendOTPURL,
    ApiUrls.sendForgotPasswordOTPURL,
    ApiUrls.verifyOTPURL,
    ApiUrls.resetForgotPasswordURL,
    ApiUrls.refreshTokenURL,
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tenantId = await PreferenceUtils.getTenantId();
    options.headers['X-Tenant-ID'] = '$tenantId';
    final isPublicEndpoint = _publicEndpoints.contains(options.path);

    try {
      if (!isPublicEndpoint) {
        await _ensureValidToken();
        await _attachAuthHeader(options);
      }
      return handler.next(options);
    } catch (e) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  /// Ensures we have a valid token
  Future<void> _ensureValidToken() async {
    final isExpired = await PreferenceUtils.isTokenExpired();

    if (isExpired) {
      if (_isRefreshing) {
        // Wait for ongoing refresh to complete
        await _refreshCompleter?.future;
      } else {
        // Start new refresh
        await _refreshToken();
      }
    }
  }

  Future<void> _attachAuthHeader(RequestOptions options) async {
    final token = await PreferenceUtils.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<void> _refreshToken() async {
    _isRefreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      final refreshToken = await _getValidRefreshToken();
      if (refreshToken == null) {
        // _handleRefreshFailure already called inside _getValidRefreshToken.
        // Complete so that any concurrent request waiting on the completer
        // is unblocked (it will fail on its own next interceptor pass).
        _refreshCompleter?.complete();
        return;
      }

      await _callRefreshApi(refreshToken);

      _refreshCompleter?.complete();
    } catch (e) {
      await _handleRefreshFailure();
      _refreshCompleter?.completeError(e);
    } finally {
      // Safety net: if the completer was somehow left incomplete, unblock waiters.
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete();
      }
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  Future<String?> _getValidRefreshToken() async {
    final refreshToken = await PreferenceUtils.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await _handleRefreshFailure();
      return null;
    }

    return refreshToken;
  }

  /// Calls the refresh token API and saves new tokens
  Future<void> _callRefreshApi(String refreshToken) async {
    final result = await _repository.refreshToken(refreshToken);
    await result.fold(
      (error) => _handleRefreshFailure(),
      (authModel) => _saveNewTokens(authModel),
    );
  }

  Future<void> _saveNewTokens(authModel) async {
    await PreferenceUtils.saveAllTokens(
      accessToken: authModel.token,
      refreshToken: authModel.refreshToken,
      expiresIn: authModel.expiresIn,
    );
  }

  /// Handles refresh failure by clearing all tokens and redirecting to login
  Future<void> _handleRefreshFailure() async {
    await PreferenceUtils.clearAll();

    // Navigate to login and clear navigation stack
    // navigatorKey.currentState?.pushNamedAndRemoveUntil(
    //   AppRoutes.login,
    //   (route) => false,
    // );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    });
  }
}
