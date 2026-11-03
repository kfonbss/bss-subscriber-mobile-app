import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/features/auth/data/model/railwire_user_model.dart';
import 'package:kfon_subscriber/features/auth/data/model/tenant_model.dart';

void main() {
  test('parses the login data, with flags as numbers or strings', () {
    final user = RailwireUserModel.fromJson({
      'status': true,
      'Message': '',
      'stcode': 'xx.railwire.test',
      'username': 'xx.user',
      'subscriberid': '1001',
      'mobileno': '9000000000',
      'email': 'user@example.com',
      'is_sme_subscriber': 1,
      'atomenabled': '1',
      'mimoenabled': '0',
      'subonrechargerazorpay': '1',
    }).toEntity();

    expect(user.subscriberId, '1001');
    expect(user.username, 'xx.user');
    expect(user.mobileNo, '9000000000');
    expect(user.email, 'user@example.com');
    expect(user.stCode, 'xx.railwire.test');
    expect(user.state, isNull);
    expect(user.isSmeSubscriber, isTrue);
    expect(user.atomEnabled, isTrue);
    expect(user.mimoEnabled, isFalse);
    expect(user.subOnRechargeRazorpay, isTrue);
  });

  test('copes with the older shape and missing fields', () {
    final user = RailwireUserModel.fromJson({
      'subscriberid': 1001,
      'state': 'XX',
      'is_sme_subscriber': 0,
    }).toEntity();

    expect(user.subscriberId, '1001');
    expect(user.state, 'XX');
    expect(user.stCode, '');
    expect(user.isSmeSubscriber, isFalse);
    expect(user.atomEnabled, isFalse);
  });

  test('keeps the state app_url and leaves it empty for Java tenants', () {
    final state = TenantModel.fromRailwireJson({
      'state_name': 'Test State',
      'state_code': 'TS',
      'app_url': 'https://ts.railwire.test',
    }).toEntity();
    final tenant = TenantModel.fromJson({'code': 'TS', 'name': 'T'}).toEntity();

    expect(state.appUrl, 'https://ts.railwire.test');
    expect(tenant.appUrl, isNull);
  });
}
