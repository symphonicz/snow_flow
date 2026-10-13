import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/failure.dart';

/// "Delete all data": deletes every entry and keeps the settings (#15).
class ClearAllEntries {
  const ClearAllEntries(this._entries);

  final EntryRepository _entries;

  Future<Either<Failure, Unit>> call() => _entries.clear();
}
