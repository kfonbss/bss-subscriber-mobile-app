import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';

class Validators {
  /// Validates that a field is not empty
  static String? validateRequired(
    String? value, {
    String fieldName = 'This field',
    BssSubLocalizations? l10n,
  }) {
    if (value == null || value.trim().isEmpty) {
      final cleanFieldName = fieldName.replaceAll('*', '').trim();
      return l10n?.fieldIsRequired(cleanFieldName) ??
          '$cleanFieldName is required';
    }
    return null;
  }

  /// Generic max length validator (character count matches [String.length] as sent to APIs)
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String fieldName = 'This field',
    BssSubLocalizations? l10n,
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      final cleanFieldName = fieldName.replaceAll('*', '').trim();
      return '$cleanFieldName must be at most $maxLength characters';
    }

    return null;
  }

  /// Validates mobile number (10 digits)
  static String? validateMobileNumber(
    String? value, {
    BssSubLocalizations? l10n,
  }) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.pleaseEnterMobileNumber ?? 'Please enter mobile number';
    }

    final trimmedValue = value.trim();

    // Check if it contains only digits
    if (!RegExp(r'^\d+$').hasMatch(trimmedValue)) {
      return 'Mobile number must contain only digits';
    }

    // Check if it's exactly 10 digits
    if (trimmedValue.length != 10) {
      return l10n?.pleaseEnterValidMobileNumber ??
          'Please enter valid 10-digit mobile number';
    }

    return null;
  }

  /// Validates password (minimum 6 characters)
  static String? validatePassword(
    String? value, {
    BssSubLocalizations? l10n,
  }) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.pleaseEnterPassword ?? 'Please enter password';
    }

    if (value.trim().length < 6) {
      return l10n?.passwordMinLength ??
          'Password must be at least 6 characters';
    }

    return null;
  }

  /// Generic min length validator
  static String? validateMinLength(
    String? value,
    int minLength, {
    String fieldName = 'This field',
    BssSubLocalizations? l10n,
  }) {
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty, use validateRequired if you need to enforce presence
    }

    if (value.trim().length < minLength) {
      final cleanFieldName = fieldName.replaceAll('*', '').trim();
      return '$cleanFieldName must be at least $minLength characters';
    }

    return null;
  }

  /// Validates email format
  static String? validateEmail(
    String? value, {
    BssSubLocalizations? l10n,
  }) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.pleaseEnterEmailAddress ?? 'Please enter email address';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return l10n?.pleaseEnterValidEmailAddress ??
          'Please enter a valid email address';
    }

    return null;
  }

  /// Validates that confirm password matches the original password
  static String? validateConfirmPassword(
    String? value,
    String originalPassword, {
    BssSubLocalizations? l10n,
  }) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.pleaseConfirmPassword ?? 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }
}
