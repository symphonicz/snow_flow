import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/shared/domain/cycle.dart';
import 'package:snow_flow/shared/domain/local_date.dart';

void main() {
  group('Cycle.containing', () {
    test('start day 1 is the calendar month', () {
      final cycle = Cycle.containing(LocalDate(2026, 10, 15), startDay: 1);

      expect(cycle.start, LocalDate(2026, 10, 1));
      expect(cycle.end, LocalDate(2026, 10, 31));
    });

    test('a day before the start day belongs to the cycle of last month', () {
      final cycle = Cycle.containing(LocalDate(2026, 10, 3), startDay: 25);

      expect(cycle.start, LocalDate(2026, 9, 25));
      expect(cycle.end, LocalDate(2026, 10, 24));
    });

    test('the start day itself opens a new cycle', () {
      final cycle = Cycle.containing(LocalDate(2026, 10, 25), startDay: 25);

      expect(cycle.start, LocalDate(2026, 10, 25));
      expect(cycle.end, LocalDate(2026, 11, 24));
    });

    test('a cycle across new year belongs to the year it starts (#12)', () {
      final cycle = Cycle.containing(LocalDate(2027, 1, 10), startDay: 25);

      expect(cycle.start, LocalDate(2026, 12, 25));
      expect(cycle.end, LocalDate(2027, 1, 24));
      expect((cycle.year, cycle.month), (2026, 12));
    });

    test('changing the start day mid-cycle gives the new cycle at once', () {
      final day = LocalDate(2026, 10, 20);

      expect(Cycle.containing(day, startDay: 25).start, LocalDate(2026, 9, 25));
      expect(
        Cycle.containing(day, startDay: 15).start,
        LocalDate(2026, 10, 15),
      );
    });
  });

  group('a start day past the end of the month', () {
    test('31 starts February on the 29th in a leap year', () {
      final february = Cycle(2028, 2, startDay: 31);

      expect(february.start, LocalDate(2028, 2, 29));
      expect(february.end, LocalDate(2028, 3, 30));
      expect(february.previous.end, LocalDate(2028, 2, 28));
    });

    test('31 starts February on the 28th in a common year', () {
      final february = Cycle(2026, 2, startDay: 31);

      expect(february.start, LocalDate(2026, 2, 28));
      expect(february.previous.end, LocalDate(2026, 2, 27));
    });

    test('31 starts April on the 30th, so March ends on the 29th', () {
      expect(Cycle(2026, 3, startDay: 31).end, LocalDate(2026, 4, 29));
    });

    test('30 ends a cycle on the 29th even when the month has 31 days', () {
      final march = Cycle(2026, 3, startDay: 30);

      expect(march.start, LocalDate(2026, 3, 30));
      expect(march.end, LocalDate(2026, 4, 29));
    });

    test('29 in a common year starts February on the 28th', () {
      final january = Cycle(2026, 1, startDay: 29);

      expect(january.end, LocalDate(2026, 2, 27));
      expect(january.next.start, LocalDate(2026, 2, 28));
      expect(january.next.end, LocalDate(2026, 3, 28));
    });

    test('the last days of a short month fall in the right cycle', () {
      expect(
        Cycle.containing(LocalDate(2026, 2, 28), startDay: 31),
        Cycle(2026, 2, startDay: 31),
      );
      expect(
        Cycle.containing(LocalDate(2026, 2, 27), startDay: 31),
        Cycle(2026, 1, startDay: 31),
      );
      expect(
        Cycle.containing(LocalDate(2026, 3, 31), startDay: 31),
        Cycle(2026, 3, startDay: 31),
      );
    });
  });

  group('previous and next', () {
    test('step over new year both ways', () {
      final december = Cycle(2026, 12, startDay: 1);

      expect(december.next, Cycle(2027, 1, startDay: 1));
      expect(december.next.previous, december);
      expect(december.next.start, LocalDate(2027, 1, 1));
    });

    test('next always starts the day after this one ends', () {
      for (final startDay in [1, 15, 28, 29, 30, 31]) {
        var cycle = Cycle(2027, 11, startDay: startDay);
        for (var i = 0; i < 30; i++) {
          final next = cycle.next;
          expect(
            Cycle.containing(next.start, startDay: startDay),
            next,
            reason: 'start day $startDay, after $cycle',
          );
          expect(cycle.contains(next.start), isFalse);
          expect(cycle.contains(cycle.end), isTrue);
          cycle = next;
        }
      }
    });
  });
}
