import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/shared/domain/local_date.dart';

void main() {
  group('LocalDate.tryParse', () {
    test('reads YYYY-MM-DD', () {
      expect(LocalDate.tryParse('2026-10-03'), LocalDate(2026, 10, 3));
      expect(LocalDate.tryParse('2028-02-29'), LocalDate(2028, 2, 29));
    });

    test('rejects days that do not exist', () {
      for (final text in [
        '2026-02-29',
        '2026-02-30',
        '2026-04-31',
        '2026-13-01',
        '2026-00-10',
        '2026-10-00',
        '2100-02-29',
      ]) {
        expect(LocalDate.tryParse(text), isNull, reason: text);
      }
    });

    test('rejects other formats', () {
      for (final text in [
        '',
        '2026-1-3',
        '03/10/2026',
        '2026-10-03T09:00',
        ' 2026-10-03',
        '20261003',
        '+2026-10-03',
      ]) {
        expect(LocalDate.tryParse(text), isNull, reason: text);
      }
    });
  });

  test('constructor rejects days that do not exist', () {
    expect(() => LocalDate(2026, 2, 29), throwsArgumentError);
    expect(() => LocalDate(2026, 0, 1), throwsArgumentError);
  });

  test('writes YYYY-MM-DD with zero padding', () {
    expect(LocalDate(2026, 1, 5).toString(), '2026-01-05');
    expect(LocalDate(987, 12, 31).toString(), '0987-12-31');
  });

  test('sorts by calendar order', () {
    final dates = [
      LocalDate(2026, 10, 3),
      LocalDate(2025, 12, 31),
      LocalDate(2026, 9, 30),
      LocalDate(2026, 10, 1),
    ]..sort();
    expect(dates.map((d) => '$d'), [
      '2025-12-31',
      '2026-09-30',
      '2026-10-01',
      '2026-10-03',
    ]);
    expect(LocalDate(2026, 10, 3) > LocalDate(2026, 10, 2), isTrue);
    expect(LocalDate(2026, 10, 3) < LocalDate(2026, 10, 3), isFalse);
  });

  test('fromDateTime keeps the local calendar day', () {
    expect(
      LocalDate.fromDateTime(DateTime(2026, 10, 3, 23, 59)),
      LocalDate(2026, 10, 3),
    );
  });

  test('nextDay crosses months, years and 29 February', () {
    expect(LocalDate(2026, 10, 3).nextDay, LocalDate(2026, 10, 4));
    expect(LocalDate(2026, 9, 30).nextDay, LocalDate(2026, 10, 1));
    expect(LocalDate(2026, 12, 31).nextDay, LocalDate(2027, 1, 1));
    expect(LocalDate(2028, 2, 28).nextDay, LocalDate(2028, 2, 29));
    expect(LocalDate(2026, 2, 28).nextDay, LocalDate(2026, 3, 1));
  });
}
