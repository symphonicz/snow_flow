import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';

/// Behaviour every [SettingsRepository] must share, run against both the fake
/// and hive_ce (#18 Q9). [create] gives a repository with nothing saved.
void settingsRepositoryContract(Future<SettingsRepository> Function() create) {
  late SettingsRepository repository;

  setUp(() async => repository = await create());

  Future<AppSettings> current() async =>
      (await repository.get()).getOrElse((failure) => fail('$failure'));

  group('SettingsRepository contract', () {
    test('reads the defaults before anything is saved', () async {
      expect(await current(), const AppSettings());
    });

    test('update saves the changed settings', () async {
      final result = await repository.update(
        (settings) =>
            settings.copyWith(lang: AppLanguage.en, cycleStartDay: 25),
      );

      expect(result, right(unit));
      expect(
        await current(),
        const AppSettings(lang: AppLanguage.en, cycleStartDay: 25),
      );
    });

    test('two updates without waiting both stick', () async {
      await Future.wait([
        repository.update((s) => s.copyWith(currency: Currency.jpy)),
        repository.update((s) => s.copyWith(remind: false)),
      ]);

      expect(
        await current(),
        const AppSettings(currency: Currency.jpy, remind: false),
      );
    });

    test('watch emits the settings now and after each change', () async {
      final emitted = <AppSettings>[];
      final subscription = repository.watch().listen(emitted.add);
      await pumpEventQueue();

      await repository.update((s) => s.copyWith(theme: ThemePreference.dark));
      await pumpEventQueue();
      await subscription.cancel();

      expect(emitted, [
        const AppSettings(),
        const AppSettings(theme: ThemePreference.dark),
      ]);
    });
  });
}
