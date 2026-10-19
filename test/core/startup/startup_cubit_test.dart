import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/core/startup/app_storage.dart';
import 'package:snow_flow/core/startup/startup_cubit.dart';
import 'package:snow_flow/core/startup/startup_state.dart';

import '../../helpers/fakes/fake_startup.dart';

void main() {
  late FakeTabLock tabLock;
  late FakeAppStorage storage;

  setUp(() {
    tabLock = FakeTabLock();
    storage = FakeAppStorage();
  });

  StartupCubit build() => StartupCubit(tabLock: tabLock, storage: storage);

  group('start', () {
    blocTest<StartupCubit, StartupState>(
      'opens the storage and is ready',
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => [const StartupReady()],
      verify: (_) => expect(storage.openCount, 1),
    );

    blocTest<StartupCubit, StartupState>(
      'a second tab is stopped before it touches the storage',
      setUp: () => tabLock.heldElsewhere = true,
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => [const StartupOtherTab()],
      verify: (_) => expect(storage.openCount, 0),
    );

    blocTest<StartupCubit, StartupState>(
      'storage that cannot be opened shows the unavailable screen',
      setUp: () => storage.results.add(const StorageCannotOpen()),
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => [const StartupUnavailable()],
    );

    blocTest<StartupCubit, StartupState>(
      'broken data shows the unreadable screen and deletes nothing',
      setUp: () =>
          storage.results.add(const StorageBroken({StoredData.entries})),
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => [
        const StartupUnreadable({StoredData.entries}),
      ],
      verify: (_) => expect(storage.startedOver, isEmpty),
    );
  });

  group('takeOver', () {
    blocTest<StartupCubit, StartupState>(
      'takes the lock from the other tab and opens the storage',
      setUp: () => tabLock.heldElsewhere = true,
      build: build,
      act: (cubit) async {
        await cubit.start();
        await cubit.takeOver();
      },
      expect: () => [
        const StartupOtherTab(),
        const StartupLoading(),
        const StartupReady(),
      ],
      verify: (_) => expect(tabLock.takeOvers, 1),
    );
  });

  group('when another tab takes over', () {
    blocTest<StartupCubit, StartupState>(
      'shows the other-tab screen and stops using the storage',
      build: build,
      act: (cubit) async {
        await cubit.start();
        tabLock.loseToAnotherTab();
        await pumpEventQueue();
      },
      expect: () => [const StartupReady(), const StartupOtherTab()],
      verify: (_) => expect(storage.closeCount, 1),
    );

    blocTest<StartupCubit, StartupState>(
      'while still opening: never becomes ready and closes the storage',
      build: build,
      act: (cubit) async {
        final gate = storage.holdNextOpen();
        final starting = cubit.start();
        await pumpEventQueue();
        tabLock.loseToAnotherTab();
        await pumpEventQueue();
        gate.complete();
        await starting;
      },
      expect: () => [const StartupOtherTab()],
      verify: (_) => expect(storage.closeCount, greaterThanOrEqualTo(1)),
    );
  });

  blocTest<StartupCubit, StartupState>(
    'a bug while opening is reported and still leaves a button to press',
    setUp: () => storage.openError = StateError('bug'),
    build: build,
    act: (cubit) => cubit.start(),
    expect: () => [const StartupUnavailable()],
    errors: () => [isStateError],
  );

  blocTest<StartupCubit, StartupState>(
    'a second tap while opening is ignored',
    setUp: () => storage.results.add(const StorageCannotOpen()),
    build: build,
    act: (cubit) async {
      await cubit.start();
      final gate = storage.holdNextOpen();
      final first = cubit.retry();
      final second = cubit.retry();
      gate.complete();
      await Future.wait([first, second]);
    },
    expect: () => [
      const StartupUnavailable(),
      const StartupLoading(),
      const StartupReady(),
    ],
    verify: (_) => expect(storage.openCount, 2),
  );

  group('retry', () {
    blocTest<StartupCubit, StartupState>(
      'opens again',
      setUp: () => storage.results.add(const StorageCannotOpen()),
      build: build,
      act: (cubit) async {
        await cubit.start();
        await cubit.retry();
      },
      expect: () => [
        const StartupUnavailable(),
        const StartupLoading(),
        const StartupReady(),
      ],
      verify: (_) => expect(storage.openCount, 2),
    );
  });

  group('startOver', () {
    blocTest<StartupCubit, StartupState>(
      'deletes only the broken data, then opens',
      setUp: () =>
          storage.results.add(const StorageBroken({StoredData.settings})),
      build: build,
      act: (cubit) async {
        await cubit.start();
        await cubit.startOver();
      },
      expect: () => [
        const StartupUnreadable({StoredData.settings}),
        const StartupLoading(),
        const StartupReady(),
      ],
      verify: (_) => expect(storage.startedOver, [
        {StoredData.settings},
      ]),
    );

    blocTest<StartupCubit, StartupState>(
      'storage still unusable afterwards shows the unavailable screen',
      setUp: () => storage.results.addAll([
        const StorageBroken({StoredData.entries}),
        const StorageCannotOpen(),
      ]),
      build: build,
      act: (cubit) async {
        await cubit.start();
        await cubit.startOver();
      },
      expect: () => [
        const StartupUnreadable({StoredData.entries}),
        const StartupLoading(),
        const StartupUnavailable(),
      ],
    );

    blocTest<StartupCubit, StartupState>(
      'does nothing unless something is broken',
      build: build,
      act: (cubit) async {
        await cubit.start();
        await cubit.startOver();
      },
      expect: () => [const StartupReady()],
      verify: (_) => expect(storage.startedOver, isEmpty),
    );
  });

  test('closing the cubit stops listening to the lock', () async {
    final cubit = build();
    await cubit.start();
    await cubit.close();

    expect(tabLock.hasListener, isFalse);
  });
}
