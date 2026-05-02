class Validators {
  /// Validates that a field is not empty
  static String? validateRequired(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName.replaceAll('*', '').trim()} is required';
    }
    return null;
  }
  /// Generic max length validator (character count matches [String.length] as sent to APIs)
  static String? validateMaxLength(
      String? value,
      int maxLength, {
        String fieldName = 'This field',
      }) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      return '${fieldName.replaceAll('*', '').trim()} must be at most $maxLength characters';
    }

    return null;
  }
  /// Validates mobile number (10 digits)
  static String? validateMobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter mobile number';
    }

    final trimmedValue = value.trim();

    // Check if it contains only digits
    if (!RegExp(r'^\d+$').hasMatch(trimmedValue)) {
      return 'Mobile number must contain only digits';
    }

    // Check if it's exactly 10 digits
    if (trimmedValue.length != 10) {
      return 'Please enter valid 10-digit mobile number';
    }

    return null;
  }

  /// Validates password (minimum 6 characters)
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter password';
    }

    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Generic min length validator
  static String? validateMinLength(
    String? value,
    int minLength, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty, use validateRequired if you need to enforce presence
    }

    if (value.trim().length < minLength) {
      return '${fieldName.replaceAll('*', '').trim()} must be at least $minLength characters';
    }

    return null;
  }

  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email address';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates that confirm password matches the original password
  static String? validateConfirmPassword(
    String? value,
    String originalPassword,
  ) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }
}
