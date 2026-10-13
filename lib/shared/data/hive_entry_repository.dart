import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive.dart';
import 'package:snow_flow/shared/data/hive_storage.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/failure.dart';

/// Keeps each entry as its [Entry.toMap] under its id (ADR 0002).
class HiveEntryRepository implements EntryRepository {
  HiveEntryRepository(this._box);

  final Box<dynamic> _box;

  List<Entry> _readAll() => [
    for (final value in _box.values) Entry.fromMap(requireMap(value)),
  ];

  @override
  Future<Either<Failure, List<Entry>>> getAll() =>
      guardStorage(() => Right(_readAll()));

  @override
  Stream<List<Entry>> watchAll() => watchBox(_box, _readAll);

  @override
  Future<Either<Failure, Unit>> add(Entry entry) => guardStorage(() async {
    if (_box.containsKey(entry.id)) return const Left(EntryAlreadyExists());
    await _box.put(entry.id, entry.toMap());
    return const Right(unit);
  });

  @override
  Future<Either<Failure, Unit>> update(Entry entry) => guardStorage(() async {
    if (!_box.containsKey(entry.id)) return const Left(EntryNotFound());
    await _box.put(entry.id, entry.toMap());
    return const Right(unit);
  });

  @override
  Future<Either<Failure, Unit>> delete(String id) => guardStorage(() async {
    await _box.delete(id);
    return const Right(unit);
  });

  @override
  Future<Either<Failure, Unit>> clear() => guardStorage(() async {
    await _box.clear();
    return const Right(unit);
  });
}
