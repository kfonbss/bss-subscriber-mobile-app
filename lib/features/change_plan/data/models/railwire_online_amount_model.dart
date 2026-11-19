import 'package:kfon_subscriber/core/network/railwire_api.dart';

/// RailWire's `onlineamount`: what renewing the current plan costs, and which
/// payment gateways the subscriber can use. Loaded by
/// [RailwireOnlineAmountSource].
class RailwireOnlineAmountModel {
  final bool atomEnabled;
  final bool razorpayEnabled;

  /// What the subscriber pays to renew, in rupees.
  final double amount;

  /// The fee and GST within [amount], once the API sends `package_fee` and
  /// `gst_amount`. Until then the fee is the whole amount and GST is 0.
  final double packageFee;
  final double gstAmount;

  /// Whether an earlier payment hasn't completed yet.
  final bool isPaymentPending;

  const RailwireOnlineAmountModel({
    required this.atomEnabled,
    required this.razorpayEnabled,
    required this.amount,
    this.packageFee = 0,
    this.gstAmount = 0,
    required this.isPaymentPending,
  });

  static const empty = RailwireOnlineAmountModel(
    atomEnabled: false,
    razorpayEnabled: false,
    amount: 0,
    isPaymentPending: false,
  );

  static bool _flag(dynamic value) => value?.toString().trim() == '1';

  /// Uses the gateway amount (`razorpayamnt`, else `atomamnt`), falling back
  /// to `amt`. What `amt` adds on top is an open question with the PHP team.
  factory RailwireOnlineAmountModel.fromJson(Map<String, dynamic> json) {
    final razorpayEnabled = _flag(json['razorpay_enabled']);
    final atomEnabled = _flag(json['atom_enabled']);
    final gatewayAmount = RailwireApi.toDouble(
      razorpayEnabled || !atomEnabled ? json['razorpayamnt'] : json['atomamnt'],
    );
    final pending = json['onpending']?.toString().trim().toLowerCase() ?? '';
    final amount =
        gatewayAmount > 0 ? gatewayAmount : RailwireApi.toDouble(json['amt']);
    final packageFee = RailwireApi.toDouble(json['package_fee']);
    return RailwireOnlineAmountModel(
      atomEnabled: atomEnabled,
      razorpayEnabled: razorpayEnabled,
      amount: amount,
      packageFee: packageFee > 0 ? packageFee : amount,
      gstAmount: packageFee > 0 ? RailwireApi.toDouble(json['gst_amount']) : 0,
      isPaymentPending: pending.isNotEmpty && pending != 'notpending',
    );
  }
}
