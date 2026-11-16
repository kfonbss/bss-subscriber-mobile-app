import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

/// Pill showing how long the plan has left, counted in calendar days from
/// [activeUntil]:
///
/// | End date      | Pill           |
/// |---------------|----------------|
/// | passed        | Expired        |
/// | today         | Expires today  |
/// | tomorrow      | 1 Day left     |
/// | in N days     | N Days left    |
///
/// The API's `daysLeft` is not used: it rounds partial days down, so a plan
/// ending tomorrow morning reads 0, and it stays 0 after expiry.
class PlanValidityBadge extends StatelessWidget {
  final DateTime activeUntil;

  const PlanValidityBadge({super.key, required this.activeUntil});

  /// Calendar days from today to [activeUntil] (local time): 0 on the end
  /// date, negative once it has passed. [now] is only for tests.
  static int daysRemaining(DateTime activeUntil, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final until = activeUntil.toLocal();
    // UTC dates, so a daylight-saving shift can't make a day 23 hours long.
    final today = DateTime.utc(current.year, current.month, current.day);
    final end = DateTime.utc(until.year, until.month, until.day);
    return end.difference(today).inDays;
  }

  /// True once the calendar day after [activeUntil] has started.
  static bool isExpired(DateTime activeUntil, {DateTime? now}) =>
      daysRemaining(activeUntil, now: now) < 0;

  static const _activeDecoration = BoxDecoration(
    color: AppColor.kAutopayButtonColor,
    borderRadius: BorderRadius.all(Radius.circular(50)),
  );

  static final _expiredDecoration = BoxDecoration(
    color: AppColor.kFailedRed.withValues(alpha: 0.12),
    borderRadius: const BorderRadius.all(Radius.circular(50)),
  );

  static final _textStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontSize: 12.sp,
    color: AppColor.kTextSecondaryDark,
  );

  static final _urgentTextStyle = _textStyle.copyWith(
    color: AppColor.kFailedRed,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final days = daysRemaining(activeUntil);

    final (
      String label,
      BoxDecoration decoration,
      TextStyle style,
    ) = switch (days) {
      < 0 => (l10n.planExpired, _expiredDecoration, _urgentTextStyle),
      0 => (l10n.planExpiresToday, _activeDecoration, _urgentTextStyle),
      _ => (l10n.daysLeft(days), _activeDecoration, _textStyle),
    };

    return Container(
      height: 28.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: decoration,
      child: Text(label, style: style),
    );
  }
}
