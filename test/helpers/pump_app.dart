import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:snow_flow/main.dart';
import 'package:snow_flow/router.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/usecases/watch_settings.dart';

import 'fakes/in_memory_settings_repository.dart';

/// The real app with its real router, in [lang], at [location] (the
/// entries page when null).
Future<GoRouter> pumpSnowFlowApp(
  WidgetTester tester, {
  AppLanguage lang = AppLanguage.en,
  String? location,
}) async {
  final router = createRouter();
  addTearDown(router.dispose);
  final settings = InMemorySettingsRepository(AppSettings(lang: lang));
  await tester.pumpWidget(
    SnowFlowApp(router: router, watchSettings: WatchSettings(settings)),
  );
  if (location != null) router.go(location);
  await tester.pumpAndSettle();
  return router;
}
