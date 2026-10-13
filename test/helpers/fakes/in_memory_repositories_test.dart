import 'package:flutter_test/flutter_test.dart';

import 'package:snow_flow/shared/domain/app_settings.dart';

import '../contracts/entry_repository_contract.dart';
import '../contracts/settings_repository_contract.dart';
import 'in_memory_entry_repository.dart';
import 'in_memory_settings_repository.dart';

void main() {
  group('InMemoryEntryRepository', () {
    entryRepositoryContract(() async => InMemoryEntryRepository());
  });

  group('InMemorySettingsRepository', () {
    settingsRepositoryContract(() async => InMemorySettingsRepository());

    test('can start from given settings', () async {
      const settings = AppSettings(cycleStartDay: 10);
      final repository = InMemorySettingsRepository(settings);

      expect((await repository.get()).toNullable(), settings);
    });
  });
}
