import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/pages/faq/railwire_faq_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class _FakeClient extends DioClient {
  _FakeClient(this.response);

  final Map<String, dynamic> response;
  String? url;
  Map<String, dynamic>? query;

  @override
  Future<Map<String, dynamic>> getRailwire(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    this.url = url;
    query = queryParameters;
    return response;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<_FakeClient> client(Map<String, dynamic> response) async {
    final fake = _FakeClient(response);
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
  });

  test('loads the state FAQs and skips ones without a question', () async {
    final fake = await client({
      'STATUS': true,
      'data': {
        'status': true,
        'Message': '',
        'faqs_list': [
          {'question': ' Error 678 ', 'answer': 'Check the cable.'},
          {'question': '', 'answer': 'orphan'},
        ],
      },
    });

    final result = await RailwireFaqRepository.fetch();
    final faqs = result.fold((l) => fail(l.message), (r) => r);

    expect(fake.url, 'Newsubapp_api/faqdetails');
    expect(fake.query, {'stcode': 'ka.railwire.co.in'});
    expect(faqs, hasLength(1));
    expect(faqs.single.question, 'Error 678');
    expect(faqs.single.category, '');
  });

  test('shows the API error', () async {
    await client({'STATUS': false, 'msg': 'Something went wrong!'});

    final result = await RailwireFaqRepository.fetch();

    expect(result.fold((l) => l.message, (_) => ''), 'Something went wrong!');
  });

  test('a network error is a failure, not a crash', () async {
    final fake = _ThrowingClient();
    await sl.reset();
    sl.registerSingleton<DioClient>(fake);

    final result = await RailwireFaqRepository.fetch();

    expect(result.isLeft(), isTrue);
  });
}

class _ThrowingClient extends DioClient {
  @override
  Future<Map<String, dynamic>> getRailwire(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async => throw DioException(requestOptions: RequestOptions(path: url));
}
