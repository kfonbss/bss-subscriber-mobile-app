import 'package:equatable/equatable.dart';

class RailwireUserEntity extends Equatable {
  final String subscriberId;
  final String username;
  final String mobileNo;
  final String email;

  /// Subscriber's state host, e.g. `ka.railwire.co.in`.
  final String stCode;

  /// State code, e.g. `KL`. Not sent in every response, see [stCode].
  final String? state;
  final bool isSmeSubscriber;
  final bool atomEnabled;
  final bool mimoEnabled;
  final bool subOnRechargeRazorpay;

  const RailwireUserEntity({
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

  @override
  List<Object?> get props => [
    subscriberId,
    username,
    mobileNo,
    email,
    stCode,
    state,
    isSmeSubscriber,
    atomEnabled,
    mimoEnabled,
    subOnRechargeRazorpay,
  ];
}
