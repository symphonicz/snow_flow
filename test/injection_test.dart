import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:snow_flow/core/storage/box_names.dart';
import 'package:snow_flow/core/storage/storage_open_failed.dart';
import 'package:snow_flow/core/storage/storage_persistence.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/add_entry.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/delete_entry.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/get_default_currency.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/update_entry.dart';
import 'package:snow_flow/features/settings/domain/usecases/clear_all_entries.dart';
import 'package:snow_flow/features/settings/domain/usecases/set_currency.dart';
import 'package:snow_flow/features/settings/domain/usecases/set_cycle_start_day.dart';
import 'package:snow_flow/features/settings/domain/usecases/set_language.dart';
import 'package:snow_flow/features/settings/domain/usecases/set_reminder.dart';
import 'package:snow_flow/features/settings/domain/usecases/set_theme.dart';
import 'package:snow_flow/injection.dart';
import 'package:snow_flow/shared/data/hive_entry_repository.dart';
import 'package:snow_flow/shared/data/hive_settings_repository.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';
import 'package:snow_flow/shared/domain/usecases/get_entries.dart';
import 'package:snow_flow/shared/domain/usecases/get_settings.dart';
import 'package:snow_flow/shared/domain/usecases/watch_entries.dart';
import 'package:snow_flow/shared/domain/usecases/watch_settings.dart';

void main() {
  late Directory folder;
  late GetIt getIt;

  setUp(() async {
    folder = Directory.systemTemp.createTempSync('snowflow_injection_test');
    Hive.init(folder.path);
    getIt = GetIt.asNewInstance();
    await configureDependencies(getIt);
  });

  tearDown(() async {
    await Hive.close();
    folder.deleteSync(recursive: true);
  });

  test('core opens every box in BoxNames for the repositories', () {
    for (final name in BoxNames.all) {
      expect(getIt<Box<dynamic>>(instanceName: name).isOpen, isTrue);
    }
    expect(getIt<EntryRepository>(), isA<HiveEntryRepository>());
    expect(getIt<SettingsRepository>(), isA<HiveSettingsRepository>());
    expect(getIt<StoragePersistence>(), StoragePersistence.notWeb);
  });

  test(
    'a box that cannot be opened stops before shared is registered',
    () async {
      await Hive.close();
      final fresh = GetIt.asNewInstance();
      // A folder where the box file should be makes opening it fail.
      final boxFile = '${folder.path}/${BoxNames.settings}.hive';
      File(boxFile).deleteSync();
      Directory(boxFile).createSync();

      await expectLater(
        configureDependencies(fresh),
        throwsA(isA<StorageOpenFailed>()),
      );
      expect(fresh.isRegistered<EntryRepository>(), isFalse);
    },
  );

  test('every use case can be built', () {
    expect(getIt<GetEntries>(), isNotNull);
    expect(getIt<GetSettings>(), isNotNull);
    expect(getIt<WatchEntries>(), isNotNull);
    expect(getIt<WatchSettings>(), isNotNull);
    expect(getIt<AddEntry>(), isNotNull);
    expect(getIt<UpdateEntry>(), isNotNull);
    expect(getIt<DeleteEntry>(), isNotNull);
    expect(getIt<GetDefaultCurrency>(), isNotNull);
    expect(getIt<ClearAllEntries>(), isNotNull);
    expect(getIt<SetTheme>(), isNotNull);
    expect(getIt<SetLanguage>(), isNotNull);
    expect(getIt<SetCurrency>(), isNotNull);
    expect(getIt<SetReminder>(), isNotNull);
    expect(getIt<SetCycleStartDay>(), isNotNull);
  });
}
