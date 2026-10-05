import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';

/// Tax-payer type codes sent to / received from the API (GST and PAN
/// Updation tickets). `COMPOSITE` matches the backend; the others are assumed.
const taxPayerTypeCodes = [
  'REGULAR',
  'COMPOSITE',
  'CASUAL',
  'NON_RESIDENT',
  'SEZ_UNIT',
  'SEZ_DEVELOPER',
  'ISD',
  'UN_BODY',
];

/// Display label for a tax-payer type code; unknown codes are shown as-is.
String taxPayerTypeLabel(BssSubLocalizations l10n, String code) {
  return switch (code.trim().toUpperCase()) {
    'REGULAR' => l10n.taxPayerRegular,
    'COMPOSITE' => l10n.taxPayerComposite,
    'CASUAL' => l10n.taxPayerCasual,
    'NON_RESIDENT' => l10n.taxPayerNonResident,
    'SEZ_UNIT' => l10n.taxPayerSezUnit,
    'SEZ_DEVELOPER' => l10n.taxPayerSezDeveloper,
    'ISD' => l10n.taxPayerIsd,
    'UN_BODY' => l10n.taxPayerUnBody,
    _ => code,
  };
}
