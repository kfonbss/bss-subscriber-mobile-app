import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/railwire_online_amount_model.dart';

void main() {
  test('reads the sample response', () {
    final online = RailwireOnlineAmountModel.fromJson({
      'atom_enabled': '1',
      'razorpay_enabled': '1',
      'atomamnt': '11800',
      'razorpayamnt': '11800',
      'amt': '11978.89',
      'onpending': 'Notpending',
    });

    expect(online.razorpayEnabled, isTrue);
    expect(online.atomEnabled, isTrue);
    expect(online.amount, 11800);
    expect(online.isPaymentPending, isFalse);
  });

  test('uses the Atom amount when only Atom is enabled', () {
    final online = RailwireOnlineAmountModel.fromJson({
      'atom_enabled': 1,
      'razorpay_enabled': 0,
      'atomamnt': '500',
      'razorpayamnt': '0',
    });

    expect(online.razorpayEnabled, isFalse);
    expect(online.amount, 500);
  });

  test('falls back to amt when there is no gateway amount', () {
    final online = RailwireOnlineAmountModel.fromJson({'amt': '11978.89'});

    expect(online.amount, 11978.89);
  });

  test('any onpending value other than Notpending is pending', () {
    final online = RailwireOnlineAmountModel.fromJson({'onpending': 'Pending'});

    expect(online.isPaymentPending, isTrue);
  });

  test('fee is the whole amount until package_fee is sent', () {
    final whole = RailwireOnlineAmountModel.fromJson({
      'razorpay_enabled': '1',
      'razorpayamnt': '11800',
    });
    final split = RailwireOnlineAmountModel.fromJson({
      'razorpay_enabled': '1',
      'razorpayamnt': '11800',
      'package_fee': '10000',
      'gst_amount': '1800',
    });

    expect(whole.packageFee, 11800);
    expect(whole.gstAmount, 0);
    expect(split.packageFee, 10000);
    expect(split.gstAmount, 1800);
  });
}
