import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';

/// Obtains the RailWire service token. This is an app-level login with fixed
/// credentials, separate from the subscriber's own login.
class RailwireAuth {
  static const _username = 'railrest';
  static const _password = 'railrest123';

  static const authScheme = 'Bearer';

  /// Has no interceptors, so the login and the retried requests can't re-enter
  /// [RailwireAuthInterceptor].
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiUrls.railwireBaseURL,
      responseType: ResponseType.json,
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static Future<String>? _login;

  /// The stored token while it's valid, otherwise a new one. Concurrent callers
  /// share one login. [rejected] is a token the server refused with a 401.
  static Future<String> token({String? rejected}) async {
    final stored = await PreferenceUtils.getRailwireToken();
    if (stored != null &&
        stored != rejected &&
        !await PreferenceUtils.isRailwireTokenExpired()) {
      return stored;
    }
    return _login ??= _authenticate().whenComplete(() => _login = null);
  }

  static Future<String> _authenticate() async {
    final response = await dio.post(
      ApiUrls.railwireLoginURL,
      data: {'username': _username, 'password': _password},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {'Accept': 'application/json'},
      ),
    );
    final token = response.data['token'] as String;
    await PreferenceUtils.saveRailwireToken(
      token: token,
      expiryAt: _expiryAt(token),
    );
    return token;
  }

  /// The login response has no expiry field, so it's read from the JWT's `exp`.
  static int _expiryAt(String token) {
    final payload = base64Url.normalize(token.split('.')[1]);
    final claims = jsonDecode(utf8.decode(base64Url.decode(payload)));
    return (claims['exp'] as int) * 1000;
  }
}

/// Replaces [AuthInterceptor] when [ApiUrls.isRailwire] is true.
class RailwireAuthInterceptor extends Interceptor {
  static const _sentTokenKey = 'railwireToken';

  void _attachToken(RequestOptions options, String token) {
    options.extra[_sentTokenKey] = token;
    options.headers['Authorization'] = '${RailwireAuth.authScheme} $token';
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      _attachToken(options, await RailwireAuth.token());
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

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    final options = err.requestOptions;
    try {
      final token = await RailwireAuth.token(
        rejected: options.extra[_sentTokenKey] as String?,
      );
      _attachToken(options, token);
      final data = options.data;
      if (data is FormData) options.data = data.clone();
      // Sent through the interceptor-free client, so it's only retried once.
      return handler.resolve(await RailwireAuth.dio.fetch(options));
    } on DioException catch (e) {
      return handler.next(e);
    } catch (_) {
      return handler.next(err);
    }
  }
}
