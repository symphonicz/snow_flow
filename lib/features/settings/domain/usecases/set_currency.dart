import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';

/// The default currency: balance card, and new entries when none exist.
class SetCurrency {
  const SetCurrency(this._settings);

  final SettingsRepository _settings;

  Future<Either<Failure, Unit>> call(Currency currency) =>
      _settings.update((settings) => settings.copyWith(currency: currency));
}
