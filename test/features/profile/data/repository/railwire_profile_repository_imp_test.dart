import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/profile/data/repository/railwire_profile_repository_imp.dart';
import 'package:kfon_subscriber/features/profile/domain/params/change_password_params.dart';
import 'package:kfon_subscriber/service_locator.dart';

/// Answers each RailWire URL with its own response and records the requests.
class _FakeClient extends DioClient {
  _FakeClient(this.responses);

  final Map<String, Map<String, dynamic>> responses;
  final requests = <String, dynamic>{};
  final sensitive = <String, bool>{};

  @override
  Future<Map<String, dynamic>> postRailwire(
    String url, {
    dynamic data,
    bool sensitive = false,
  }) async {
    requests[url] = data;
    this.sensitive[url] = sensitive;
    return responses[url] ?? {'STATUS': false, 'msg': 'unexpected $url'};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const login = 'Newsubapp_api/userlogin';
  const update = 'Newsubapp_api/subscriber_update_password';
  const params = ChangePasswordParams(
    oldPassword: 'old-pw',
    newPassword: 'new-pw',
    confirmPassword: 'new-pw',
  );

  late RailwireProfileRepositoryImp repository;

  Future<_FakeClient> client(
    Map<String, Map<String, dynamic>> responses,
  ) async {
    final fake = _FakeClient(responses);
    await sl.reset();
    sl.registerSingleton<DioClient>(fake);
    return fake;
  }

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    dotenv.loadFromString(envString: 'BASE_URL=https://existing.example/api/');
    await PreferenceUtils.setRailwireUser(
      '{"username": "ka.user", "subscriberid": "1001", "stcode": "ka.railwire.co.in"}',
    );
    repository = RailwireProfileRepositoryImp();
  });

  test(
    'checks the current password, then updates the portal password',
    () async {
      final fake = await client({
        login: {
          'STATUS': true,
          'data': {'status': true, 'username': 'ka.user'},
        },
        update: {
          'STATUS': true,
          'data': {'status': true, 'Message': 'Password has been updated'},
        },
      });

      final result = await repository.changePortalPassword(params);

      expect(result.isRight(), isTrue);
      expect(fake.requests[login], {
        'username': 'ka.user',
        'password': 'old-pw',
      });
      expect(fake.requests[update], {
        'stcode': 'ka.railwire.co.in',
        'username': 'ka.user',
        'changepasswordfor': 'Bill',
        'newpassword': 'new-pw',
      });
      expect(fake.sensitive[login], isTrue);
      expect(fake.sensitive[update], isTrue);
    },
  );

  test('a wrong current password changes nothing', () async {
    final fake = await client({
      login: {'STATUS': false, 'msg': 'Invalid Username/Password'},
    });

    final result = await repository.changePortalPassword(params);

    expect(
      result.fold((l) => l.message, (_) => ''),
      'Current password is incorrect.',
    );
    expect(fake.requests.containsKey(update), isFalse);
  });
}
