/// Thresholds for the automatic feedback prompt. Change them here only.
class RatingConfig {
  const RatingConfig._();

  /// Distinct calendar days the app must have been used.
  static const int minActiveDays = 3;

  /// App launches (cold starts) required.
  static const int minLaunches = 5;

  /// Calendar days that must pass after the first recorded launch.
  static const int minDaysSinceFirstLaunch = 3;

  /// Calendar days to wait after a prompt was shown / dismissed.
  static const int dismissalCooldownDays = 14;

  /// Delay after landing on the trigger point before the prompt opens, so
  /// tab/route animations have settled.
  static const Duration promptDelay = Duration(milliseconds: 800);

  /// Upper bound on stored active-day entries (only the count matters).
  static const int maxStoredActiveDays = 30;
}
