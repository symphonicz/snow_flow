import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snow_flow/core/l10n/app_locale.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/core/startup/app_storage.dart';
import 'package:snow_flow/core/startup/startup_cubit.dart';
import 'package:snow_flow/core/startup/startup_state.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/presentation/icons/app_icons.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';

/// Shows the app only once [cubit] is ready, and a startup screen otherwise
/// (#56). The app is built fresh each time it becomes ready, because coming
/// back from another tab registers everything again.
class StartupGate extends StatefulWidget {
  const StartupGate({
    super.key,
    required this.cubit,
    required this.buildApp,
    this.isWeb = kIsWeb,
  });

  final StartupCubit cubit;
  final Widget Function() buildApp;

  /// Shows the private window tip; a parameter so tests can turn it on.
  final bool isWeb;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  Widget? _app;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StartupCubit, StartupState>(
      bloc: widget.cubit,
      builder: (context, state) {
        if (state is StartupReady) return _app ??= widget.buildApp();
        _app = null;
        return _StartupApp(
          state: state,
          cubit: widget.cubit,
          isWeb: widget.isWeb,
        );
      },
    );
  }
}

/// Its own [MaterialApp]: these screens show before the app's theme, router
/// and settings exist, so they follow the device's brightness and language
/// (not Thai → English, #56). Light and dark come from the theme file of
/// #51, the text from the ARB files of #52.
class _StartupApp extends StatelessWidget {
  const _StartupApp({
    required this.state,
    required this.cubit,
    required this.isWeb,
  });

  final StartupState state;
  final StartupCubit cubit;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnowFlow',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localeListResolutionCallback: (device, _) => deviceLocale(device),
      supportedLocales: appLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: _StartupScreen(state: state, cubit: cubit, isWeb: isWeb),
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen({
    required this.state,
    required this.cubit,
    required this.isWeb,
  });

  final StartupState state;
  final StartupCubit cubit;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: switch (state) {
        StartupLoading() || StartupReady() => const SizedBox.shrink(),
        StartupOtherTab() => _StartupMessage(
          icon: AppIcons.appWindow,
          title: l10n.startupOtherTabTitle,
          body: l10n.startupOtherTabBody,
          actions: [
            FilledButton(
              onPressed: cubit.takeOver,
              child: Text(l10n.startupUseHere),
            ),
          ],
        ),
        StartupUnavailable() => _StartupMessage(
          icon: AppIcons.database,
          title: l10n.startupUnavailableTitle,
          body: isWeb
              ? '${l10n.startupUnavailableBody} ${l10n.startupPrivateWindowTip}'
              : l10n.startupUnavailableBody,
          actions: [
            FilledButton(
              onPressed: cubit.retry,
              child: Text(l10n.commonTryAgain),
            ),
          ],
        ),
        StartupUnreadable(:final broken) => _StartupMessage(
          icon: AppIcons.circleAlert,
          title: l10n.startupUnreadableTitle,
          body: l10n.startupUnreadableBody(_brokenKey(broken)),
          actions: [
            FilledButton(
              onPressed: cubit.retry,
              child: Text(l10n.commonTryAgain),
            ),
            // The import button of #66 goes here.
            _StartOverButton(broken: broken, cubit: cubit),
          ],
        ),
      },
    );
  }
}

/// The ARB select value: the one broken kind, or `both`.
String _brokenKey(Set<StoredData> broken) =>
    broken.length == 1 ? broken.single.name : 'both';

class _StartOverButton extends StatelessWidget {
  const _StartOverButton({required this.broken, required this.cubit});

  final Set<StoredData> broken;
  final StartupCubit cubit;

  Future<void> _confirm(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.startupConfirmTitle),
        content: Text(l10n.startupConfirmBody(_brokenKey(broken))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: _deleteStyle(context),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.startOver();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _confirm(context),
      style: _deleteStyle(context),
      child: Text(
        AppLocalizations.of(context).startupStartOver,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Marks the buttons that delete data with the `expense` token.
  static ButtonStyle _deleteStyle(BuildContext context) =>
      TextButton.styleFrom(foregroundColor: AppColors.of(context).expense);
}

/// Icon, title, text and buttons, centred and scrollable so a narrow screen
/// or large text never overflows.
class _StartupMessage extends StatelessWidget {
  const _StartupMessage({
    required this.icon,
    required this.title,
    required this.body,
    required this.actions,
  });

  final List<IconShape> icon;
  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.messageMaxWidth,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s12,
              children: [
                LineIcon(icon, size: AppSizes.iconLarge),
                Text(
                  title,
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                Text(
                  body,
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s12),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
