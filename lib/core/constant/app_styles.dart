import 'package:flutter/material.dart';

class AppStyles {
  AppStyles._();

  static final boxDecorationSmall = BoxDecoration(
    color: Colors.white,
    boxShadow: boxShadowForWhite,
    borderRadius: BorderRadius.circular(8.0),
  );
  static final boxDecorationMedium = BoxDecoration(
    color: Colors.white,
    boxShadow: boxShadowForWhite,
    borderRadius: BorderRadius.circular(12.0),
  );
  static final boxDecorationLarge = BoxDecoration(
    color: Colors.white,
    boxShadow: boxShadowForWhite,
    borderRadius: BorderRadius.circular(16.0),
  );
  static final tabBarDecoration = BoxDecoration(
    color: Colors.black.withValues(alpha: 0.04),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.white, width: 1),
  );
  static final List<BoxShadow> boxShadowForWhite = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static final inputDecorationLight = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
