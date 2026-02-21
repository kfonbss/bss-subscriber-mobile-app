import 'package:flutter/widgets.dart';

/// A utility class for creating responsive layouts.
///
/// This class needs to be initialized once in your app, typically in the `builder`
/// of your `MaterialApp`.
///
/// Usage:
///
/// 1. Initialize in `MaterialApp`:
/// ```dart
/// MaterialApp(
///   builder: (context, child) {
///     Sizer.init(context); // Initialize Sizer
///     return child!;
///   },
///   home: HomeScreen(),
/// );
/// ```
///
/// 2. Use in your widgets:
/// ```dart
/// Container(
///   height: 100.h, // 100 logical pixels height on the design canvas
///   width: 50.w,   // 50 logical pixels width on the design canvas
///   child: Text(
///     'Hello',
///     style: TextStyle(fontSize: 16.sp), // 16 logical pixels font size
///   ),
/// );
/// ```
class Sizer {
  /// The design canvas width. Defaults to 375.0 (e.g., iPhone X).
  static const double _designWidth = 375.0;

  /// The design canvas height. Defaults to 812.0 (e.g., iPhone X).
  static const double _designHeight = 812.0;

  /// The screen's physical width in logical pixels.
  static double screenWidth = _designWidth;

  /// The screen's physical height in logical pixels.
  static double screenHeight = _designHeight;

  /// The ratio of the screen's width to the design width.
  static double _widthRatio = 1.0;

  /// The ratio of the screen's height to the design height.
  static double _heightRatio = 1.0;

  /// Flag to track if Sizer has been initialized.
  static bool _isInitialized = false;

  /// Initializes the Sizer.
  ///
  /// Must be called before using the extension methods.
  /// Best placed in the `builder` of `MaterialApp`.
  ///
  /// [context] is the `BuildContext` from which to get screen dimensions.
  /// You can optionally provide a custom [designWidth] and [designHeight]
  /// if your UI design canvas has different dimensions.
  static void init(
    BuildContext context, {
    double designWidth = _designWidth,
    double designHeight = _designHeight,
  }) {
    try {
      final mediaQuery = MediaQuery.maybeOf(context);
      if (mediaQuery != null) {
        screenWidth = mediaQuery.size.width;
        screenHeight = mediaQuery.size.height;
        _widthRatio = screenWidth / designWidth;
        _heightRatio = screenHeight / designHeight;
        _isInitialized = true;
      } else {
        // Fallback if MediaQuery is not available
        _isInitialized = false;
      }
    } catch (e) {
      // If initialization fails, use default values
      _isInitialized = false;
    }
  }

  /// Calculates a responsive width.
  /// [width] is the width on the design canvas.
  static double getWidth(num width) {
    if (!_isInitialized || _widthRatio <= 0) {
      return width.toDouble();
    }
    return width * _widthRatio;
  }

  /// Calculates a responsive height.
  /// [height] is the height on the design canvas.
  static double getHeight(num height) {
    if (!_isInitialized || _heightRatio <= 0) {
      return height.toDouble();
    }
    return height * _heightRatio;
  }

  /// Calculates a responsive font size.
  /// It takes the average of the width and height scaling factors to provide
  /// a balanced text size.
  /// [size] is the font size on the design canvas.
  static double getSp(num size) {
    if (!_isInitialized || _widthRatio <= 0 || _heightRatio <= 0) {
      return size.toDouble();
    }
    // Using the average of width and height ratios for a more balanced scaling.
    final scale = (_widthRatio + _heightRatio) / 2;
    return size * scale;
  }

  /// Returns true if the screen width is 600 or greater (tablet size).
  static bool get isTablet => screenWidth >= 600;
}

/// Extension methods for `num` to provide a clean and concise syntax for
/// responsive sizing.
extension SizerExt on num {
  /// Calculates a responsive height based on the design canvas.
  ///
  /// Example: `100.h`
  double get h => Sizer.getHeight(this);

  /// Calculates a responsive width based on the design canvas.
  ///
  /// Use for widths, margins, padding, etc.
  /// Example: `50.w`
  double get w => Sizer.getWidth(this);

  /// Calculates a responsive font size.
  ///
  /// Example: `16.sp`
  double get sp => Sizer.getSp(this);
}

