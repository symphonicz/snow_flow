import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snow_flow/shared/data/hive_entry_repository.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/failure.dart';

import '../../helpers/contracts/entry_repository_contract.dart';
import '../../helpers/fixtures/entries.dart';

class _MockBox extends Mock implements Box<dynamic> {}

void main() {
  late Directory folder;
  var boxCount = 0;
  late String boxName;

  setUpAll(() {
    folder = Directory.systemTemp.createTempSync('snowflow_hive_test');
    Hive.init(folder.path);
  });

  tearDownAll(() async {
    await Hive.close();
    folder.deleteSync(recursive: true);
  });

  Future<Box<dynamic>> openBox() async {
    boxName = 'entries_${boxCount++}';
    return Hive.openBox<dynamic>(boxName);
  }

  group('HiveEntryRepository', () {
    entryRepositoryContract(() async => HiveEntryRepository(await openBox()));

    test(
      'entries are still there after the box is closed and reopened',
      () async {
        final box = await openBox();
        await HiveEntryRepository(box).add(lunch);
        await box.close();

        final reopened = HiveEntryRepository(
          await Hive.openBox<dynamic>(boxName),
        );

        expect((await reopened.getAll()).toNullable(), [lunch]);
      },
    );

    test('stores each entry as its toMap under its id (ADR 0002)', () async {
      final box = await openBox();
      await HiveEntryRepository(box).add(lunch);

      expect(box.get(lunch.id), lunch.toMap());
    });

    group('a broken map', () {
      late Box<dynamic> box;
      late HiveEntryRepository repository;

      setUp(() async {
        box = await openBox();
        repository = HiveEntryRepository(box);
        await box.put('broken', {'id': 'broken', 'amount': 'sixty'});
      });

      test('getAll fails with StorageUnreadable and deletes nothing', () async {
        expect(await repository.getAll(), left(const StorageUnreadable()));
        expect(box.containsKey('broken'), isTrue);
      });

      test('a value that is not a map is unreadable too', () async {
        await box.put('broken', 'not a map');

        expect(await repository.getAll(), left(const StorageUnreadable()));
      });

      test('watchAll sends the error and keeps going', () async {
        final errors = <Object>[];
        final lists = <List<Entry>>[];
        final subscription = repository.watchAll().listen(
          lists.add,
          onError: errors.add,
        );
        await pumpEventQueue();

        await box.delete('broken');
        await pumpEventQueue();
        await subscription.cancel();

        expect(errors, [const StorageUnreadable()]);
        expect(lists, [<Entry>[]]);
      });
    });

    group('a box that cannot be used', () {
      late _MockBox box;
      late HiveEntryRepository repository;

      setUp(() {
        box = _MockBox();
        repository = HiveEntryRepository(box);
        when(() => box.values).thenThrow(HiveError('IndexedDB is blocked'));
        when(() => box.containsKey(any())).thenReturn(false);
        when(() => box.put(any(), any())).thenThrow(HiveError('quota'));
        when(() => box.delete(any())).thenThrow(HiveError('quota'));
        when(() => box.clear()).thenThrow(HiveError('quota'));
      });

      test('every call fails with StorageUnavailable', () async {
        const unavailable = Left<Failure, Never>(StorageUnavailable());
        expect(await repository.getAll(), unavailable);
        expect(await repository.add(lunch), unavailable);
        expect(await repository.delete(lunch.id), unavailable);
        expect(await repository.clear(), unavailable);
      });

      test('update fails with StorageUnavailable when writing fails', () async {
        when(() => box.containsKey(any())).thenReturn(true);

        expect(
          await repository.update(lunch),
          left(const StorageUnavailable()),
        );
      });
    });
  });
}
