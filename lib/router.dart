/// Composition root for navigation: the only file besides `injection.dart`
/// allowed to import every feature (ADR 0003).
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/features/entries/presentation/entries_cubit.dart';
import 'package:snow_flow/features/entries/presentation/entries_page.dart';
import 'package:snow_flow/features/entry_form/presentation/entry_form_sheet.dart';
import 'package:snow_flow/features/settings/presentation/settings_page.dart';
import 'package:snow_flow/features/summary/presentation/summary_page.dart';
import 'package:snow_flow/shared/presentation/shell/mobile_shell.dart';
import 'package:snow_flow/shared/presentation/shell/mobile_stacked_page.dart';

const entriesPath = '/entries';
const summaryPath = '/summary';
const settingsPath = '/settings';

GoRouter createRouter() {
  // Settings opens with push so back returns to the tab it came from; this
  // makes push change the web URL too (go_router leaves it out by default),
  // so the address bar shows `#/settings` and a refresh stays there.
  GoRouter.optionURLReflectsImperativeAPIs = true;
  return GoRouter(
    initialLocation: entriesPath,
    // A URL with no route (typed by hand, an old link) quietly opens the
    // entries page instead of an error page (#59 Q2).
    onException: (context, state, router) => router.go(entriesPath),
    routes: [
      // The tabs keep their state when switching (#18 Q7). Branch order is
      // what MobileShell expects.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MobileShell(
          navigationShell: navigationShell,
          onAddEntry: showEntryForm,
          onOpenSettings: (context) => context.push(settingsPath),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: entriesPath,
                builder: (context, state) => BlocProvider(
                  create: (_) => GetIt.instance<EntriesCubit>()..start(),
                  child: EntriesPage(
                    onOpenEntry: (context, entry) =>
                        showEntryForm(context, entry: entry),
                    // The other-currency note (#12).
                    onOpenSummary: (context) => context.go(summaryPath),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: summaryPath,
                builder: (context, state) => const SummaryPage(),
              ),
            ],
          ),
        ],
      ),
      // Outside the shell: on mobile, settings is a page stacked over the
      // tabs without the bottom bar (#18 Q7).
      GoRoute(
        path: settingsPath,
        builder: (context, state) => MobileStackedPage(
          title: AppLocalizations.of(context).commonSettings,
          fallbackLocation: entriesPath,
          child: const SettingsPage(),
        ),
      ),
    ],
  );
}
