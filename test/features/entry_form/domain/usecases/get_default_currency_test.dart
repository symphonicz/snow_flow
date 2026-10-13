import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/get_default_currency.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/failure.dart';

import '../../../../helpers/fixtures/entries.dart';
import '../../../../helpers/fakes/in_memory_entry_repository.dart';
import '../../../../helpers/fakes/in_memory_settings_repository.dart';

class _MockEntryRepository extends Mock implements EntryRepository {}

void main() {
  final settings = InMemorySettingsRepository(
    const AppSettings(currency: Currency.eur),
  );

  test('uses the currency of the entry created last (#17)', () async {
    // salary is in JPY and was created before lunch (THB).
    final useCase = GetDefaultCurrency(
      InMemoryEntryRepository([lunch, salary]),
      settings,
    );

    expect(await useCase(), right(Currency.thb));
  });

  test('goes by created, not by date or order in storage', () async {
    final newest = salary.copyWith(id: 'later', created: lunch.created + 1);
    final useCase = GetDefaultCurrency(
      InMemoryEntryRepository([newest, lunch]),
      settings,
    );

    expect(await useCase(), right(Currency.jpy));
  });

  test('falls back to the settings currency when there is no entry', () async {
    final useCase = GetDefaultCurrency(InMemoryEntryRepository(), settings);

    expect(await useCase(), right(Currency.eur));
  });

  test('passes on a storage failure', () async {
    final entries = _MockEntryRepository();
    when(
      entries.getAll,
    ).thenAnswer((_) async => const Left(StorageUnreadable()));

    expect(
      await GetDefaultCurrency(entries, settings)(),
      left(const StorageUnreadable()),
    );
  });
}
