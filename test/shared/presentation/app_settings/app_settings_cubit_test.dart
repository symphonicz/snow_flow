import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/features/settings/domain/usecases/set_language.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';
import 'package:snow_flow/shared/domain/usecases/watch_settings.dart';
import 'package:snow_flow/shared/presentation/app_settings/app_settings_cubit.dart';

import '../../../helpers/fakes/in_memory_settings_repository.dart';

/// Settings whose stream the test drives, errors included.
class _ControlledSettings implements SettingsRepository {
  final changes = StreamController<AppSettings>();

  @override
  Stream<AppSettings> watch() => changes.stream;

  @override
  Future<Either<Failure, AppSettings>> get() => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> update(
    AppSettings Function(AppSettings) change,
  ) => throw UnimplementedError();
}

const _english = AppSettings(lang: AppLanguage.en);
const _thai = AppSettings(lang: AppLanguage.th);

void main() {
  test('starts empty, so nothing shows before the settings are read', () {
    final cubit = AppSettingsCubit(WatchSettings(InMemorySettingsRepository()));
    addTearDown(cubit.close);

    expect(cubit.state, isNull);
  });

  late InMemorySettingsRepository repository;

  blocTest<AppSettingsCubit, AppSettings?>(
    'shows the stored settings, then each change at once',
    setUp: () => repository = InMemorySettingsRepository(_english),
    build: () => AppSettingsCubit(WatchSettings(repository)),
    act: (cubit) async {
      cubit.start();
      await pumpEventQueue();
      await SetLanguage(repository).call(AppLanguage.th);
    },
    expect: () => [_english, _thai],
  );

  late _ControlledSettings controlled;

  blocTest<AppSettingsCubit, AppSettings?>(
    'settings that cannot be read fall back to the defaults',
    setUp: () => controlled = _ControlledSettings(),
    build: () => AppSettingsCubit(WatchSettings(controlled)),
    act: (cubit) async {
      cubit.start();
      controlled.changes.addError(const StorageUnreadable());
      await pumpEventQueue();
    },
    expect: () => [const AppSettings()],
  );

  blocTest<AppSettingsCubit, AppSettings?>(
    'a later read error keeps the settings already shown',
    setUp: () => controlled = _ControlledSettings(),
    build: () => AppSettingsCubit(WatchSettings(controlled)),
    act: (cubit) async {
      cubit.start();
      controlled.changes
        ..add(_thai)
        ..addError(const StorageUnavailable())
        ..add(_english);
      await pumpEventQueue();
    },
    expect: () => [_thai, _english],
  );
}
