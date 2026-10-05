import 'package:equatable/equatable.dart';

/// UPI Autopay (mandate) state from `upi-mandate/status`.
enum AutopayStatus {
  /// Mandate is live — renewals are auto-debited.
  active,

  /// Mandate created, waiting for the user to approve it in their UPI app.
  pending,

  /// No mandate (never enabled, revoked, failed, expired…).
  notEnabled;

  /// ACTIVE and PENDING both show the "enabled" details screen.
  bool get isEnabled => this == active || this == pending;
}

/// `upi-mandate/quote`: charges and content for the enable screen, plus the
/// mandate details (UPI ID, UMN, next debit…) once Autopay is enabled.
class AutopayQuoteEntity extends Equatable {
  final String packageId;
  final double renewalFee;
  final double serviceCharge;
  final double totalCharge;
  final bool eligible;
  final String? ineligibleReason;

  // ── Plan ──
  final String packageName;

  /// Speed in Mbps, e.g. "5".
  final String speedProfile;

  /// Plan price per renewal period (excl. GST / platform charge).
  final double baseRate;

  /// Renewal period in days.
  final int? renewPeriod;
  final DateTime? expiryDate;

  // ── Mandate (set once Autopay is enabled) ──
  final DateTime? nextAutoDebitDate;
  final int? daysUntilNextAutoDebit;
  final String? upiId;
  final String? umnNumber;
  final double maxAutoDebitAmount;

  // ── Content ──
  /// "Enroll in UPI Autopay…" banner text.
  final String? enrollmentBanner;

  /// UPI handle chips under the UPI ID field, e.g. "@okaxis".
  final List<String> upiHandles;

  /// Terms & Conditions page opened from the agreement checkbox.
  final String? termsUrl;

  /// Platform charge policy text shown in the policies card.
  final String? platformChargePolicy;

  /// Refund / cancellation policy text shown in the policies card.
  final String? refundPolicy;

  /// Support number shown in the Contact Us section.
  final String? tollFreeNumber;

  const AutopayQuoteEntity({
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

  /// Details screen data. [fallbackUpiId] covers the moment right after
  /// enabling, before the quote returns the mandate's UPI ID.
  AutopayMandateDetailsEntity toMandateDetails({String? fallbackUpiId}) {
    final upi = upiId?.trim() ?? '';
    return AutopayMandateDetailsEntity(
      planName: packageName,
      speed: speedProfile,
      baseRate: baseRate > 0 ? baseRate : renewalFee,
      totalDebit: totalCharge,
      nextDebitDate: nextAutoDebitDate,
      upiId: upi.isNotEmpty ? upi : (fallbackUpiId ?? ''),
      umn: umnNumber?.trim() ?? '',
      maxDebitCap: maxAutoDebitAmount,
    );
  }

  @override
  List<Object?> get props => [
    packageId,
    renewalFee,
    serviceCharge,
    totalCharge,
    eligible,
    ineligibleReason,
    packageName,
    speedProfile,
    baseRate,
    renewPeriod,
    expiryDate,
    nextAutoDebitDate,
    daysUntilNextAutoDebit,
    upiId,
    umnNumber,
    maxAutoDebitAmount,
    enrollmentBanner,
    upiHandles,
    termsUrl,
    platformChargePolicy,
    refundPolicy,
    tollFreeNumber,
  ];
}

/// Active mandate shown on the details screen.
class AutopayMandateDetailsEntity extends Equatable {
  final String planName;
  final String speed;
  final double baseRate;
  final double totalDebit;
  final DateTime? nextDebitDate;
  final String upiId;
  final String umn;
  final double maxDebitCap;

  const AutopayMandateDetailsEntity({
    required this.planName,
    required this.speed,
    required this.baseRate,
    required this.totalDebit,
    required this.nextDebitDate,
    required this.upiId,
    required this.umn,
    required this.maxDebitCap,
  });

  @override
  List<Object?> get props => [
    planName,
    speed,
    baseRate,
    totalDebit,
    nextDebitDate,
    upiId,
    umn,
    maxDebitCap,
  ];
}
