import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snow_flow/shared/data/hive_settings_repository.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/failure.dart';

import '../../helpers/contracts/settings_repository_contract.dart';

class _MockBox extends Mock implements Box<dynamic> {}

void main() {
  late Directory folder;
  var boxCount = 0;
  late String boxName;

  setUpAll(() {
    folder = Directory.systemTemp.createTempSync('snowflow_hive_test');
    Hive.init(folder.path);
  });

  tearDownAll(() async {
    await Hive.close();
    folder.deleteSync(recursive: true);
  });

  Future<Box<dynamic>> openBox() async {
    boxName = 'settings_${boxCount++}';
    return Hive.openBox<dynamic>(boxName);
  }

  group('HiveSettingsRepository', () {
    settingsRepositoryContract(
      () async => HiveSettingsRepository(await openBox()),
    );

    test(
      'settings are still there after the box is closed and reopened',
      () async {
        final box = await openBox();
        await HiveSettingsRepository(
          box,
        ).update((s) => s.copyWith(lang: AppLanguage.th));
        await box.close();

        final reopened = HiveSettingsRepository(
          await Hive.openBox<dynamic>(boxName),
        );

        expect(
          (await reopened.get()).toNullable(),
          const AppSettings(lang: AppLanguage.th),
        );
      },
    );

    test('a broken map fails with StorageUnreadable and stays', () async {
      final box = await openBox();
      await box.put(HiveSettingsRepository.key, {'cycleStartDay': 'one'});
      final repository = HiveSettingsRepository(box);

      expect(await repository.get(), left(const StorageUnreadable()));
      expect(
        await repository.update((s) => s.copyWith(remind: false)),
        left(const StorageUnreadable()),
      );
      expect(box.get(HiveSettingsRepository.key), {'cycleStartDay': 'one'});
    });

    test('watch sends a broken map as an error and keeps going', () async {
      final box = await openBox();
      final repository = HiveSettingsRepository(box);
      final errors = <Object>[];
      final emitted = <AppSettings>[];
      final subscription = repository.watch().listen(
        emitted.add,
        onError: errors.add,
      );
      await pumpEventQueue();

      await box.put(HiveSettingsRepository.key, 'not a map');
      await pumpEventQueue();
      await box.put(HiveSettingsRepository.key, {'remind': false});
      await pumpEventQueue();
      await subscription.cancel();

      expect(errors, [const StorageUnreadable()]);
      expect(emitted, [const AppSettings(), const AppSettings(remind: false)]);
    });

    test('a bug in the change is thrown, not reported as storage', () async {
      final repository = HiveSettingsRepository(await openBox());

      await expectLater(
        repository.update((_) => throw StateError('bug')),
        throwsStateError,
      );
    });

    test('a box that cannot be used fails with StorageUnavailable', () async {
      final box = _MockBox();
      when(() => box.get(any())).thenThrow(HiveError('IndexedDB is blocked'));
      final repository = HiveSettingsRepository(box);

      expect(await repository.get(), left(const StorageUnavailable()));
      expect(
        await repository.update((s) => s),
        left(const StorageUnavailable()),
      );
    });
  });
}
