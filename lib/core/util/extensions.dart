import 'package:flutter/material.dart';

extension ExtString on String {
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  String get toCapitalized {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Deprecated alias kept for backward-compatibility — use [toCapitalized].
  @Deprecated('Use toCapitalized instead')
  String get toCaptialized => toCapitalized;
}

extension PriceExtension on num {
  /// Formats a number using Indian grouping (e.g. 1250000 → 12,50,000).
  /// Fractional digits are preserved as-is from the input.
  String get formatAmount {
    // Split integer and fractional parts
    final parts = toStringAsFixed(
      this is double && (this as double) % 1 != 0 ? 2 : 0,
    ).split('.');
    final intStr = parts[0];
    final fraction = parts.length > 1 ? '.${parts[1]}' : '';

    if (intStr.length <= 3) return '$intStr$fraction';

    final last3 = intStr.substring(intStr.length - 3);
    final rest = intStr.substring(0, intStr.length - 3);
    final buffer = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      final idxFromEnd = rest.length - i;
      buffer.write(rest[i]);
      if (idxFromEnd > 1 && idxFromEnd.isEven) buffer.write(',');
    }
    return '${buffer.toString()},$last3$fraction';
  }
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // Define your breakpoints here
  bool get isTablet => screenWidth >= 600;
  bool get isMobile => screenWidth < 600;
  bool get isDesktop => screenWidth >= 1200;
}
