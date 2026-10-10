import 'package:flutter/widgets.dart';
import 'package:kfon_subscriber/core/routes/navigator_key.dart';
import 'bss_sub_localizations.dart';

extension BssSub10n on BuildContext {
  BssSubLocalizations get bssSubL10n => BssSubLocalizations.of(this)!;
}

/// Localizations for code that has no [BuildContext] (blocs, repositories,
/// validators, static helpers). Uses the app's current locale through the
/// root navigator, and falls back to English before the app is built.
///
/// Prefer `context.bssLNPL10n` wherever a context is available. Never cache
/// the returned object: call `appL10n` each time so a language change applies.
BssSubLocalizations get appL10n {
  final context = navigatorKey.currentContext;
  if (context != null) {
    final localizations = BssSubLocalizations.of(context);
    if (localizations != null) return localizations;
  }
  return lookupBssSubLocalizations(const Locale('en'));
}
