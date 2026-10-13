import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:snow_flow/core/storage/box_names.dart';
import 'package:snow_flow/shared/data/hive_entry_repository.dart';
import 'package:snow_flow/shared/data/hive_settings_repository.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';
import 'package:snow_flow/shared/domain/usecases/get_entries.dart';
import 'package:snow_flow/shared/domain/usecases/watch_entries.dart';
import 'package:snow_flow/shared/domain/usecases/watch_settings.dart';

/// Registers business code used by two or more features (repositories,
/// month-cycle logic). The repositories need the open boxes that
/// `registerCore` registers under their [BoxNames] (#56), so they are lazy.
void registerShared(GetIt getIt) {
  getIt
    ..registerLazySingleton<EntryRepository>(
      () => HiveEntryRepository(
        getIt<Box<dynamic>>(instanceName: BoxNames.entries),
      ),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => HiveSettingsRepository(
        getIt<Box<dynamic>>(instanceName: BoxNames.settings),
      ),
    )
    ..registerLazySingleton(() => GetEntries(getIt()))
    ..registerLazySingleton(() => WatchEntries(getIt()))
    ..registerLazySingleton(() => WatchSettings(getIt()));
}
