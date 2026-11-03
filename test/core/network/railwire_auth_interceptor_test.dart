import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/core/network/interceptors/railwire_auth_interceptor.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';

String _jwt(int id, {Duration ttl = const Duration(hours: 5)}) {
  String encode(Map<String, dynamic> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final exp = DateTime.now().add(ttl).millisecondsSinceEpoch ~/ 1000;
  return '${encode({'alg': 'HS256'})}.${encode({'id': id, 'exp': exp})}.sig';
}

/// Answers login and API calls; API calls get a 401 for any token in [revoked].
class _FakeServer implements HttpClientAdapter {
  final Set<String> revoked = {};
  final List<RequestOptions> apiRequests = [];
  final List<String> loginBodies = [];
  int loginStatus = 200;
  int logins = 0;
  String lastToken = '';

  ResponseBody _json(Object body, int status) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    if (options.path == 'auth/login') {
      logins++;
      loginBodies.add(
        utf8.decode(await requestStream!.expand((b) => b).toList()),
      );
      if (loginStatus != 200) return _json({'error': 'no'}, loginStatus);
      lastToken = _jwt(logins);
      return _json({'token': lastToken}, 200);
    }
    apiRequests.add(options);
    final token = '${options.headers['Authorization']}'.split(' ').last;
    return _json({'ok': true}, revoked.contains(token) ? 401 : 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _FakeServer server;
  late Dio client;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    server = _FakeServer();
    RailwireAuth.dio.httpClientAdapter = server;
    client = Dio(BaseOptions(baseUrl: 'https://railwire.test/'))
      ..httpClientAdapter = server
      ..interceptors.add(RailwireAuthInterceptor());
  });

  test('logs in with the fixed credentials, stores and sends the token', () async {
    await client.get('a');

    expect(server.logins, 1);
    expect(server.loginBodies.single, 'username=railrest&password=railrest123');
    expect(await PreferenceUtils.getRailwireToken(), server.lastToken);
    expect(
      server.apiRequests.single.headers['Authorization'],
      'Bearer ${server.lastToken}',
    );
  });

  test('reuses a valid stored token', () async {
    await client.get('a');
    await client.get('b');

    expect(server.logins, 1);
    expect(server.apiRequests, hasLength(2));
  });

  test('logs in again when the stored token is close to expiry', () async {
    await PreferenceUtils.saveRailwireToken(
      token: 'old',
      expiryAt: DateTime.now().millisecondsSinceEpoch + 60 * 1000,
    );

    await client.get('a');

    expect(server.logins, 1);
    expect(await PreferenceUtils.getRailwireToken(), server.lastToken);
  });

  test('concurrent requests share one login', () async {
    await Future.wait(List.generate(8, (i) => client.get('r$i')));

    expect(server.logins, 1);
    expect(server.apiRequests, hasLength(8));
  });

  test('a 401 re-authenticates once and retries the request', () async {
    await client.get('a');
    server.revoked.add(server.lastToken);
    server.apiRequests.clear();

    final response = await client.get('a');

    expect(response.statusCode, 200);
    expect(server.logins, 2);
    expect(server.apiRequests, hasLength(2));
  });

  test('concurrent 401s share one re-authentication', () async {
    await client.get('a');
    server.revoked.add(server.lastToken);

    await Future.wait(List.generate(8, (i) => client.get('r$i')));

    expect(server.logins, 2);
  });

  test('a repeated 401 fails without retrying again', () async {
    final refusing = _AlwaysUnauthorized(server);
    client.httpClientAdapter = refusing;
    RailwireAuth.dio.httpClientAdapter = refusing;

    await expectLater(client.get('a'), throwsA(isA<DioException>()));

    expect(server.logins, 2);
    expect(refusing.apiCalls, 2);
  });

  test('a failed login rejects the request and can recover', () async {
    server.loginStatus = 500;
    await expectLater(client.get('a'), throwsA(isA<DioException>()));
    expect(server.apiRequests, isEmpty);

    server.loginStatus = 200;
    final response = await client.get('a');
    expect(response.statusCode, 200);
  });
}

/// Passes logins to [server] and refuses every API call.
class _AlwaysUnauthorized implements HttpClientAdapter {
  _AlwaysUnauthorized(this.server);

  final _FakeServer server;
  int apiCalls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (options.path == 'auth/login') {
      return server.fetch(options, requestStream, cancelFuture);
    }
    apiCalls++;
    return Future.value(ResponseBody.fromString('{}', 401));
  }

  @override
  void close({bool force = false}) {}
}
