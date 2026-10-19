import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/router.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';

import '../../../helpers/overflow.dart';
import '../../../helpers/pump_app.dart';

/// The real app in the language of [c], at [location].
Future<void> pumpAt(WidgetTester tester, OverflowCase c, String location) =>
    pumpSnowFlowApp(
      tester,
      lang: AppLanguage.values.byName(c.locale.languageCode),
      location: location,
    );

/// The screens of the mobile shell, each by how a test reaches it.
final _screens = <String, Future<void> Function(WidgetTester, OverflowCase)>{
  'the entries tab': (tester, c) => pumpAt(tester, c, entriesPath),
  'the summary tab': (tester, c) => pumpAt(tester, c, summaryPath),
  'settings': (tester, c) => pumpAt(tester, c, settingsPath),
  'the entry form sheet': (tester, c) async {
    await pumpAt(tester, c, entriesPath);
    // The label under the pencil button.
    await tester.tap(
      find.text(lookupAppLocalizations(c.locale).commonAddEntry),
    );
    await tester.pumpAndSettle();
  },
};

void main() {
  for (final MapEntry(key: name, value: pump) in _screens.entries) {
    testNoOverflow(name, pump);
    testNoOverflow('$name in dark', pump, cases: darkCases);
  }
}
