import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/features/home/data/model/railwire_last_recharge_model.dart';

void main() {
  test('reads the amount and date of the sample', () {
    final txn = RailwireLastRechargeModel.fromJson({
      'status': true,
      'list': {
        'subscriberid': '113755',
        'amount': '499.00',
        'lastupdate': '2023-05-18 12:38:04',
        'cause': 'Partner Transfer',
      },
    });

    expect(txn!.amount, 499);
    expect(txn.paidOn, DateTime(2023, 5, 18, 12, 38, 4));
  });

  test('no recharge leaves the card empty', () {
    expect(RailwireLastRechargeModel.fromJson({'list': null}), isNull);
    expect(RailwireLastRechargeModel.fromJson({'list': []}), isNull);
    expect(
      RailwireLastRechargeModel.fromJson({
        'list': {'amount': ''},
      }),
      isNull,
    );
  });
}
