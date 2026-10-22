import 'dart:async';

import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';

/// An [EntryRepository] whose stream the test drives, errors included
/// (#18 Q9). Each watch gets a new stream, like the real repository, so a
/// retry can listen again; [stream] is the latest. Only watching works.
class ControlledEntryRepository implements EntryRepository {
  final _streams = <StreamController<List<Entry>>>[];

  StreamController<List<Entry>> get stream => _streams.last;

  @override
  Stream<List<Entry>> watchAll() {
    final controller = StreamController<List<Entry>>();
    _streams.add(controller);
    return controller.stream;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
