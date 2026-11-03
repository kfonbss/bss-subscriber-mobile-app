import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/auth/data/repository/railwire_auth_repository_imp.dart';
import 'package:kfon_subscriber/features/auth/domain/repository/railwire_auth_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class _FakeClient extends DioClient {
  _FakeClient(this.response);

  final Map<String, dynamic> response;
  dynamic sentData;
  bool? sentSensitive;

  @override
  Future<Map<String, dynamic>> postRailwire(
    String url, {
    dynamic data,
    bool sensitive = false,
  }) async {
    sentData = data;
    sentSensitive = sensitive;
    return response;
  }
}

Map<String, dynamic> _success({String stcode = 'ka.railwire.test'}) => {
  'STATUS': true,
  'data': {
    'status': true,
    'Message': '',
    'stcode': stcode,
    'username': 'ka.user',
    'subscriberid': '1001',
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RailwireAuthRepositoryImp repository;

  Future<dynamic> login(Map<String, dynamic> response) async {
    final client = _FakeClient(response);
    await sl.reset();
    sl.registerSingleton<DioClient>(client);
    final result = await repository.login(username: 'ka.user', password: 'pw');
    expect(client.sentData, {'username': 'ka.user', 'password': 'pw'});
    expect(client.sentSensitive, isTrue);
    return result.fold((failure) => failure.message, (user) => user);
  }

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    dotenv.loadFromString(envString: 'BASE_URL=https://existing.example/api/');
    repository = RailwireAuthRepositoryImp();
  });

  test('success returns the user and saves it unless an OTP follows', () async {
    final user = await login(_success());

    expect(user.subscriberId, '1001');
    expect(
      await PreferenceUtils.getRailwireUser(),
      RailwireAuthRepository.loginOtpEnabled ? isNull : contains('1001'),
    );
  });

  group('login OTP', skip: !RailwireAuthRepository.loginOtpEnabled, () {
    Map<String, dynamic> ok([Map<String, dynamic> data = const {}]) => {
      'STATUS': true,
      'data': {'status': true, 'Message': '', ...data},
    };

    Future<_FakeClient> otpClient(Map<String, dynamic> response) async {
      await login(_success());
      final client = _FakeClient(response);
      await sl.unregister<DioClient>();
      sl.registerSingleton<DioClient>(client);
      return client;
    }

    test('is sent to the test number, not the account mobile', () async {
      final client = await otpClient(ok({'state_code': 'AP'}));

      final result = await repository.sendLoginOtp();

      expect(client.sentData, {'mblno': '8281412765'});
      expect(result.fold((l) => l, (r) => r), '8281412765');
    });

    test('is verified against the test number and its state', () async {
      final client = await otpClient(ok({'state_code': 'AP'}));
      await repository.sendLoginOtp();

      final result = await repository.verifyLoginOtp('1234');

      expect(result.isRight(), isTrue);
      expect(client.sentData, {
        'eamil_or_mblno': '8281412765',
        'stcode': 'AP',
        'otp_number': '1234',
      });
      expect(client.sentSensitive, isTrue);
      expect(await PreferenceUtils.getRailwireUser(), contains('1001'));
    });

    test('falls back to the selected state when none is reported', () async {
      await PreferenceUtils.setTenant('KA', 'Karnataka');
      final client = await otpClient(ok());
      await repository.sendLoginOtp();

      await repository.verifyLoginOtp('1234');

      expect((client.sentData as Map)['stcode'], 'KA');
    });

    test('a wrong OTP saves nothing', () async {
      await otpClient({'STATUS': false, 'msg': 'Entered OTP is Invalid'});

      final result = await repository.verifyLoginOtp('0000');

      expect(result.fold((l) => l.message, (_) => ''), 'Entered OTP is Invalid');
      expect(await PreferenceUtils.getRailwireUser(), isNull);
    });

    test('needs a password login first', () async {
      final result = await repository.sendLoginOtp();

      expect(result.isLeft(), isTrue);
    });
  });

  test('STATUS false shows the API message and saves nothing', () async {
    final message = await login({
      'STATUS': false,
      'msg': 'Invalid Username/Password',
    });

    expect(message, 'Invalid Username/Password');
    expect(await PreferenceUtils.getRailwireUser(), isNull);
  });

  test('data.status false shows the nested message', () async {
    final message = await login({
      'STATUS': true,
      'data': {'status': false, 'Message': 'Account inactive'},
    });

    expect(message, 'Account inactive');
    expect(await PreferenceUtils.getRailwireUser(), isNull);
  });

  test('an account from another state is refused', () async {
    await PreferenceUtils.setTenant(
      'KL',
      'Kerala',
      appUrl: 'https://kl.railwire.test',
    );

    final result = await login(_success());

    expect(result, startsWith('This account belongs to a different circle'));
    expect(await PreferenceUtils.getRailwireUser(), isNull);
  });

  test('the selected state matches regardless of case', () async {
    await PreferenceUtils.setTenant(
      'KA',
      'Karnataka',
      appUrl: 'https://KA.railwire.test',
    );

    final result = await login(_success());

    expect(result, isNot(isA<String>()));
  });

  test('skips the state check when no app_url is saved', () async {
    final result = await login(_success());

    expect(result, isNot(isA<String>()));
  });
}
