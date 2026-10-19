import 'package:snow_flow/core/storage/storage_persistence.dart';

/// Apps keep their data until uninstalled; there is nothing to ask.
Future<StoragePersistence> requestPlatformPersistence() async =>
    StoragePersistence.notWeb;
