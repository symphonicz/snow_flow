import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/failure.dart';

/// Stores entries by [Entry.id]. Lists come back unsorted; sorting and
/// grouping belong to the summary logic (#58).
abstract interface class EntryRepository {
  Future<Either<Failure, List<Entry>>> getAll();

  /// Emits every entry now, then again after each change. A broken box is
  /// sent as a [StorageUnreadable] error and the stream keeps going (#18 Q4).
  Stream<List<Entry>> watchAll();

  /// [EntryAlreadyExists] when the id is taken.
  Future<Either<Failure, Unit>> add(Entry entry);

  /// [EntryNotFound] when no entry has this id.
  Future<Either<Failure, Unit>> update(Entry entry);

  /// Succeeds when the id is already gone, so deleting twice is fine.
  Future<Either<Failure, Unit>> delete(String id);

  /// Deletes every entry. Settings stay (#15).
  Future<Either<Failure, Unit>> clear();
}
