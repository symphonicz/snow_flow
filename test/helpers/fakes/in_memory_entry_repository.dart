import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/failure.dart';

/// Fake [EntryRepository] for use case and Cubit tests (#18 Q9). It never
/// fails on storage; use mocktail for that.
class InMemoryEntryRepository implements EntryRepository {
  InMemoryEntryRepository([Iterable<Entry> entries = const []])
    : _entries = {for (final entry in entries) entry.id: entry};

  final Map<String, Entry> _entries;
  final _changes = StreamController<void>.broadcast(sync: true);

  List<Entry> get _list => List.unmodifiable(_entries.values);

  Either<Failure, Unit> _changed() {
    _changes.add(null);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<Entry>>> getAll() async => Right(_list);

  @override
  Stream<List<Entry>> watchAll() => Stream.multi((controller) {
    final changes = _changes.stream.listen((_) => controller.add(_list));
    controller
      ..onCancel = changes.cancel
      ..add(_list);
  });

  @override
  Future<Either<Failure, Unit>> add(Entry entry) async {
    if (_entries.containsKey(entry.id)) return const Left(EntryAlreadyExists());
    _entries[entry.id] = entry;
    return _changed();
  }

  @override
  Future<Either<Failure, Unit>> update(Entry entry) async {
    if (!_entries.containsKey(entry.id)) return const Left(EntryNotFound());
    _entries[entry.id] = entry;
    return _changed();
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    if (_entries.remove(id) == null) return const Right(unit);
    return _changed();
  }

  @override
  Future<Either<Failure, Unit>> clear() async {
    _entries.clear();
    return _changed();
  }
}
