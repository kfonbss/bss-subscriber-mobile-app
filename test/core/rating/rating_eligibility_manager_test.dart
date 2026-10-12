import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/core/rating/rating_eligibility_manager.dart';

class _MemoryStore implements RatingTrackingStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String json) async => value = json;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final day0 = DateTime(2026, 1, 1, 10);
  DateTime day(int n) => day0.add(Duration(days: n));

  /// Simulates one cold start on [when] against a shared store.
  Future<RatingEligibilityManager> launch(
    _MemoryStore store,
    DateTime when,
  ) async {
    final m = RatingEligibilityManager(store: store);
    await m.init(now: when);
    return m;
  }

  test('fresh install is not eligible', () async {
    final m = await launch(_MemoryStore(), day0);
    expect(m.isEligible(now: day0), isFalse);
  });

  test('init twice does not double count launches', () async {
    final store = _MemoryStore();
    final m = await launch(store, day0);
    await m.init(now: day0);
    expect(store.value, contains('"launches":1'));
  });

  test('needs launches, active days and elapsed days together', () async {
    final store = _MemoryStore();
    // 4 launches on 3 days: launches short.
    for (final d in [0, 0, 1, 3]) {
      await launch(store, day(d));
    }
    expect(
      (await launch(
        _MemoryStore()..value = store.value,
        day(3),
      )).isEligible(now: day(3)),
      isTrue,
      reason: '5th launch, 3 active days, 3 days elapsed',
    );

    final fewDays = _MemoryStore();
    for (final d in [0, 0, 0, 0, 3]) {
      await launch(fewDays, day(d));
    }
    expect(
      (await launch(fewDays, day(3))).isEligible(now: day(3)),
      isFalse,
      reason: 'only 2 active days',
    );

    final fewLaunches = _MemoryStore();
    for (final d in [0, 1, 3]) {
      await launch(fewLaunches, day(d));
    }
    expect(
      (await launch(fewLaunches, day(3))).isEligible(now: day(3)),
      isFalse,
      reason: 'only 4 launches',
    );
  });

  Future<_MemoryStore> eligibleStore() async {
    final store = _MemoryStore();
    for (final d in [0, 1, 2, 3]) {
      await launch(store, day(d));
    }
    return store;
  }

  test('prompt shown once per session and cooldown respected', () async {
    final store = await eligibleStore();
    final m = await launch(store, day(3));
    expect(m.isEligible(now: day(3)), isTrue);

    await m.markPromptShown(now: day(3));
    expect(m.isEligible(now: day(3)), isFalse, reason: 'same session');

    await m.recordDismissed(now: day(3));
    final restarted = await launch(store, day(10));
    expect(restarted.isEligible(now: day(10)), isFalse, reason: 'cooldown');
    final later = await launch(store, day(17));
    expect(later.isEligible(now: day(17)), isTrue, reason: 'cooldown over');
  });

  test('submitted feedback disables prompts and survives restart', () async {
    final store = await eligibleStore();
    final m = await launch(store, day(3));
    await m.recordSubmitted();
    expect((await launch(store, day(60))).isEligible(now: day(60)), isFalse);
  });

  test('failed submission leaves user eligible after cooldown', () async {
    final store = await eligibleStore();
    final m = await launch(store, day(3));
    await m.markPromptShown(now: day(3));
    // No recordSubmitted() on failure.
    expect((await launch(store, day(30))).isEligible(now: day(30)), isTrue);
  });

  test('corrupt stored data does not crash', () async {
    final store = _MemoryStore()..value = 'not json';
    final m = await launch(store, day0);
    expect(m.isEligible(now: day0), isFalse);
  });
}
