import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/failure.dart';

/// Deletes one entry. Succeeds when it is already gone.
class DeleteEntry {
  const DeleteEntry(this._entries);

  final EntryRepository _entries;

  Future<Either<Failure, Unit>> call(String id) => _entries.delete(id);
}
