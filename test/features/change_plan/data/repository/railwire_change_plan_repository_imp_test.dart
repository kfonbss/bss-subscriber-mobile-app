import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/discount_details_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/change_plan/data/source/railwire_online_amount_source.dart';
import 'package:kfon_subscriber/features/change_plan/data/repository/railwire_change_plan_repository_imp.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/recharge_change_plan_params.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/subscriber_discount_request_params.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/url_redirect_checkout.dart';
import 'package:kfon_subscriber/service_locator.dart';

/// Answers each RailWire URL with its own response and records the requests.
class _FakeClient extends DioClient {
  _FakeClient(this.responses);

  final Map<String, Map<String, dynamic>> responses;
  final requests = <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> postRailwire(
    String url, {
    dynamic data,
    bool sensitive = false,
  }) async {
    requests[url] = data;
    return responses[url] ?? {'STATUS': false, 'msg': 'unexpected $url'};
  }
}

/// [_FakeClient] that also counts the calls per URL.
class _CountingClient extends _FakeClient {
  _CountingClient(super.responses);

  final calls = <String, int>{};

  @override
  Future<Map<String, dynamic>> postRailwire(
    String url, {
    dynamic data,
    bool sensitive = false,
  }) {
    calls[url] = (calls[url] ?? 0) + 1;
    return super.postRailwire(url, data: data, sensitive: sensitive);
  }
}

