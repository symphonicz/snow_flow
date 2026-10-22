import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/features/summary/domain/summary_range.dart';
import 'package:snow_flow/shared/domain/cycle.dart';
import 'package:snow_flow/shared/domain/local_date.dart';

void main() {
  group('daily: the days of one cycle (brief §4.3)', () {
    test('runs from the cycle start to its end', () {
      final range = DailyRange(Cycle(2026, 9, startDay: 25));

      expect(range.start, LocalDate(2026, 9, 25));
      expect(range.end, LocalDate(2026, 10, 24));
      expect(range.periods.length, 30);
      expect(range.periods.first, Period(range.start, range.start));
      expect(range.periods[6], Period.day(LocalDate(2026, 10, 1)));
      expect(range.periods.last, Period.day(range.end));
    });

    test('a cycle from 31 January lasts until 27 February (common year)', () {
      final range = DailyRange(Cycle(2026, 1, startDay: 31));

      expect(range.periods.length, 28);
      expect(range.periods.last, Period.day(LocalDate(2026, 2, 27)));
    });

    test('February set to 31 runs from the 29th in a leap year', () {
      final range = DailyRange(Cycle(2028, 2, startDay: 31));

      expect(range.periods.first, Period.day(LocalDate(2028, 2, 29)));
      expect(range.periods.last, Period.day(LocalDate(2028, 3, 30)));
      expect(range.periods.length, 31);
    });

    test('moves one cycle at a time', () {
      final range = DailyRange(Cycle(2026, 12, startDay: 25));

      expect(range.next, DailyRange(Cycle(2027, 1, startDay: 25)));
      expect(range.previous, DailyRange(Cycle(2026, 11, startDay: 25)));
    });
  });

  group('monthly: the 12 cycles starting in one year (brief §4.3, #12)', () {
    test('a cycle across new year belongs to the year it starts', () {
      final range = MonthlyRange(2026, startDay: 25);

      expect(range.periods.length, 12);
      expect(
        range.periods.first,
        Period(LocalDate(2026, 1, 25), LocalDate(2026, 2, 24)),
      );
      expect(
        range.periods.last,
        Period(LocalDate(2026, 12, 25), LocalDate(2027, 1, 24)),
      );
      expect(range.start, LocalDate(2026, 1, 25));
      expect(range.end, LocalDate(2027, 1, 24));
    });

    test('starting on the 1st is the calendar year', () {
      final range = MonthlyRange(2026, startDay: 1);

      expect(range.start, LocalDate(2026, 1, 1));
      expect(range.end, LocalDate(2026, 12, 31));
      expect(
        range.periods[1],
        Period(LocalDate(2026, 2, 1), LocalDate(2026, 2, 28)),
      );
    });

    test('containing: early January can still be last year', () {
      expect(
        MonthlyRange.containing(LocalDate(2027, 1, 5), startDay: 25),
        MonthlyRange(2026, startDay: 25),
      );
      expect(
        MonthlyRange.containing(LocalDate(2027, 1, 25), startDay: 25),
        MonthlyRange(2027, startDay: 25),
      );
    });

    test('moves one year at a time', () {
      final range = MonthlyRange(2026, startDay: 25);

      expect(range.next, MonthlyRange(2027, startDay: 25));
      expect(range.previous, MonthlyRange(2025, startDay: 25));
    });
  });
}
