class SubscriberDiscountRequestParams {
  final String subscriberId;
  final String packageId;
  final String? seasonId;
  final String? paymentMode;
  final bool referral;
  final String? referralCode;

  const SubscriberDiscountRequestParams({
    required this.subscriberId,
    required this.packageId,
    this.seasonId,
    this.paymentMode,
    this.referral = false,
    this.referralCode,
  });

  /// Sends JSON `null` when optional values are absent or blank (API contract).
  static String? _nullIfBlank(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriberId': subscriberId,
      'packageId': packageId,
      'seasonId': _nullIfBlank(seasonId),
      'paymentMode': _nullIfBlank(paymentMode),
      'referral': referral,
      'referralCode': _nullIfBlank(referralCode),
    };
  }
}
