import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/shared/widgets/plan_validity_badge.dart';

void main() {
  group('PlanValidityBadge.daysRemaining', () {
    int days(DateTime until, DateTime now) =>
        PlanValidityBadge.daysRemaining(until, now: now);

    test('is 0 on the end date (Expires today)', () {
      expect(
        days(DateTime(2026, 11, 16, 23, 59), DateTime(2026, 11, 16, 8)),
        0,
      );
    });

    test('is 1 when the plan ends tomorrow, even under 24 hours away', () {
      // 16 hours left, but the end date is tomorrow.
      expect(days(DateTime(2026, 11, 17, 8), DateTime(2026, 11, 16, 16)), 1);
    });

    test('counts whole calendar days ahead', () {
      expect(days(DateTime(2026, 11, 21), DateTime(2026, 11, 16, 22)), 5);
    });

    test('is negative once the end date has passed', () {
      expect(days(DateTime(2026, 11, 12), DateTime(2026, 11, 16)), -4);
    });

    test('is not thrown off by a daylight-saving change', () {
      // Spans the US/EU autumn clock change; dates are compared, not hours.
      expect(days(DateTime(2026, 11, 3), DateTime(2026, 10, 24)), 10);
    });
  });

  group('PlanValidityBadge.isExpired', () {
    final activeUntil = DateTime(2026, 11, 12);

    test('is not expired before the end date', () {
      expect(
        PlanValidityBadge.isExpired(activeUntil, now: DateTime(2026, 11, 10)),
        isFalse,
      );
    });

    test('is still valid for the whole end date', () {
      expect(
        PlanValidityBadge.isExpired(
          activeUntil,
          now: DateTime(2026, 11, 12, 23, 59),
        ),
        isFalse,
      );
    });

    test('expires from the next day', () {
      expect(
        PlanValidityBadge.isExpired(activeUntil, now: DateTime(2026, 11, 13)),
        isTrue,
      );
    });

    test('is expired well after the end date (reported case)', () {
      expect(
        PlanValidityBadge.isExpired(activeUntil, now: DateTime(2026, 11, 16)),
        isTrue,
      );
    });

    test('ignores the time of day on the end date', () {
      expect(
        PlanValidityBadge.isExpired(
          DateTime(2026, 11, 12, 0, 1),
          now: DateTime(2026, 11, 12, 18),
        ),
        isFalse,
      );
    });

    test('handles a year boundary', () {
      expect(
        PlanValidityBadge.isExpired(
          DateTime(2026, 12, 31),
          now: DateTime(2027, 1, 1),
        ),
        isTrue,
      );
    });
  });
}
