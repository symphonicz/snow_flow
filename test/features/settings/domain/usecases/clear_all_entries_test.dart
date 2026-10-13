import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/features/settings/domain/usecases/clear_all_entries.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/currency.dart';

import '../../../../helpers/fixtures/entries.dart';
import '../../../../helpers/fakes/in_memory_entry_repository.dart';
import '../../../../helpers/fakes/in_memory_settings_repository.dart';

void main() {
  test('deletes every entry and keeps every setting (#15)', () async {
    const saved = AppSettings(
      theme: ThemePreference.dark,
      lang: AppLanguage.en,
      currency: Currency.jpy,
      remind: false,
      cycleStartDay: 25,
      sideOpen: true,
    );
    final entries = InMemoryEntryRepository([lunch, salary]);
    final settings = InMemorySettingsRepository(saved);

    expect(await ClearAllEntries(entries)(), right(unit));

    expect((await entries.getAll()).toNullable(), isEmpty);
    expect((await settings.get()).toNullable(), saved);
  });
}
