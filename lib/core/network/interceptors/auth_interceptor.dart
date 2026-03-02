import 'dart:async';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/routes/navigator_key.dart';
import 'package:kfon_subscriber/features/auth/domain/repository/auth_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';

/// Interceptor that handles authentication token management
/// and  Automatically refreshes token before expiry
class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  static List<String> get _publicEndpoints => [
    ApiUrls.loginURL,
    ApiUrls.sendOTPURL,
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
    final isPublicEndpoint = _publicEndpoints.contains(options.path);

    if (!isPublicEndpoint) {
      await _ensureValidToken();
      await _attachAuthHeader(options);
    }

    return handler.next(options);
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

    debugPrint('authTest token: $token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<void> _refreshToken() async {
    _isRefreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      final refreshToken = await _getValidRefreshToken();

      if (refreshToken == null) return;

      await _callRefreshApi(refreshToken);

      // Complete successfully
      _refreshCompleter?.complete();
    } catch (e) {
      await _handleRefreshFailure();
      // Complete with error
      _refreshCompleter?.completeError(e);
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  Future<String?> _getValidRefreshToken() async {
    final refreshToken = await PreferenceUtils.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      _handleRefreshFailure();
      return null;
    }

    return refreshToken;
  }

  /// Calls the refresh token API and saves new tokens
  Future<void> _callRefreshApi(String refreshToken) async {
    final authRepository = sl<AuthRepository>();
    final result = await authRepository.refreshToken(refreshToken);

    result.fold(
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
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }
}
