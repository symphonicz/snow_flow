import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/failure.dart';

/// Saves a new entry. [EntryAlreadyExists] when its id is taken.
class AddEntry {
  const AddEntry(this._entries);

  final EntryRepository _entries;

  Future<Either<Failure, Unit>> call(Entry entry) => _entries.add(entry);
}
