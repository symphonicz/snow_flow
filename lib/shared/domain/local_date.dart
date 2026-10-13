import 'package:equatable/equatable.dart';

/// A calendar day with no time or time zone, stored as `YYYY-MM-DD` (#17).
/// Not a [DateTime], so a day saved in Thailand stays the same day in Japan.
class LocalDate extends Equatable implements Comparable<LocalDate> {
  LocalDate(this.year, this.month, this.day) {
    if (!_exists(year, month, day)) {
      throw ArgumentError('No such day: $year-$month-$day');
    }
  }

  /// Today on this device, or the local day of [time].
  factory LocalDate.fromDateTime(DateTime time) =>
      LocalDate(time.year, time.month, time.day);

  static final _format = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  /// Reads exactly `YYYY-MM-DD`; null when the format is wrong or the day
  /// does not exist.
  static LocalDate? tryParse(String text) {
    final match = _format.firstMatch(text);
    if (match == null) return null;
    final [year, month, day] = [
      for (var i = 1; i <= 3; i++) int.parse(match.group(i)!),
    ];
    return _exists(year, month, day) ? LocalDate(year, month, day) : null;
  }

  static bool _exists(int year, int month, int day) =>
      month >= 1 && month <= 12 && day >= 1 && day <= daysInMonth(year, month);

  static int daysInMonth(int year, int month) => switch (month) {
    2 => _isLeapYear(year) ? 29 : 28,
    4 || 6 || 9 || 11 => 30,
    _ => 31,
  };

  static bool _isLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  bool operator <(LocalDate other) => compareTo(other) < 0;
  bool operator <=(LocalDate other) => compareTo(other) <= 0;
  bool operator >(LocalDate other) => compareTo(other) > 0;
  bool operator >=(LocalDate other) => compareTo(other) >= 0;

  @override
  List<Object> get props => [year, month, day];

  @override
  String toString() =>
      '${'$year'.padLeft(4, '0')}-${'$month'.padLeft(2, '0')}-'
      '${'$day'.padLeft(2, '0')}';
}
