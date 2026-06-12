class SubscriberDiscountRequestParams {
  final String subscriberId;
  final String packageId;
  final String seasonId;
  final String paymentMode;
  final bool referral;
  final String referralCode;

  const SubscriberDiscountRequestParams({
    required this.subscriberId,
    required this.packageId,
    this.seasonId = '',
    this.paymentMode = '',
    this.referral = false,
    this.referralCode = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'subscriberId': subscriberId,
      'packageId': packageId,
      'seasonId': seasonId,
      'paymentMode': paymentMode,
      'referral': referral,
      'referralCode': referralCode,
    };
  }
}
