import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/core/format/date_format.dart';
import 'package:snow_flow/shared/domain/cycle.dart';
import 'package:snow_flow/shared/domain/local_date.dart';

const _th = Locale('th');
const _en = Locale('en');

void main() {
  group('formatMonth', () {
    test('Thai shows the Buddhist year (#12)', () {
      expect(formatMonth(2026, 10, _th), 'ตุลาคม 2569');
    });

    test('English shows the Common Era year', () {
      expect(formatMonth(2026, 10, _en), 'October 2026');
    });
  });

  group('formatRange', () {
    test('shows the year once when both ends share it', () {
      final start = LocalDate(2026, 9, 25);
      final end = LocalDate(2026, 10, 24);

      expect(formatRange(start, end, _th), '25 ก.ย. – 24 ต.ค. 2569');
      expect(formatRange(start, end, _en), '25 Sep – 24 Oct 2026');
    });

    test('a range across new year shows both years (#12)', () {
      final start = LocalDate(2026, 12, 25);
      final end = LocalDate(2027, 1, 24);

      expect(formatRange(start, end, _th), '25 ธ.ค. 2569 – 24 ม.ค. 2570');
      expect(formatRange(start, end, _en), '25 Dec 2026 – 24 Jan 2027');
    });
  });

  group('formatCycle', () {
    test('a cycle starting on the 1st shows the month name', () {
      final cycle = Cycle(2026, 10, startDay: 1);

      expect(formatCycle(cycle, _th), 'ตุลาคม 2569');
      expect(formatCycle(cycle, _en), 'October 2026');
    });

    test('any other start day shows the range', () {
      final cycle = Cycle(2026, 9, startDay: 25);

      expect(formatCycle(cycle, _th), '25 ก.ย. – 24 ต.ค. 2569');
      expect(formatCycle(cycle, _en), '25 Sep – 24 Oct 2026');
    });

    test('a cycle across new year shows both years (#12)', () {
      final cycle = Cycle(2026, 12, startDay: 25);

      expect(formatCycle(cycle, _th), '25 ธ.ค. 2569 – 24 ม.ค. 2570');
      expect(formatCycle(cycle, _en), '25 Dec 2026 – 24 Jan 2027');
    });

    test('31 shows the day the short month really starts', () {
      final cycle = Cycle(2028, 2, startDay: 31);

      expect(formatCycle(cycle, _th), '29 ก.พ. – 30 มี.ค. 2571');
    });
  });

  group('formatDate', () {
    test('day before month, then the year of the language', () {
      expect(formatDate(LocalDate(2026, 10, 3), _th), '3 ต.ค. 2569');
      expect(formatDate(LocalDate(2026, 10, 3), _en), '3 Oct 2026');
    });

    test('a leap day keeps its year', () {
      expect(formatDate(LocalDate(2028, 2, 29), _th), '29 ก.พ. 2571');
    });
  });

  group('formatDayHeader', () {
    final today = LocalDate(2026, 10, 19);

    test('Thai uses the full day name without "วัน"', () {
      expect(
        formatDayHeader(LocalDate(2026, 10, 2), _th, today: today),
        'ศุกร์ 2 ต.ค.',
      );
      expect(
        formatDayHeader(LocalDate(2026, 10, 1), _th, today: today),
        'พฤหัสบดี 1 ต.ค.',
      );
    });

    test('English uses the short day name (#14)', () {
      expect(
        formatDayHeader(LocalDate(2026, 10, 2), _en, today: today),
        'Fri, 2 Oct',
      );
    });

    test('a day in another year adds the year', () {
      final lastYear = LocalDate(2025, 10, 2);

      expect(
        formatDayHeader(lastYear, _th, today: today),
        'พฤหัสบดี 2 ต.ค. 2568',
      );
      expect(formatDayHeader(lastYear, _en, today: today), 'Thu, 2 Oct 2025');
    });

    test('the year counts from today, not from the day before', () {
      final newYearsDay = LocalDate(2027, 1, 1);

      expect(
        formatDayHeader(LocalDate(2026, 12, 30), _en, today: newYearsDay),
        'Wed, 30 Dec 2026',
      );
    });
  });
}
