import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:kfon_subscriber/core/rating/rating_config.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';

/// Persistence for the tracking blob (swappable in tests).
abstract class RatingTrackingStore {
  Future<String?> read();
  Future<void> write(String json);
}

class PreferenceRatingTrackingStore implements RatingTrackingStore {
  const PreferenceRatingTrackingStore();

  @override
  Future<String?> read() => PreferenceUtils.getRatingTracking();

  @override
  Future<void> write(String json) => PreferenceUtils.setRatingTracking(json);
}

/// Tracks app usage and decides whether the feedback prompt may be shown.
///
/// * A *launch* is counted once per process, in [init].
/// * An *active day* is recorded at launch and when the app returns to the
///   foreground; a resume is never counted as a launch.
/// * All state is persisted as one JSON blob and survives logout.
class RatingEligibilityManager with WidgetsBindingObserver {
  RatingEligibilityManager({RatingTrackingStore? store})
    : _store = store ?? const PreferenceRatingTrackingStore();

  static final RatingEligibilityManager instance = RatingEligibilityManager();

  final RatingTrackingStore _store;

  DateTime? _firstLaunch;
  int _launches = 0;
  final Set<String> _activeDays = <String>{};
  DateTime? _lastPrompt;
  bool _feedbackSubmitted = false;

  bool _initialized = false;
  bool _promptedThisSession = false;
  Future<void> _writeQueue = Future<void>.value();

  /// Loads persisted state and counts this launch. Safe to call repeatedly:
  /// only the first call has any effect.
  Future<void> init({DateTime? now}) async {
    if (_initialized) return;
    _initialized = true;
    final today = now ?? DateTime.now();
    await _load();
    _firstLaunch ??= _dateOnly(today);
    _launches++;
    _addActiveDay(today);
    await _persist();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _initialized) {
      final before = _activeDays.length;
      _addActiveDay(DateTime.now());
      if (_activeDays.length != before) _persist();
    }
  }

  /// True when every threshold in [RatingConfig] is met.
  bool isEligible({DateTime? now}) {
    if (!_initialized || _feedbackSubmitted || _promptedThisSession) {
      return false;
    }
    final today = _dateOnly(now ?? DateTime.now());
    final first = _firstLaunch;
    if (first == null) return false;
    if (_launches < RatingConfig.minLaunches) return false;
    if (_activeDays.length < RatingConfig.minActiveDays) return false;
    if (today.difference(first).inDays < RatingConfig.minDaysSinceFirstLaunch) {
      return false;
    }
    final last = _lastPrompt;
    if (last != null &&
        today.difference(_dateOnly(last)).inDays <
            RatingConfig.dismissalCooldownDays) {
      return false;
    }
    return true;
  }

  /// Call when the prompt is displayed. Starts the cooldown immediately, so a
  /// prompt interrupted by the app being killed is not repeated at once.
  Future<void> markPromptShown({DateTime? now}) {
    _promptedThisSession = true;
    _lastPrompt = now ?? DateTime.now();
    return _persist();
  }

  /// Call when the prompt is closed without a successful submission.
  Future<void> recordDismissed({DateTime? now}) {
    _lastPrompt = now ?? DateTime.now();
    return _persist();
  }

  /// Call only after the server confirmed the feedback.
  Future<void> recordSubmitted() {
    _feedbackSubmitted = true;
    return _persist();
  }

  // ── Persistence ─────────────────────────────────────────────────────────
  Future<void> _load() async {
    try {
      final raw = await _store.read();
      if (raw == null || raw.isEmpty) return;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _firstLaunch = DateTime.tryParse(json['firstLaunch']?.toString() ?? '');
      _launches = (json['launches'] as num?)?.toInt() ?? 0;
      _activeDays.addAll(
        (json['activeDays'] as List?)?.map((e) => e.toString()) ?? const [],
      );
      _lastPrompt = DateTime.tryParse(json['lastPrompt']?.toString() ?? '');
      _feedbackSubmitted = json['submitted'] == true;
    } catch (_) {
      // Corrupt or unreadable data: start fresh rather than crash the app.
    }
  }

  /// Writes are chained so concurrent updates cannot interleave.
  Future<void> _persist() {
    final payload = jsonEncode({
      'firstLaunch': _firstLaunch?.toIso8601String(),
      'launches': _launches,
      'activeDays': _activeDays.toList(),
      'lastPrompt': _lastPrompt?.toIso8601String(),
      'submitted': _feedbackSubmitted,
    });
    _writeQueue = _writeQueue.then((_) async {
      try {
        await _store.write(payload);
      } catch (_) {
        // Tracking is best-effort; never surface storage errors to the user.
      }
    });
    return _writeQueue;
  }

  void _addActiveDay(DateTime date) {
    if (_activeDays.length >= RatingConfig.maxStoredActiveDays) return;
    _activeDays.add(_dayKey(date));
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
