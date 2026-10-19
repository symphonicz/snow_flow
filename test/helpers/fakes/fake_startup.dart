import 'dart:async';

import 'package:snow_flow/core/startup/app_storage.dart';
import 'package:snow_flow/core/startup/tab_lock.dart';

/// A tab lock another tab may hold ([heldElsewhere]) or take away
/// ([loseToAnotherTab]).
class FakeTabLock implements TabLock {
  bool heldElsewhere = false;
  int takeOvers = 0;
  final _lost = StreamController<void>.broadcast();

  bool get hasListener => _lost.hasListener;

  void loseToAnotherTab() {
    heldElsewhere = true;
    _lost.add(null);
  }

  @override
  Future<bool> acquire({bool takeOver = false}) async {
    if (takeOver) {
      takeOvers++;
      heldElsewhere = false;
    }
    return !heldElsewhere;
  }

  @override
  Stream<void> get lost => _lost.stream;
}

/// Answers [open] and [startOver] from [results] in order, then
/// [StorageReady].
class FakeAppStorage implements AppStorage {
  final results = <StorageStatus>[];
  final startedOver = <Set<StoredData>>[];
  int openCount = 0;
  int closeCount = 0;

  /// Thrown by the next [open], like a bug in the code it runs.
  Object? openError;
  Completer<void>? _openGate;

  /// Makes the next [open] wait until the returned completer completes.
  Completer<void> holdNextOpen() => _openGate = Completer<void>();

  StorageStatus _next() =>
      results.isEmpty ? const StorageReady() : results.removeAt(0);

  @override
  Future<StorageStatus> open() async {
    openCount++;
    final error = openError;
    openError = null;
    if (error != null) throw error;
    final gate = _openGate;
    _openGate = null;
    if (gate != null) await gate.future;
    return _next();
  }

  @override
  Future<StorageStatus> startOver(Set<StoredData> broken) async {
    startedOver.add(broken);
    return _next();
  }

  @override
  Future<void> close() async => closeCount++;
}
