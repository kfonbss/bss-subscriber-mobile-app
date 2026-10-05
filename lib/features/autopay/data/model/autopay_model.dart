import 'package:kfon_subscriber/features/autopay/domain/entity/autopay_entity.dart';

double _toDouble(dynamic value) => switch (value) {
  num n => n.toDouble(),
  String s => double.tryParse(s) ?? 0,
  _ => 0,
};

/// Parses the `data` string of `upi-mandate/status`, e.g. "PENDING".
AutopayStatus parseAutopayStatus(dynamic value) {
  switch (value?.toString().trim().toUpperCase()) {
    case 'ACTIVE':
      return AutopayStatus.active;
    case 'PENDING':
      return AutopayStatus.pending;
    default:
      // null, "", REVOKED, FAILED, EXPIRED… → not enabled.
      return AutopayStatus.notEnabled;
  }
}

int? _toInt(dynamic value) => switch (value) {
  num n => n.toInt(),
  String s => int.tryParse(s),
  _ => null,
};

String? _toStr(dynamic value) {
  final s = value?.toString().trim() ?? '';
  return s.isEmpty || s == 'null' ? null : s;
}

DateTime? _toDate(dynamic value) => DateTime.tryParse(value?.toString() ?? '');

/// `upi-mandate/quote` `data`.
class AutopayQuoteModel {
  final String packageId;
  final double renewalFee;
  final double serviceCharge;
  final double totalCharge;
  final bool eligible;
  final String? ineligibleReason;
  final String packageName;
  final String speedProfile;
  final double baseRate;
  final int? renewPeriod;
  final DateTime? expiryDate;
  final DateTime? nextAutoDebitDate;
  final int? daysUntilNextAutoDebit;
  final String? upiId;
  final String? umnNumber;
  final double maxAutoDebitAmount;
  final String? enrollmentBanner;
  final List<String> upiHandles;
  final String? termsUrl;
  final String? platformChargePolicy;
  final String? refundPolicy;
  final String? tollFreeNumber;

  const AutopayQuoteModel({
    required this.packageId,
    required this.renewalFee,
    required this.serviceCharge,
    required this.totalCharge,
    required this.eligible,
    this.ineligibleReason,
    this.packageName = '',
    this.speedProfile = '',
    this.baseRate = 0,
    this.renewPeriod,
    this.expiryDate,
    this.nextAutoDebitDate,
    this.daysUntilNextAutoDebit,
    this.upiId,
    this.umnNumber,
    this.maxAutoDebitAmount = 0,
    this.enrollmentBanner,
    this.upiHandles = const [],
    this.termsUrl,
    this.platformChargePolicy,
    this.refundPolicy,
    this.tollFreeNumber,
  });

  factory AutopayQuoteModel.fromJson(Map<String, dynamic> json) {
    // Texts and UPI handles now live under `content`; fall back to the old
    // top-level keys.
    final content =
        json['content'] is Map<String, dynamic>
            ? json['content'] as Map<String, dynamic>
            : const <String, dynamic>{};
    dynamic pick(String key) => content[key] ?? json[key];

    final handles = pick('upiHandles');

    return AutopayQuoteModel(
      packageId: json['packageId']?.toString() ?? '',
      renewalFee: _toDouble(json['renewalFee']),
      serviceCharge: _toDouble(json['serviceCharge']),
      totalCharge: _toDouble(json['totalCharge']),
      eligible: json['eligible'] == true,
      ineligibleReason: _toStr(json['ineligibleReason']),
      packageName: _toStr(json['packageName']) ?? '',
      speedProfile: _toStr(json['speedProfile']) ?? '',
      baseRate: _toDouble(json['baseRate']),
      renewPeriod: _toInt(json['renewPeriod']),
      expiryDate: _toDate(json['expiryDate']),
      nextAutoDebitDate: _toDate(json['nextAutoDebitDate']),
      daysUntilNextAutoDebit: _toInt(json['daysUntilNextAutoDebit']),
      upiId: _toStr(json['upiId']),
      umnNumber: _toStr(json['umnNumber']),
      maxAutoDebitAmount: _toDouble(json['maxAutoDebitAmount']),
      enrollmentBanner: _toStr(pick('enrollmentBanner')),
      upiHandles:
          handles is List
              ? handles
                  .map((e) => e?.toString().trim() ?? '')
                  .where((e) => e.isNotEmpty)
                  .toList()
              : const [],
      termsUrl: _toStr(pick('termsUrl')),
      platformChargePolicy: _toStr(pick('platformChargePolicy')),
      refundPolicy: _toStr(pick('refundPolicy')),
      tollFreeNumber: _toStr(pick('tollFreeNumber')),
    );
  }

  AutopayQuoteEntity toEntity() => AutopayQuoteEntity(
    packageId: packageId,
    renewalFee: renewalFee,
    serviceCharge: serviceCharge,
    totalCharge: totalCharge,
    eligible: eligible,
    ineligibleReason: ineligibleReason,
    packageName: packageName,
    speedProfile: speedProfile,
    baseRate: baseRate,
    renewPeriod: renewPeriod,
    expiryDate: expiryDate,
    nextAutoDebitDate: nextAutoDebitDate,
    daysUntilNextAutoDebit: daysUntilNextAutoDebit,
    upiId: upiId,
    umnNumber: umnNumber,
    maxAutoDebitAmount: maxAutoDebitAmount,
    enrollmentBanner: enrollmentBanner,
    upiHandles: upiHandles,
    termsUrl: termsUrl,
    platformChargePolicy: platformChargePolicy,
    refundPolicy: refundPolicy,
    tollFreeNumber: tollFreeNumber,
  );
}
