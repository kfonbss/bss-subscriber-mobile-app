import 'package:flutter/material.dart';

/// Global navigator key for app-wide navigation
/// Used by interceptors and services that need navigation without BuildContext
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
