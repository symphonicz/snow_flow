import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The messages of one ARB file, without `@` metadata.
Map<String, String> _messages(String locale) {
  final file = File('lib/core/l10n/app_$locale.arb');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final MapEntry(:key, :value) in json.entries)
      if (!key.startsWith('@')) key: value as String,
  };
}

void main() {
  final thai = _messages('th');
  final english = _messages('en');

  test('every message exists in both languages', () {
    expect(english.keys.toSet(), thai.keys.toSet());
  });

  test('no message is empty', () {
    for (final messages in [thai, english]) {
      for (final MapEntry(:key, :value) in messages.entries) {
        expect(value.trim(), isNotEmpty, reason: key);
      }
    }
  });

  test('keys start with the part of the app that uses them (#52)', () {
    final prefix = RegExp('^(common|category|toast|startup)[A-Z]');
    for (final key in thai.keys) {
      expect(key, matches(prefix));
    }
  });
}
