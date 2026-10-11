/// Composition root for navigation: the only file besides `injection.dart`
/// allowed to import every feature (ADR 0003).
library;

import 'package:go_router/go_router.dart';
import 'package:snow_flow/features/entries/presentation/entries_page.dart';

const entriesPath = '/entries';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: entriesPath,
    routes: [
      GoRoute(
        path: entriesPath,
        builder: (context, state) => const EntriesPage(),
      ),
    ],
  );
}
