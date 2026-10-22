import 'package:equatable/equatable.dart';
import 'package:snow_flow/shared/domain/cycle.dart';
import 'package:snow_flow/shared/domain/local_date.dart';

/// The days of one bar in the summary chart: one day, or one cycle.
class Period extends Equatable {
  const Period(this.start, this.end);

  const Period.day(LocalDate date) : this(date, date);

  final LocalDate start;
  final LocalDate end;

  bool contains(LocalDate date) => start <= date && date <= end;

  @override
  List<Object> get props => [start, end];

  @override
  String toString() => 'Period($start – $end)';
}

/// What the summary page shows at once (brief §4.3), split into the bars of
/// its chart. Moves back and forth with [previous] and [next].
sealed class SummaryRange extends Equatable {
  const SummaryRange();

  LocalDate get start;
  LocalDate get end;
  List<Period> get periods;
  SummaryRange get previous;
  SummaryRange get next;

  bool contains(LocalDate date) => start <= date && date <= end;
}

/// "รายวัน": each day of one cycle.
class DailyRange extends SummaryRange {
  const DailyRange(this.cycle);

  final Cycle cycle;

  @override
  LocalDate get start => cycle.start;

  @override
  LocalDate get end => cycle.end;

  @override
  List<Period> get periods => [
    for (var day = cycle.start; day <= cycle.end; day = day.nextDay)
      Period.day(day),
  ];

  @override
  DailyRange get previous => DailyRange(cycle.previous);

  @override
  DailyRange get next => DailyRange(cycle.next);

  @override
  List<Object> get props => [cycle];
}

/// "รายเดือน": the 12 cycles starting in [year], so one starting on 25 Dec
/// belongs to that year even though it ends in the next (#12).
class MonthlyRange extends SummaryRange {
  const MonthlyRange(this.year, {required this.startDay});

  /// The year of the cycle [date] falls in, which is last year in early
  /// January when the cycle started in December.
  factory MonthlyRange.containing(LocalDate date, {required int startDay}) =>
      MonthlyRange(
        Cycle.containing(date, startDay: startDay).year,
        startDay: startDay,
      );

  final int year;

  /// `cycleStartDay` of the settings, 1–31.
  final int startDay;

  List<Cycle> get cycles => [
    for (var month = 1; month <= 12; month++)
      Cycle(year, month, startDay: startDay),
  ];

  @override
  LocalDate get start => Cycle(year, 1, startDay: startDay).start;

  @override
  LocalDate get end => Cycle(year, 12, startDay: startDay).end;

  @override
  List<Period> get periods => [
    for (final cycle in cycles) Period(cycle.start, cycle.end),
  ];

  @override
  MonthlyRange get previous => MonthlyRange(year - 1, startDay: startDay);

  @override
  MonthlyRange get next => MonthlyRange(year + 1, startDay: startDay);

  @override
  List<Object> get props => [year, startDay];
}
