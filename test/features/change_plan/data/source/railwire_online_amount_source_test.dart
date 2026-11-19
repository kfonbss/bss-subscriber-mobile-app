import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/change_plan/data/source/railwire_online_amount_source.dart';
import 'package:kfon_subscriber/service_locator.dart';

/// Answers onlineamount with [response] and counts the calls.
class _CountingClient extends DioClient {
  Map<String, dynamic> response = {
    'STATUS': true,
    'data': {'status': true, 'razorpay_enabled': '1', 'razorpayamnt': '824.82'},
  };
  int calls = 0;

  @override
  Future<Map<String, dynamic>> postRailwire(
    String url, {
    dynamic data,
    bool sensitive = false,
  }) async {
    calls++;
    return response;
  }
}

Future<void> _login(String username) => PreferenceUtils.setRailwireUser(
  '{"username": "$username", "subscriberid": "1001", '
  '"stcode": "ka.railwire.co.in"}',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _CountingClient client;
  late DateTime now;
  late RailwireOnlineAmountSource source;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    dotenv.loadFromString(envString: 'BASE_URL=https://existing.example/api/');
    await _login('ka.user');
    client = _CountingClient();
    await sl.reset();
    sl.registerSingleton<DioClient>(client);
    now = DateTime(2026, 11, 19, 10);
    source = RailwireOnlineAmountSource(now: () => now);
  });

  test('calls made together share one request', () async {
    final results = await Future.wait([source.shared(), source.shared()]);

    expect(client.calls, 1);
    expect(results.map((r) => r.amount), [824.82, 824.82]);
  });

  test('the result is reused until it is 30 seconds old', () async {
    await source.shared();
    now = now.add(const Duration(seconds: 29));
    await source.shared();
    expect(client.calls, 1);

    now = now.add(const Duration(seconds: 1));
    await source.shared();
    expect(client.calls, 2);
  });

  test('fetch is always fresh and its result is reused', () async {
    await source.fetch();
    await source.fetch();
    await source.shared();

    expect(client.calls, 2);
  });

  test('clear makes the next call fresh', () async {
    await source.shared();
    source.clear();
    await source.shared();

    expect(client.calls, 2);
  });

  test('a failed call is not reused', () async {
    client.response = {'STATUS': false, 'msg': 'down'};

    final failed = await source.shared();
    await source.shared();

    expect(failed.amount, 0);
    expect(client.calls, 2);
  });

  test('another subscriber never gets this one\'s amount', () async {
    await source.shared();
    await _login('ka.other');
    await source.shared();

    expect(client.calls, 2);
  });
}
