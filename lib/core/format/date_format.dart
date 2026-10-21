import 'dart:ui';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:snow_flow/core/l10n/app_locale.dart';
import 'package:snow_flow/shared/domain/cycle.dart';
import 'package:snow_flow/shared/domain/local_date.dart';

/// Dates for display, day before month in both languages (#14). Thai shows
/// the Buddhist year (Common Era + 543), which intl cannot do, so the year is
/// always added here; stored dates stay Common Era (#12). Digits are 0–9.

/// "ตุลาคม 2569" / "October 2026"
String formatMonth(int year, int month, Locale locale) =>
    '${_format('MMMM', locale, DateTime(year, month))} '
    '${_year(year, locale)}';

/// The cycle's label (brief §4.4): its month, "ตุลาคม 2569", when it starts
/// on the 1st; otherwise its range, "25 ก.ย. – 24 ต.ค. 2569".
String formatCycle(Cycle cycle, Locale locale) => cycle.startDay == 1
    ? formatMonth(cycle.year, cycle.month, locale)
    : formatRange(cycle.start, cycle.end, locale);

/// "25 ก.ย. – 24 ต.ค. 2569"; a range across new year shows both years,
/// "25 ธ.ค. 2569 – 24 ม.ค. 2570" (#12).
String formatRange(LocalDate start, LocalDate end, Locale locale) {
  final from = start.year == end.year
      ? _dayMonth(start, locale)
      : formatDate(start, locale);
  return '$from – ${formatDate(end, locale)}';
}

/// "3 ต.ค. 2569" / "3 Oct 2026"
String formatDate(LocalDate date, Locale locale) =>
    '${_dayMonth(date, locale)} ${_year(date.year, locale)}';

/// The entries list's day header: "ศุกร์ 2 ต.ค." / "Fri, 2 Oct". A day not
/// in [today]'s year adds the year, so last year never looks like this one
/// (#52).
String formatDayHeader(
  LocalDate date,
  Locale locale, {
  required LocalDate today,
}) {
  final weekday = _isThai(locale)
      // intl's Thai full name is "วันศุกร์"; the header drops "วัน" (#52).
      ? '${_format('EEEE', locale, _dateTime(date)).replaceFirst('วัน', '')} '
      : '${_format('EEE', locale, _dateTime(date))}, ';
  final header = '$weekday${_dayMonth(date, locale)}';
  return date.year == today.year
      ? header
      : '$header ${_year(date.year, locale)}';
}

bool _isThai(Locale locale) => locale.languageCode == thai.languageCode;

int _year(int year, Locale locale) => _isThai(locale) ? year + 543 : year;

String _dayMonth(LocalDate date, Locale locale) =>
    _format('d MMM', locale, _dateTime(date));

DateTime _dateTime(LocalDate date) => DateTime(date.year, date.month, date.day);

String _format(String pattern, Locale locale, DateTime time) {
  _symbolsLoaded;
  return DateFormat(pattern, locale.languageCode).format(time);
}

/// intl needs its Thai month and day names loaded before the first format.
/// The local data loads at once even though the call returns a Future.
final Object _symbolsLoaded = initializeDateFormatting();
