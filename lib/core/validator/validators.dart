import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

class Validators {
  /// Validates that a field is not empty
  static String? validateRequired(
    String? value, {
    String? fieldName,
    BssSubLocalizations? l10n,
  }) {
    final strings = l10n ?? appL10n;
    if (value == null || value.trim().isEmpty) {
      final cleanFieldName =
          (fieldName ?? strings.thisField).replaceAll('*', '').trim();
      return strings.fieldIsRequired(cleanFieldName);
    }
    return null;
  }

  /// Generic max length validator (character count matches [String.length] as sent to APIs)
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
    BssSubLocalizations? l10n,
  }) {
    final strings = l10n ?? appL10n;
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      final cleanFieldName =
          (fieldName ?? strings.thisField).replaceAll('*', '').trim();
      return strings.fieldMaxLength(cleanFieldName, maxLength);
    }

    return null;
  }

  /// Validates mobile number (10 digits)
  static String? validateMobileNumber(
    String? value, {
    BssSubLocalizations? l10n,
  }) {
    final strings = l10n ?? appL10n;
    if (value == null || value.trim().isEmpty) {
      return strings.pleaseEnterMobileNumber;
    }

    final trimmedValue = value.trim();

    // Check if it contains only digits
    if (!RegExp(r'^\d+$').hasMatch(trimmedValue)) {
      return strings.mobileNumberOnlyDigits;
    }

    // Check if it's exactly 10 digits
    if (trimmedValue.length != 10) {
      return strings.pleaseEnterValidMobileNumber;
    }

    return null;
  }

  /// Validates password (minimum 6 characters)
  static String? validatePassword(String? value, {BssSubLocalizations? l10n}) {
    final strings = l10n ?? appL10n;
    if (value == null || value.trim().isEmpty) {
      return strings.pleaseEnterPassword;
    }

    if (value.trim().length < 6) {
      return strings.passwordMinLength;
    }

    return null;
  }

  /// Generic min length validator
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
    BssSubLocalizations? l10n,
  }) {
    final strings = l10n ?? appL10n;
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty, use validateRequired if you need to enforce presence
    }

    if (value.trim().length < minLength) {
      final cleanFieldName =
          (fieldName ?? strings.thisField).replaceAll('*', '').trim();
      return strings.fieldMinLength(cleanFieldName, minLength);
    }

    return null;
  }

  /// Validates email format
  static String? validateEmail(String? value, {BssSubLocalizations? l10n}) {
    final strings = l10n ?? appL10n;
    if (value == null || value.trim().isEmpty) {
      return strings.pleaseEnterEmailAddress;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return strings.pleaseEnterValidEmailAddress;
    }

    return null;
  }

  /// Validates that confirm password matches the original password
  static String? validateConfirmPassword(
    String? value,
    String originalPassword, {
    BssSubLocalizations? l10n,
  }) {
    final strings = l10n ?? appL10n;
    if (value == null || value.trim().isEmpty) {
      return strings.pleaseConfirmPassword;
    }

    if (value != originalPassword) {
      return strings.passwordsDoNotMatch;
    }

    return null;
  }
}
