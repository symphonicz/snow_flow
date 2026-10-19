import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/features/entries/presentation/entries_page.dart';
import 'package:snow_flow/main.dart';
import 'package:snow_flow/router.dart';
import 'package:snow_flow/shared/presentation/toast/toast.dart';

void main() {
  testWidgets('app opens the entries page through the router', (tester) async {
    final router = createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(SnowFlowApp(router: router));

    expect(find.byType(EntriesPage), findsOneWidget);
    expect(router.state.matchedLocation, entriesPath);
  });

  testWidgets('app uses the token themes and can show toasts', (tester) async {
    final router = createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(SnowFlowApp(router: router));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme, AppTheme.light);
    expect(app.darkTheme, AppTheme.dark);
    // The theme setting is wired in by #65.
    expect(app.themeMode, ThemeMode.system);
    expect(find.byType(ToastHost), findsOneWidget);
  });
}
