import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:snow_flow/core/l10n/app_locale.dart';

/// Flutter's Thai Material texts, but every year in the Buddhist era
/// (Common Era + 543), which intl cannot do. Wrap a date picker in
/// [withBuddhistYears] so its header, year list and read-out labels match
/// the rest of the app (#12, #61 Q2).
class BuddhistMaterialLocalizations extends MaterialLocalizationTh {
  BuddhistMaterialLocalizations()
    : super(
        // The same formats GlobalMaterialLocalizations.delegate builds.
        fullYearFormat: DateFormat.y(_th),
        compactDateFormat: DateFormat.yMd(_th),
        shortDateFormat: DateFormat.yMMMd(_th),
        mediumDateFormat: DateFormat.MMMEd(_th),
        longDateFormat: DateFormat.yMMMMEEEEd(_th),
        yearMonthFormat: DateFormat.yMMMM(_th),
        shortMonthDayFormat: DateFormat.MMMd(_th),
        decimalFormat: NumberFormat.decimalPattern(_th),
        twoDigitZeroPaddedFormat: NumberFormat('00', _th),
      );

  static const _th = 'th';

  /// Swaps the Common Era year in [text] for the Buddhist one. No other
  /// part of a date has four digits.
  static String _buddhist(String text, DateTime date) =>
      text.replaceAll('${date.year}', '${date.year + 543}');

  @override
  String formatYear(DateTime date) => _buddhist(super.formatYear(date), date);

  @override
  String formatCompactDate(DateTime date) =>
      _buddhist(super.formatCompactDate(date), date);

  @override
  String formatShortDate(DateTime date) =>
      _buddhist(super.formatShortDate(date), date);

  @override
  String formatFullDate(DateTime date) =>
      _buddhist(super.formatFullDate(date), date);

  @override
  String formatMonthYear(DateTime date) =>
      _buddhist(super.formatMonthYear(date), date);
}

class _BuddhistDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _BuddhistDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == thai.languageCode;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    _symbolsLoaded;
    return SynchronousFuture(BuddhistMaterialLocalizations());
  }

  @override
  bool shouldReload(_BuddhistDelegate old) => false;
}

/// [child] with Buddhist years when the app is in Thai; unchanged in
/// English.
Widget withBuddhistYears(BuildContext context, Widget child) =>
    Localizations.localeOf(context).languageCode == thai.languageCode
    ? Localizations.override(
        context: context,
        delegates: const [_BuddhistDelegate()],
        child: child,
      )
    : child;

/// intl needs its Thai month names loaded before the first format.
final Object _symbolsLoaded = initializeDateFormatting();
