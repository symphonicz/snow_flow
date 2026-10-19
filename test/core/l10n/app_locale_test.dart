import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/core/l10n/app_locale.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';

void main() {
  group('deviceLocale', () {
    test('Thai device gets Thai, whatever the country', () {
      expect(deviceLocale(const [Locale('th', 'TH')]), const Locale('th'));
      expect(deviceLocale(const [Locale('th')]), const Locale('th'));
    });

    test('English device gets English, whatever the country', () {
      expect(deviceLocale(const [Locale('en', 'GB')]), const Locale('en'));
      expect(deviceLocale(const [Locale('en', 'SG')]), const Locale('en'));
    });

    test('any other language gets English', () {
      expect(deviceLocale(const [Locale('ja', 'JP')]), const Locale('en'));
    });

    test('only the first device language counts (#14)', () {
      expect(
        deviceLocale(const [Locale('ja'), Locale('th')]),
        const Locale('en'),
      );
    });

    test('no device language gets English', () {
      expect(deviceLocale(null), const Locale('en'));
      expect(deviceLocale(const []), const Locale('en'));
    });
  });

  group('pickedLocale', () {
    test('follows the device until a language is picked', () {
      expect(pickedLocale(null), isNull);
    });

    test('a picked language wins', () {
      expect(pickedLocale(AppLanguage.th), const Locale('th'));
      expect(pickedLocale(AppLanguage.en), const Locale('en'));
    });
  });
}
