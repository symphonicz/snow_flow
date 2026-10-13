import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';

/// Fake [SettingsRepository] for use case and Cubit tests (#18 Q9). It never
/// fails on storage; use mocktail for that.
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this._settings = const AppSettings()]);

  AppSettings _settings;
  final _changes = StreamController<void>.broadcast(sync: true);

  @override
  Future<Either<Failure, AppSettings>> get() async => Right(_settings);

  @override
  Stream<AppSettings> watch() => Stream.multi((controller) {
    final changes = _changes.stream.listen((_) => controller.add(_settings));
    controller
      ..onCancel = changes.cancel
      ..add(_settings);
  });

  @override
  Future<Either<Failure, Unit>> update(
    AppSettings Function(AppSettings) change,
  ) async {
    _settings = change(_settings);
    _changes.add(null);
    return const Right(unit);
  }
}
