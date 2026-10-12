import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/rating/rating_config.dart';
import 'package:kfon_subscriber/core/rating/rating_eligibility_manager.dart';
import 'package:kfon_subscriber/features/feedback/presentation/widgets/app_feedback_sheet.dart';

/// Single entry point for the automatic feedback prompt.
///
/// Call [maybeShow] from a safe, stable point of the signed-in UI; it checks
/// eligibility and that nothing else is on screen, then opens the feedback
/// sheet at most once per session.
class RatingPromptCoordinator {
  RatingPromptCoordinator._();

  static bool _busy = false;

  /// [isBusy] lets the caller veto the prompt while a critical operation is
  /// running (checked again after the settle delay).
  static Future<void> maybeShow(
    BuildContext context, {
    bool Function()? isBusy,
  }) async {
    final manager = RatingEligibilityManager.instance;
    if (_busy || !manager.isEligible()) return;
    _busy = true;
    try {
      await Future<void>.delayed(RatingConfig.promptDelay);
      if (!context.mounted) return;
      // Another route, dialog or sheet is on top, or the lifecycle is not
      // foregrounded: not a safe moment.
      final route = ModalRoute.of(context);
      if (route == null || !route.isCurrent) return;
      if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed &&
          WidgetsBinding.instance.lifecycleState != null) {
        return;
      }
      if (isBusy?.call() ?? false) return;
      if (!manager.isEligible()) return;

      await manager.markPromptShown();
      if (!context.mounted) return;
      final submitted = await showAppFeedbackSheet(context);
      if (submitted != true) await manager.recordDismissed();
    } finally {
      _busy = false;
    }
  }
}
