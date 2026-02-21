import 'package:flutter/material.dart';

extension ExtString on String {
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );
    return emailRegex.hasMatch(this);
  }

  String get toCaptialized {
    return this[0].toUpperCase() + substring(1);
  }
}

extension PriceExtension on int {
  String get formatAmount {
    final str = toString();
    // crude grouping for demo: 1250000 -> 12,50,000
    if (str.length <= 3) return str;
    final last3 = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final buffer = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      final idxFromEnd = rest.length - i;
      buffer.write(rest[i]);
      if (idxFromEnd > 1 && idxFromEnd.isEven) buffer.write(',');
    }
    return '${buffer.toString()},$last3';
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
