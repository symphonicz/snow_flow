import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/features/entries/domain/day_groups.dart';
import 'package:snow_flow/features/entries/presentation/entries_cubit.dart';
import 'package:snow_flow/features/entries/presentation/widgets/balance_card.dart';
import 'package:snow_flow/features/entries/presentation/widgets/day_header.dart';
import 'package:snow_flow/features/entries/presentation/widgets/entry_row.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/presentation/icons/app_icons.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';
import 'package:snow_flow/shared/presentation/toast/toast.dart';

/// Opens [entry] for editing (brief §4.1).
typedef OpenEntry = void Function(BuildContext context, Entry entry);

/// The entries page (brief §4.2): the balance card, then every entry by day.
/// Reads an [EntriesCubit] from above. What tapping an entry or the
/// other-currency note opens comes from the router, because a feature may
/// not import another (ADR 0003).
class EntriesPage extends StatefulWidget {
  const EntriesPage({
    super.key,
    required this.onOpenEntry,
    required this.onOpenSummary,
  });

  final OpenEntry onOpenEntry;
  final void Function(BuildContext context) onOpenSummary;

  @override
  State<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends State<EntriesPage> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // The app coming back may be a new day (#60).
    _lifecycle = AppLifecycleListener(
      onResume: () => context.read<EntriesCubit>().refreshToday(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EntriesCubit, EntriesState>(
      // A read error after the entries are shown keeps them and says so in
      // a toast (#60 Q3).
      listenWhen: (previous, current) =>
          previous is EntriesLoaded &&
          current is EntriesLoaded &&
          current.failedReads > previous.failedReads,
      listener: (context, state) => showToast(
        context,
        AppLocalizations.of(context).entriesUnreadable,
        kind: ToastKind.error,
        onRetry: context.read<EntriesCubit>().retry,
      ),
      builder: (context, state) => switch (state) {
        EntriesLoading() => const SizedBox.shrink(),
        EntriesUnreadable() => const _Unreadable(),
        final EntriesLoaded loaded => _Entries(
          state: loaded,
          onOpenEntry: widget.onOpenEntry,
          onOpenSummary: widget.onOpenSummary,
        ),
      },
    );
  }
}

class _Entries extends StatelessWidget {
  const _Entries({
    required this.state,
    required this.onOpenEntry,
    required this.onOpenSummary,
  });

  final EntriesLoaded state;
  final OpenEntry onOpenEntry;
  final void Function(BuildContext context) onOpenSummary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = state.days;
    // Card (+ the other-currency note), then a day or the empty message.
    final top = [
      BalanceCard(
        cycle: state.cycle,
        currency: state.currency,
        totals: state.balance,
      ),
      if (state.hasOtherCurrencies)
        _OtherCurrencies(onTap: () => onOpenSummary(context)),
    ];
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.s8,
        AppSpacing.screenEdge,
        AppSpacing.s24,
      ),
      itemCount: top.length + (days.isEmpty ? 1 : days.length),
      itemBuilder: (context, index) {
        if (index < top.length) return top[index];
        if (days.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s40),
            child: Text(
              l10n.entriesEmpty,
              style: AppText.body.copyWith(color: AppColors.of(context).ink3),
              textAlign: TextAlign.center,
            ),
          );
        }
        return _Day(
          day: days[index - top.length],
          today: state.today,
          onOpenEntry: onOpenEntry,
        );
      },
    );
  }
}

/// "There are entries in other currencies too", opening the summary (#12).
class _OtherCurrencies extends StatelessWidget {
  const _OtherCurrencies({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            child: Row(
              spacing: AppSpacing.s8,
              children: [
                LineIcon(
                  AppIcons.info,
                  size: AppSizes.iconSmall,
                  color: colors.brand,
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).entriesOtherCurrencies,
                    style: AppText.caption.copyWith(color: colors.brand),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One day: its header, then its entries on a card.
class _Day extends StatelessWidget {
  const _Day({
    required this.day,
    required this.today,
    required this.onOpenEntry,
  });

  final DayGroup day;
  final LocalDate today;
  final OpenEntry onOpenEntry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s8,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            child: DayHeader(day: day, today: today),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card(Theme.of(context).brightness),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                  child: Column(
                    children: [
                      for (final entry in day.entries)
                        EntryRow(
                          entry: entry,
                          onTap: () => onOpenEntry(context, entry),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The first read failed, so there is nothing to show (#60 Q3).
class _Unreadable extends StatelessWidget {
  const _Unreadable();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.s12,
          children: [
            const LineIcon(AppIcons.circleAlert, size: AppSizes.iconLarge),
            Text(
              l10n.entriesUnreadable,
              style: AppText.body,
              textAlign: TextAlign.center,
            ),
            FilledButton(
              onPressed: context.read<EntriesCubit>().retry,
              child: Text(l10n.commonTryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
