import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/features/entries/presentation/entries_page.dart';
import 'package:snow_flow/features/settings/domain/usecases/set_language.dart';
import 'package:snow_flow/main.dart';
import 'package:snow_flow/router.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/usecases/watch_settings.dart';
import 'package:snow_flow/shared/presentation/toast/toast.dart';

import 'helpers/fakes/in_memory_settings_repository.dart';

/// One page that shows a translated word, to see the language on screen.
GoRouter _wordRouter() => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          Text(AppLocalizations.of(context).commonSummary),
    ),
  ],
);

void main() {
  late InMemorySettingsRepository settings;

  setUp(() => settings = InMemorySettingsRepository());

  Future<void> pumpApp(WidgetTester tester, GoRouter router) async {
    addTearDown(router.dispose);
    await tester.pumpWidget(
      SnowFlowApp(router: router, watchSettings: WatchSettings(settings)),
    );
    await tester.pumpAndSettle();
  }

  void setDeviceLocales(WidgetTester tester, List<Locale> locales) {
    tester.platformDispatcher.localesTestValue = locales;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }

  testWidgets('app opens the entries page through the router', (tester) async {
    final router = createRouter();
    await pumpApp(tester, router);

    expect(find.byType(EntriesPage), findsOneWidget);
    expect(router.state.matchedLocation, entriesPath);
  });

  testWidgets('app uses the token themes and can show toasts', (tester) async {
    await pumpApp(tester, createRouter());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme, AppTheme.light);
    expect(app.darkTheme, AppTheme.dark);
    // The theme setting is wired in by #65.
    expect(app.themeMode, ThemeMode.system);
    expect(find.byType(ToastHost), findsOneWidget);
  });

  group('language', () {
    testWidgets('follows a Thai device until one is picked', (tester) async {
      setDeviceLocales(tester, const [Locale('th', 'TH')]);
      await pumpApp(tester, _wordRouter());

      expect(find.text('สรุป'), findsOneWidget);
    });

    testWidgets('a device in another language gets English', (tester) async {
      setDeviceLocales(tester, const [Locale('ja', 'JP'), Locale('th')]);
      await pumpApp(tester, _wordRouter());

      expect(find.text('Summary'), findsOneWidget);
    });

    testWidgets('a picked language beats the device language', (tester) async {
      setDeviceLocales(tester, const [Locale('th')]);
      settings = InMemorySettingsRepository(
        const AppSettings(lang: AppLanguage.en),
      );
      await pumpApp(tester, _wordRouter());

      expect(find.text('Summary'), findsOneWidget);
    });

    testWidgets('picking a language changes the text at once (#52)', (
      tester,
    ) async {
      setDeviceLocales(tester, const [Locale('en')]);
      await pumpApp(tester, _wordRouter());
      expect(find.text('Summary'), findsOneWidget);

      await tester.runAsync(() => SetLanguage(settings).call(AppLanguage.th));
      await tester.pumpAndSettle();

      expect(find.text('สรุป'), findsOneWidget);
    });

    testWidgets('following the device changes with the device', (tester) async {
      setDeviceLocales(tester, const [Locale('en')]);
      await pumpApp(tester, _wordRouter());

      setDeviceLocales(tester, const [Locale('th')]);
      await tester.pumpAndSettle();

      expect(find.text('สรุป'), findsOneWidget);
    });
  });
}
