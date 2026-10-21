import 'package:equatable/equatable.dart';
import 'package:snow_flow/shared/domain/local_date.dart';

/// One budget cycle (brief §4.4): from `cycleStartDay` of a month until the
/// day before the next cycle starts. A month shorter than the start day
/// starts on its last day, so 31 starts February on the 28th or 29th.
///
/// A cycle is named by the month it starts in, so one starting on 25 Dec
/// belongs to that December and that year (#12, to be reviewed in #64).
class Cycle extends Equatable {
  Cycle(this.year, this.month, {required this.startDay})
    : assert(month >= 1 && month <= 12),
      assert(startDay >= 1 && startDay <= 31);

  /// The cycle [date] falls in.
  factory Cycle.containing(LocalDate date, {required int startDay}) {
    final cycle = Cycle(date.year, date.month, startDay: startDay);
    return date < cycle.start ? cycle.previous : cycle;
  }

  /// The year and month the cycle starts in.
  final int year;
  final int month;

  /// `cycleStartDay` of the settings, 1–31.
  final int startDay;

  late final LocalDate start = LocalDate(
    year,
    month,
    startDay < _daysInMonth ? startDay : _daysInMonth,
  );

  /// The last day, the one before [next] starts.
  late final LocalDate end = next.start.day > 1
      ? LocalDate(next.start.year, next.start.month, next.start.day - 1)
      : LocalDate(year, month, _daysInMonth);

  Cycle get previous => month == 1
      ? Cycle(year - 1, 12, startDay: startDay)
      : Cycle(year, month - 1, startDay: startDay);

  Cycle get next => month == 12
      ? Cycle(year + 1, 1, startDay: startDay)
      : Cycle(year, month + 1, startDay: startDay);

  bool contains(LocalDate date) => start <= date && date <= end;

  int get _daysInMonth => LocalDate.daysInMonth(year, month);

  @override
  List<Object> get props => [year, month, startDay];

  @override
  String toString() => 'Cycle($start – $end)';
}
