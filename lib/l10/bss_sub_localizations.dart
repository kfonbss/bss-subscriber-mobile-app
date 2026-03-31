import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'bss_sub_localizations_en.dart';

abstract class BssSubLocalizations {
  BssSubLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static BssSubLocalizations? of(BuildContext context) {
    return Localizations.of<BssSubLocalizations>(context, BssSubLocalizations);
  }

  static const LocalizationsDelegate<BssSubLocalizations> delegate =
      _BssSubLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  String get stayConnectedAlways;
  String get experienceLightningFast;
  String get bridgingDigitalDivide;
  String get kfonEmpowersCitizen;
  String get internetWorksForYou;
  String get enjoyHighSpeed;
}

class _BssSubLocalizationsDelegate
    extends LocalizationsDelegate<BssSubLocalizations> {
  const _BssSubLocalizationsDelegate();

  @override
  Future<BssSubLocalizations> load(Locale locale) {
    return SynchronousFuture<BssSubLocalizations>(
      lookupBssLNPLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_BssSubLocalizationsDelegate old) => false;
}

BssSubLocalizations lookupBssLNPLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return BssSubLocalizationsEn();
  }

  throw FlutterError(
    'BssSubLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
