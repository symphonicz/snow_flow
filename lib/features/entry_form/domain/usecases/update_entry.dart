import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/failure.dart';

/// Saves changes to an entry. [EntryNotFound] when it was deleted.
class UpdateEntry {
  const UpdateEntry(this._entries);

  final EntryRepository _entries;

  Future<Either<Failure, Unit>> call(Entry entry) => _entries.update(entry);
}
