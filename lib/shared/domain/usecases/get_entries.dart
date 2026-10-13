import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/failure.dart';

/// Every entry once, unsorted, e.g. for the backup file.
class GetEntries {
  const GetEntries(this._entries);

  final EntryRepository _entries;

  Future<Either<Failure, List<Entry>>> call() => _entries.getAll();
}