RechargeChangePlanParams _params(String? gateway) => RechargeChangePlanParams(
  packageId: '104870',
  gateway: gateway,
  amount: 11800,
  expectedFinalAmount: 11800,
  durationDays: 30,
  referral: false,
  useWallet: false,
  changePlan: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const prepare = 'Newsubapp_api/prepare_atom_gate_way';
  const check = 'Newsubapp_api/atom_trans_check';
  const history = 'Newsubapp_api/recharge_history';
  const paymentUrl = 'https://payment.atomtech.in/paynetz/epi/fts?login=1';

  late RailwireChangePlanRepositoryImp repository;

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
    repository = RailwireChangePlanRepositoryImp(
      onlineAmount: RailwireOnlineAmountSource(),
    );
  });

  test('Atom opens the PAYGATEWAY url and returns to RailWire', () async {
    final fake = await client({
      prepare: {
        'STATUS': true,
        'data': {'status': true, 'PAYGATEWAY': paymentUrl},
      },
    });

    final result = await repository.rechargeChangePlan(_params('ATOM'));
    final redirect = result.fold((l) => fail(l.message), (r) => r.redirect!);

    expect(fake.requests[prepare], {
      'stcode': 'ka.railwire.co.in',
      'username': 'ka.user',
    });
    expect(redirect.actionUrl, paymentUrl);
    expect(UrlRedirectCheckout.supports(redirect), isTrue);
    expect(
      UrlRedirectCheckout.isReturn('https://ka.railwire.co.in/x', redirect),
      isTrue,
    );
    expect(UrlRedirectCheckout.isReturn(paymentUrl, redirect), isFalse);
  });

  test('other gateways are not available', () async {
    await client({});

    final result = await repository.rechargeChangePlan(_params('BILLDESK'));

    expect(result.isLeft(), isTrue);
  });

  test('Razorpay sends slno, reports the payment, then checks it', () async {
    const razorpayPrepare = 'Newsubapp_api/prepare_razorpay_gate_way';
    const razorpayResponse = 'Newsubapp_api/razorpayresponse';
    const razorpayCheck = 'Newsubapp_api/razorpay_trans_check';
    final fake = await client({
      razorpayPrepare: {
        'STATUS': true,
        'data': {
          'status': true,
          'PAYGATEWAY': 'https://pages.razorpay.com/x',
          'ordernumber': 'RZP1',
        },
      },
      razorpayResponse: {
        'STATUS': true,
        'data': {'STATUS': 'OK', 'Message': 'Recharge Successfully'},
      },
      razorpayCheck: {
        'STATUS': true,
        'data': {'status': true, 'Message': 'Transaction Successful'},
      },
    });

    final prepared = await repository.rechargeChangePlan(_params('RAZORPAY'));
    final orderId = prepared.fold((l) => fail(l.message), (r) => r.orderId);
    final result = await repository.getRechargePaymentStatus(orderId);
    final status = result.fold((l) => fail(l.message), (r) => r);

    expect((fake.requests[razorpayPrepare] as Map)['slno'], '104870');
    expect((fake.requests[razorpayResponse] as Map)['ordernumber'], 'RZP1');
    expect((fake.requests[razorpayCheck] as Map)['ordernumber'], 'RZP1');
    expect(fake.requests.containsKey(check), isFalse);
    expect(status.paymentStatus, 'SUCCESS');
    expect(status.gatewayType, 'RAZORPAY');
  });

  test('looks up the new order and reads a successful check', () async {
    final now = DateTime.now();
    String time(DateTime t) => t.toIso8601String().split('.').first;
    final fake = await client({
      prepare: {
        'STATUS': true,
        'data': {'status': true, 'PAYGATEWAY': paymentUrl},
      },
      history: {
        'STATUS': true,
        'data': {
          'status': true,
          'recharge_details': [
            {
              'ordernumber': '11000000000001',
              'txnid': 'OLD',
              'order_time': time(now.subtract(const Duration(days: 3))),
            },
            {
              'ordernumber': '11000000559442',
              'txnid': 'NEW',
              'order_time': time(now),
            },
          ],
        },
      },
      check: {'STATUS': false, 'msg': 'Transaction Successful'},
    });
    await repository.rechargeChangePlan(_params('ATOM'));

    final result = await repository.getRechargePaymentStatus('');
    final status = result.fold((l) => fail(l.message), (r) => r);

    expect((fake.requests[check] as Map)['ordernumber'], 'NEW');
    expect(status.paymentStatus, 'SUCCESS');
    expect(status.amount, 11800);
  });

  test('an unclear check is not reported as success', () async {
    await client({
      check: {'STATUS': false, 'msg': 'Invalid parameters!'},
    });

    final result = await repository.getRechargePaymentStatus('ORDER1');

    expect(result.fold((l) => l.message, (_) => ''), 'Invalid parameters!');
  });

  group('change plan', () {
    const packageChange = 'Newsubapp_api/Subpackagechange';
    const onlineAmount = 'Newsubapp_api/onlineamount';
    const verifyPlanChange = 'Newsubapp_api/verifyplanchange';
    final responses = <String, Map<String, dynamic>>{
      packageChange: {
        'STATUS': true,
        'data': {
          'status': true,
          'package_list': [
            {
              'packageid': '105052',
              'packagename': '50Mbps Unlimited',
              'renewalfee': '1599.2',
            },
          ],
          'current_data': {'packageid': '104870', 'sub_status': '1'},
        },
      },
      verifyPlanChange: {
        'STATUS': true,
        'data': {
          'status': true,
          'Message': 'Your upgraded package validity would be till :09-09-2024',
          'tot_data': {
            'STATUS': 'OK',
            'tot_details': {'tot_days': 32, 'new_pf': 1599.2, 'curr_bal': 1680},
          },
          'new_validity': '09-09-2024',
        },
      },
      onlineAmount: {
        'STATUS': true,
        'data': {
          'status': true,
          'razorpay_enabled': '1',
          'razorpayamnt': '11800',
        },
      },
    };

    Future<Either<Failure, List<DiscountDetailsEntity>>> summary(
      String packageId,
    ) => repository.getSubscriberDiscounts([
      SubscriberDiscountRequestParams(
        subscriberId: '1001',
        packageId: packageId,
        seasonId: '',
        referral: false,
      ),
    ]);

    Future<double?> summaryTotal(String packageId) async => (await summary(
      packageId,
    )).fold((l) => fail(l.message), (r) => r.firstOrNull?.finalAmount);

    test('a new plan is previewed; renewing costs onlineamount', () async {
      final fake = await client(responses);

      final newPlan = (await summary(
        '105052',
      )).fold((l) => fail(l.message), (r) => r.single);
      expect(newPlan.finalAmount, 1599.2);
      expect(newPlan.validity, 32);
      expect(newPlan.walletEligible, isTrue);
      expect(newPlan.walletBalance, 1680);
      expect(fake.requests[verifyPlanChange], {
        'stcode': 'ka.railwire.co.in',
        'subscriberid': '1001',
        'oldpkgid': '104870',
        'packageid': '105052',
        'sub_status': '1',
      });

      expect(await summaryTotal('104870'), 11800);
    });

    test('a refused plan change shows the API message', () async {
      await client({
        ...responses,
        verifyPlanChange: {'STATUS': false, 'msg': 'Not eligible'},
      });

      final result = await summary('105052');

      expect(result.fold((l) => l.message, (_) => ''), 'Not eligible');
    });

    test('the Change plan screen has one change-plan tab', () async {
      await client({});

      final tab = await repository.getPackageTabs(
        subscriberId: '1001',
        packageId: '104870',
      );

      expect(
        tab.fold((l) => fail(l.message), (r) => r.changePackage?.eligible),
        isTrue,
      );
    });

    test('a plan change paid from the balance is applied', () async {
      const applyPlan = 'Newsubapp_api/applyplan_subscirber';
      final fake = await client({
        ...responses,
        applyPlan: {
          'STATUS': true,
          'data': {'status': true, 'Message': 'Package changed successfully!'},
        },
      });
      const change = RechargeChangePlanParams(
        packageId: '105052',
        gateway: null,
        amount: 1599.2,
        expectedFinalAmount: 1599.2,
        durationDays: 30,
        referral: false,
        useWallet: true,
        changePlan: true,
      );

      final result = await repository.rechargeChangePlan(change);
      final response = result.fold((l) => fail(l.message), (r) => r);

      expect(response.activated, isTrue);
      expect(response.redirect, isNull);
      expect(response.message, 'Package changed successfully!');
      expect(fake.requests[applyPlan], {
        'stcode': 'ka.railwire.co.in',
        'subscriberid': '1001',
        'oldpkgid': '104870',
        'packageid': '105052',
      });
    });

    test('a gateway cannot pay for a plan change; renewing works', () async {
      final fake = await client({
        ...responses,
        prepare: {
          'STATUS': true,
          'data': {'status': true, 'PAYGATEWAY': paymentUrl},
        },
      });
      final change = RechargeChangePlanParams(
        packageId: '105052',
        gateway: 'ATOM',
        amount: 1599.2,
        expectedFinalAmount: 1599.2,
        durationDays: 30,
        referral: false,
        useWallet: false,
        changePlan: true,
      );

      final blocked = await repository.rechargeChangePlan(change);
      expect(blocked.isLeft(), isTrue);
      expect(fake.requests.containsKey(prepare), isFalse);

      final renew = await repository.rechargeChangePlan(_params('ATOM'));
      expect(renew.isRight(), isTrue);
    });
  });

  group('onlineamount on the Recharge screen', () {
    const onlineAmount = 'Newsubapp_api/onlineamount';
    const packageChange = 'Newsubapp_api/Subpackagechange';

    Future<_CountingClient> counting(Map<String, dynamic> online) async {
      final fake = _CountingClient({
        onlineAmount: online,
        packageChange: {
          'STATUS': true,
          'data': {'status': true, 'package_list': []},
        },
      });
      await sl.reset();
      sl.registerSingleton<DioClient>(fake);
      return fake;
    }

    const ok = {
      'STATUS': true,
      'data': {
        'status': true,
        'razorpay_enabled': '1',
        'razorpayamnt': '824.82',
      },
    };

    Future<void> openRechargeScreen() => Future.wait([
      repository.getPaymentGateways(),
      repository.getSubscriberDiscounts([
        SubscriberDiscountRequestParams(
          subscriberId: '1001',
          packageId: '104870',
          seasonId: '',
          referral: false,
        ),
      ]),
    ]);

    test('gateways and order summary share one call', () async {
      final fake = await counting(ok);

      await openRechargeScreen();
      await openRechargeScreen();

      expect(fake.calls[onlineAmount], 1);
    });

    test('a payment makes the next call fresh', () async {
      final fake = await counting(ok);

      await openRechargeScreen();
      await repository.rechargeChangePlan(_params('BILLDESK'));
      await openRechargeScreen();

      expect(fake.calls[onlineAmount], 2);
    });

    test('a failed call is not reused', () async {
      final fake = await counting({'STATUS': false, 'msg': 'down'});

      await repository.getPaymentGateways();
      await repository.getPaymentGateways();

      expect(fake.calls[onlineAmount], 2);
    });
  });

  group('paymentStatusOf', () {
    String? status(String message) =>
        RailwireChangePlanRepositoryImp.paymentStatusOf(message: message);

    test('reads the messages', () {
      expect(status('Transaction Successful'), 'SUCCESS');
      expect(status('Transaction Unsuccessful'), 'FAILED');
      expect(status('Transaction Failed'), 'FAILED');
      expect(status('Cancelled by user'), 'FAILED');
      expect(status('Invalid parameters!'), isNull);
    });

    test('prefers payment_status when sent', () {
      expect(
        RailwireChangePlanRepositoryImp.paymentStatusOf(
          paymentStatus: 'failed',
          message: 'Transaction Successful',
        ),
        'FAILED',
      );
    });
  });
}
