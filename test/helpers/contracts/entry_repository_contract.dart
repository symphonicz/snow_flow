import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/money.dart';

import '../fixtures/entries.dart';

/// Behaviour every [EntryRepository] must share, run against both the fake
/// and hive_ce (#18 Q9). [create] gives an empty repository per test.
void entryRepositoryContract(Future<EntryRepository> Function() create) {
  late EntryRepository repository;

  setUp(() async => repository = await create());

  Future<List<Entry>> all() async =>
      (await repository.getAll()).getOrElse((failure) => fail('$failure'));

  group('EntryRepository contract', () {
    test('starts empty', () async {
      expect(await all(), isEmpty);
    });

    test('add keeps every field', () async {
      expect(await repository.add(lunch), right(unit));
      expect(await all(), [lunch]);
    });

    test('add refuses an id that is taken and keeps the old entry', () async {
      await repository.add(lunch);
      final sameId = salary.copyWith(id: lunch.id);

      expect(await repository.add(sameId), left(const EntryAlreadyExists()));
      expect(await all(), [lunch]);
    });

    test('update replaces the entry with the same id', () async {
      await repository.add(lunch);
      await repository.add(salary);
      final edited = lunch.copyWith(amount: const Money(9900), note: '');

      expect(await repository.update(edited), right(unit));
      expect(await all(), unorderedEquals([edited, salary]));
    });

    test('update of a missing id fails and creates nothing', () async {
      expect(await repository.update(lunch), left(const EntryNotFound()));
      expect(await all(), isEmpty);
    });

    test('delete removes only that entry', () async {
      await repository.add(lunch);
      await repository.add(salary);

      expect(await repository.delete(lunch.id), right(unit));
      expect(await all(), [salary]);
    });

    test('delete of a missing id succeeds', () async {
      await repository.add(lunch);

      expect(await repository.delete('missing'), right(unit));
      expect(await all(), [lunch]);
    });

    test('clear removes every entry', () async {
      await repository.add(lunch);
      await repository.add(salary);

      expect(await repository.clear(), right(unit));
      expect(await all(), isEmpty);
    });

    test('watchAll emits the entries now and after each change', () async {
      await repository.add(lunch);
      final emitted = <List<Entry>>[];
      final subscription = repository.watchAll().listen(emitted.add);
      await pumpEventQueue();

      await repository.add(salary);
      await pumpEventQueue();
      await repository.delete(lunch.id);
      await pumpEventQueue();
      await subscription.cancel();

      expect(emitted.first, [lunch]);
      expect(emitted.any((list) => list.length == 2), isTrue);
      expect(emitted.last, [salary]);
    });
  });
}
