import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'helpers/architecture_rules.dart';

void main() {
  group('architecture rules (synthetic sources)', () {
    List<String> check(Map<String, String> sources) =>
        findArchitectureViolations(sources);

    test('feature may import core, shared and itself', () {
      expect(
        check({
          'lib/features/entries/presentation/entries_page.dart': '''
import 'package:flutter/material.dart';
import 'package:snow_flow/core/theme.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/features/entries/domain/watch_entries.dart';
''',
        }),
        isEmpty,
      );
    });

    test('feature must not import another feature', () {
      final violations = check({
        'lib/features/entries/presentation/entries_page.dart':
            "import 'package:snow_flow/features/settings/domain/get_settings.dart';",
      });
      expect(violations, hasLength(1));
      expect(violations.single, contains('features/settings'));
    });

    test('export counts like import', () {
      expect(
        check({
          'lib/features/entries/entries.dart':
              "export 'package:snow_flow/features/summary/summary.dart';",
        }),
        hasLength(1),
      );
    });

    test('core and shared must not import features', () {
      expect(
        check({
          'lib/core/theme.dart':
              "import 'package:snow_flow/features/settings/settings.dart';",
          'lib/shared/data/repo.dart':
              "import 'package:snow_flow/features/entries/entries.dart';",
        }),
        hasLength(2),
      );
    });

    test('composition roots may import every feature', () {
      expect(
        check({
          'lib/injection.dart': '''
import 'package:snow_flow/features/entries/entries_injection.dart';
import 'package:snow_flow/features/settings/settings_injection.dart';
''',
          'lib/router.dart':
              "import 'package:snow_flow/features/summary/summary.dart';",
        }),
        isEmpty,
      );
    });

    test('domain allows only the allowlist and other domain files', () {
      expect(
        check({
          'lib/features/entries/domain/add_entry.dart': '''
import 'dart:async';
import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/features/entries/domain/failure.dart';
''',
        }),
        isEmpty,
      );
    });

    test('domain must not import Flutter, hive_ce, data, presentation or core',
        () {
      final violations = check({
        'lib/shared/domain/entry.dart': '''
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:snow_flow/shared/data/entry_model.dart';
import 'package:snow_flow/features/entries/presentation/x.dart';
import 'package:snow_flow/core/money_format.dart';
import 'dart:io';
''',
      });
      expect(violations, hasLength(6));
    });

    test('relative imports are rejected so the rules cannot be bypassed', () {
      expect(
        check({
          'lib/features/entries/entries.dart':
              "import '../settings/settings.dart';",
        }),
        hasLength(1),
      );
    });

    test('line widgets are banned outside chart files', () {
      final violations = check({
        'lib/features/entries/presentation/entry_row.dart': '''
const a = Divider();
const b = VerticalDivider();
final c = Border.all();
const d = BorderSide();
''',
      });
      expect(violations, hasLength(4));
    });

    test('similar names and comments are not line widgets', () {
      expect(
        check({
          'lib/core/theme.dart': '''
// A Divider would draw a line, so we do not use one.
/* Border is banned too. */
const a = InputBorder.none;
final b = BorderRadius.circular(8);
const c = DividerThemeData(color: Colors.transparent);
''',
        }),
        isEmpty,
      );
    });

    test('chart files may draw lines', () {
      expect(
        findArchitectureViolations(
          {'lib/features/summary/presentation/bar_chart.dart': 'Divider();'},
          chartFiles: {'lib/features/summary/presentation/bar_chart.dart'},
        ),
        isEmpty,
      );
    });
  });

  test('lib/ follows the architecture rules', () {
    final sources = <String, String>{
      for (final file in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')))
        file.path.replaceAll(r'\', '/'): file.readAsStringSync(),
    };
    expect(sources, isNotEmpty);
    expect(findArchitectureViolations(sources), isEmpty);
  });
}
