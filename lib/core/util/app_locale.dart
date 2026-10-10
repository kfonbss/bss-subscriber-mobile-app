import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:flutter/material.dart';

/// The language the user picked on the language page.
///
/// [notifier] holds the chosen [Locale], or null to follow the device language.
/// `MyApp` listens to it and feeds it to `MaterialApp.locale`, so changing it
/// switches the whole app immediately. The choice is saved on the device and
/// restored on the next launch (see [load]).
class AppLocale {
  AppLocale._();

  static const List<Locale> supported = [Locale('en'), Locale('hi')];

  static final ValueNotifier<Locale?> notifier = ValueNotifier<Locale?>(null);

  /// Reads the saved language. Call once before `runApp`.
  static Future<void> load() async {
    final code = await PreferenceUtils.getLanguageCode();
    // for (final locale in supported) {
    //   if (locale.languageCode == code) {
    //     notifier.value = locale;
    //     return;
    //   }
    // }
    final locale = supported.firstWhere(
      (locale) => locale.languageCode == code,
      orElse: () => supported.first,
    );
    notifier.value = locale;
  }

  /// Applies [locale] to the whole app and saves it.
  static Future<void> set(Locale locale) async {
    notifier.value = locale;
    await PreferenceUtils.setLanguageCode(locale.languageCode);
  }
}
