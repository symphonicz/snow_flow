import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:snow_flow/core/startup/app_storage.dart';
import 'package:snow_flow/core/startup/hive_app_storage.dart';
import 'package:snow_flow/core/storage/box_names.dart';
import 'package:snow_flow/core/storage/storage_persistence.dart';
import 'package:snow_flow/injection.dart';
import 'package:snow_flow/shared/data/hive_settings_repository.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';

import '../../helpers/fixtures/entries.dart';

void main() {
  late Directory folder;
  late GetIt getIt;
  late HiveAppStorage storage;

  setUp(() {
    folder = Directory.systemTemp.createTempSync('snowflow_startup_test');
    Hive.init(folder.path);
    getIt = GetIt.asNewInstance();
    storage = HiveAppStorage(
      getIt: getIt,
      configure: configureDependencies,
      initHive: () async => Hive.init(folder.path),
    );
  });

  tearDown(() async {
    await storage.close();
    folder.deleteSync(recursive: true);
  });

  /// Writes straight into the box, as data from an older or broken app.
  Future<void> store(String box, Object key, Object value) async {
    final opened = await Hive.openBox<dynamic>(box);
    await opened.put(key, value);
    await opened.close();
  }

  Future<Object?> stored(String box, Object key) async =>
      (await Hive.openBox<dynamic>(box)).get(key);

  test('fresh storage is ready with everything registered', () async {
    expect(await storage.open(), const StorageReady());

    expect(getIt<EntryRepository>(), isNotNull);
    expect(getIt<StoragePersistence>(), StoragePersistence.notWeb);
  });

  test('an unreadable entry reports entries as broken and stays', () async {
    await store(BoxNames.entries, 'bad', {'amount': 'lots'});

    expect(await storage.open(), const StorageBroken({StoredData.entries}));
    await storage.close();
    expect(await stored(BoxNames.entries, 'bad'), {'amount': 'lots'});
  });

  test('unreadable settings report settings as broken', () async {
    await store(BoxNames.settings, HiveSettingsRepository.key, 'not a map');

    expect(await storage.open(), const StorageBroken({StoredData.settings}));
  });

  test('both broken are both reported', () async {
    await store(BoxNames.entries, 'bad', 42);
    await store(BoxNames.settings, HiveSettingsRepository.key, 42);

    expect(
      await storage.open(),
      const StorageBroken({StoredData.entries, StoredData.settings}),
    );
  });

  test('starting over deletes the broken entries but keeps settings', () async {
    await store(BoxNames.entries, 'bad', 42);
    await store(
      BoxNames.settings,
      HiveSettingsRepository.key,
      const AppSettings(lang: AppLanguage.th).toMap(),
    );
    await storage.open();

    expect(await storage.startOver({StoredData.entries}), const StorageReady());
    expect((await getIt<EntryRepository>().getAll()).toNullable(), isEmpty);
    expect(
      (await getIt<SettingsRepository>().get()).toNullable(),
      const AppSettings(lang: AppLanguage.th),
    );
  });

  test('starting over resets broken settings but keeps entries', () async {
    await store(BoxNames.entries, lunch.id, lunch.toMap());
    await store(BoxNames.settings, HiveSettingsRepository.key, 42);
    await storage.open();

    expect(
      await storage.startOver({StoredData.settings}),
      const StorageReady(),
    );
    expect((await getIt<EntryRepository>().getAll()).toNullable(), [lunch]);
    expect(
      (await getIt<SettingsRepository>().get()).toNullable(),
      const AppSettings(),
    );
  });

  test('a box that cannot be opened reports the storage unusable', () async {
    // A folder where the box file should be makes opening it fail.
    Directory('${folder.path}/${BoxNames.entries}.hive').createSync();

    expect(await storage.open(), const StorageCannotOpen());
  });

  test('hive that cannot start reports the storage unusable', () async {
    final failing = HiveAppStorage(
      getIt: getIt,
      configure: configureDependencies,
      initHive: () => throw const FileSystemException('no app folder'),
    );

    expect(await failing.open(), const StorageCannotOpen());
  });

  test('opening again after a failure or close works', () async {
    await store(BoxNames.entries, lunch.id, lunch.toMap());

    expect(await storage.open(), const StorageReady());
    expect(await storage.open(), const StorageReady());
    await storage.close();
    expect(getIt.isRegistered<EntryRepository>(), isFalse);

    expect(await storage.open(), const StorageReady());
    expect((await getIt<EntryRepository>().getAll()).toNullable(), [lunch]);
  });
}
