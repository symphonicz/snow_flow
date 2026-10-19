import 'package:snow_flow/core/storage/storage_persistence_stub.dart'
    if (dart.library.js_interop) 'package:snow_flow/core/storage/storage_persistence_web.dart';

/// What the browser said when asked to keep the stored data (#16 Q2). The
/// settings page always warns on web and uses this for the tone (#65).
enum StoragePersistence { granted, denied, notWeb }

/// The answer, asked once per app run (never saved): retrying or taking the
/// tab back reuses it. No answer within a second counts as
/// [StoragePersistence.denied], so a slow browser cannot hold up the first
/// page.
final Future<StoragePersistence> storagePersistence =
    requestPlatformPersistence().timeout(
      const Duration(seconds: 1),
      onTimeout: () => StoragePersistence.denied,
    );
