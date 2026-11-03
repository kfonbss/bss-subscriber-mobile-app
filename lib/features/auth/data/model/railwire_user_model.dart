import '../../domain/entity/railwire_user_entity.dart';

/// The `data` object of the RailWire `userlogin` response.
class RailwireUserModel {
  final String subscriberId;
  final String username;
  final String mobileNo;
  final String email;
  final String stCode;
  final String? state;
  final bool isSmeSubscriber;
  final bool atomEnabled;
  final bool mimoEnabled;
  final bool subOnRechargeRazorpay;

  const RailwireUserModel({
    required this.subscriberId,
    required this.username,
    required this.mobileNo,
    required this.email,
    required this.stCode,
    this.state,
    required this.isSmeSubscriber,
    required this.atomEnabled,
    required this.mimoEnabled,
    required this.subOnRechargeRazorpay,
  });

  // RailWire sends these flags as either 0/1 or "0"/"1".
  static bool _flag(dynamic value) => value?.toString() == '1';

  factory RailwireUserModel.fromJson(Map<String, dynamic> json) =>
      RailwireUserModel(
        subscriberId: json['subscriberid']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        mobileNo: json['mobileno']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        stCode: json['stcode']?.toString() ?? '',
        state: json['state']?.toString(),
        isSmeSubscriber: _flag(json['is_sme_subscriber']),
        atomEnabled: _flag(json['atomenabled']),
        mimoEnabled: _flag(json['mimoenabled']),
        subOnRechargeRazorpay: _flag(json['subonrechargerazorpay']),
      );

  RailwireUserEntity toEntity() => RailwireUserEntity(
    subscriberId: subscriberId,
    username: username,
    mobileNo: mobileNo,
    email: email,
    stCode: stCode,
    state: state,
    isSmeSubscriber: isSmeSubscriber,
    atomEnabled: atomEnabled,
    mimoEnabled: mimoEnabled,
    subOnRechargeRazorpay: subOnRechargeRazorpay,
  );
}
