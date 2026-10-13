import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';

/// The currency a new entry starts with: that of the entry with the latest
/// `created`, or the settings currency when there is no entry. Not stored,
/// so clearing all entries resets it (#15, #17).
class GetDefaultCurrency {
  const GetDefaultCurrency(this._entries, this._settings);

  final EntryRepository _entries;
  final SettingsRepository _settings;

  Future<Either<Failure, Currency>> call() async {
    switch (await _entries.getAll()) {
      case Left(:final value):
        return Left(value);
      case Right(:final value) when value.isNotEmpty:
        final latest = value.reduce((a, b) => b.created > a.created ? b : a);
        return Right(latest.currency);
      case Right():
        return (await _settings.get()).map((settings) => settings.currency);
    }
  }
}
