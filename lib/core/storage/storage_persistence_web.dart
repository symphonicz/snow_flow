import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:snow_flow/core/storage/storage_persistence.dart';
import 'package:web/web.dart';

/// `navigator.storage.persist()`; missing or failing counts as denied.
Future<StoragePersistence> requestPlatformPersistence() async {
  try {
    final storage = window.navigator.storage;
    if (!storage.has('persist')) return StoragePersistence.denied;
    final granted = (await storage.persist().toDart).toDart;
    return granted ? StoragePersistence.granted : StoragePersistence.denied;
  } catch (_) {
    return StoragePersistence.denied;
  }
}
