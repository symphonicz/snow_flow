import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';

/// Every entry, unsorted, now and after each change. Failures come as stream
/// errors (#18 Q4).
class WatchEntries {
  const WatchEntries(this._entries);

  final EntryRepository _entries;

  Stream<List<Entry>> call() => _entries.watchAll();
}
