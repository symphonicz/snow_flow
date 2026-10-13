import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/currency.dart';

void main() {
  test('defaults follow brief §3', () {
    expect(const AppSettings().toMap(), {
      'theme': 'system',
      'lang': null,
      'currency': 'THB',
      'remind': true,
      'remindTime': '20:00',
      'cycleStartDay': 1,
      'sideOpen': false,
    });
  });

  final custom = const AppSettings(
    theme: ThemePreference.dark,
    lang: AppLanguage.en,
    currency: Currency.jpy,
    remind: false,
    remindTime: ReminderTime(7, 5),
    cycleStartDay: 25,
    sideOpen: true,
  );

  const customMap = {
    'theme': 'dark',
    'lang': 'en',
    'currency': 'JPY',
    'remind': false,
    'remindTime': '07:05',
    'cycleStartDay': 25,
    'sideOpen': true,
  };

  group('toMap / fromMap', () {
    test('toMap writes every setting', () {
      expect(custom.toMap(), customMap);
    });

    test('fromMap reads what toMap wrote', () {
      expect(AppSettings.fromMap(customMap), custom);
      expect(
        AppSettings.fromMap(const AppSettings().toMap()),
        const AppSettings(),
      );
      expect(AppSettings.fromMap(Map<dynamic, dynamic>.of(customMap)), custom);
    });

    test('fromMap uses the default for a missing field', () {
      expect(AppSettings.fromMap({}), const AppSettings());
      expect(
        AppSettings.fromMap({'cycleStartDay': 31}),
        const AppSettings(cycleStartDay: 31),
      );
    });

    test('fromMap throws FormatException for a broken value', () {
      final broken = <String, Map<String, Object?>>{
        'unknown theme': {'theme': 'blue'},
        'unknown lang': {'lang': 'ja'},
        'unknown currency': {'currency': 'XXX'},
        'lowercase currency': {'currency': 'jpy'},
        'remind as text': {'remind': 'true'},
        'time without colon': {'remindTime': '2000'},
        'hour 24': {'remindTime': '24:00'},
        'minute 60': {'remindTime': '20:60'},
        'cycle day 0': {'cycleStartDay': 0},
        'cycle day 32': {'cycleStartDay': 32},
        'cycle day as text': {'cycleStartDay': '1'},
        'sideOpen as number': {'sideOpen': 1},
      };
      for (final MapEntry(key: reason, value: map) in broken.entries) {
        expect(
          () => AppSettings.fromMap(map),
          throwsFormatException,
          reason: reason,
        );
      }
    });
  });

  test('copyWith changes only the given fields', () {
    expect(
      const AppSettings().copyWith(lang: AppLanguage.th, cycleStartDay: 15),
      const AppSettings(lang: AppLanguage.th, cycleStartDay: 15),
    );
  });

  group('ReminderTime', () {
    test('reads and writes HH:mm', () {
      expect(ReminderTime.tryParse('07:05'), const ReminderTime(7, 5));
      expect(ReminderTime.tryParse('23:59'), const ReminderTime(23, 59));
      expect(const ReminderTime(0, 0).toString(), '00:00');
    });

    test('rejects other formats', () {
      for (final text in ['7:05', '24:00', '12:60', '12-00', '', '12:5']) {
        expect(ReminderTime.tryParse(text), isNull, reason: text);
      }
    });
  });
}
