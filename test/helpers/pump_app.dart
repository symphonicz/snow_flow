import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:snow_flow/features/entries/entries_injection.dart';
import 'package:snow_flow/main.dart';
import 'package:snow_flow/router.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/usecases/watch_entries.dart';
import 'package:snow_flow/shared/domain/usecases/watch_settings.dart';

import 'fakes/in_memory_entry_repository.dart';
import 'fakes/in_memory_settings_repository.dart';

/// The pages get their Cubits from get_it, so this resets it with in-memory
/// [entries] and [settings] in place of hive_ce (#18 Q5) until the test
/// ends.
Future<void> useFakeDependencies({
  List<Entry> entries = const [],
  required InMemorySettingsRepository settings,
}) async {
  final getIt = GetIt.instance;
  await getIt.reset();
  addTearDown(getIt.reset);
  getIt
    ..registerSingleton(WatchEntries(InMemoryEntryRepository(entries)))
    ..registerSingleton(WatchSettings(settings));
  registerEntries(getIt);
}

/// The real app with its real router, in [lang], at [location] (the
/// entries page when null), over in-memory [entries].
Future<GoRouter> pumpSnowFlowApp(
  WidgetTester tester, {
  AppLanguage lang = AppLanguage.en,
  String? location,
  List<Entry> entries = const [],
}) async {
  final settings = InMemorySettingsRepository(AppSettings(lang: lang));
  await useFakeDependencies(entries: entries, settings: settings);

  final router = createRouter();
  addTearDown(router.dispose);
  await tester.pumpWidget(
    SnowFlowApp(router: router, watchSettings: WatchSettings(settings)),
  );
  if (location != null) router.go(location);
  await tester.pumpAndSettle();
  return router;
}
