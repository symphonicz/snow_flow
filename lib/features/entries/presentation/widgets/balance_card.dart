import 'package:flutter/material.dart';
import 'package:snow_flow/core/format/date_format.dart';
import 'package:snow_flow/core/format/money_format.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/currency_totals.dart';
import 'package:snow_flow/shared/domain/cycle.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/money.dart';
import 'package:snow_flow/shared/presentation/icons/app_icons.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';
import 'package:snow_flow/shared/presentation/shrink_to_fit.dart';

/// The balance of the current cycle in one currency (brief §4.4, §8): the
/// balance, how much of the income is spent, and the income and expense
/// tiles. Numbers shrink rather than cut (#37).
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.cycle,
    required this.currency,
    required this.totals,
  });

  final Cycle cycle;
  final Currency currency;
  final CurrencyTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final locale = Localizations.localeOf(context);
    final percent = totals.spentPercent;
    final sub = AppText.caption.copyWith(color: colors.heroSub);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: ColoredBox(
        color: colors.glacier,
        child: Stack(
          children: [
            // Hangs off the top right corner and is clipped by the card.
            PositionedDirectional(
              top: -AppSizes.heroCircle / 2,
              end: -AppSizes.heroCircle / 3,
              child: Container(
                width: AppSizes.heroCircle,
                height: AppSizes.heroCircle,
                decoration: BoxDecoration(
                  color: colors.heroTile,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.heroCard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      Text(l10n.entriesBalanceTitle, style: sub),
                      _Chip(formatCycle(cycle, locale)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _Balance(totals.balance, currency),
                  const SizedBox(height: AppSpacing.s16),
                  _ProgressBar(totals.spentRatio ?? 0),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    percent == null
                        ? l10n.entriesNoIncome
                        : l10n.entriesSpent(percent),
                    style: sub,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  _Tiles(totals: totals, currency: currency),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The cycle's label on the card.
class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.heroTile,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s4,
        ),
        child: Text(
          label,
          style: AppText.label.copyWith(color: colors.heroInk),
        ),
      ),
    );
  }
}

/// The balance with a smaller currency symbol (brief §6).
class _Balance extends StatelessWidget {
  const _Balance(this.balance, this.currency);

  final Money balance;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final parts = moneyParts(balance, currency);
    final style = AppText.balance.copyWith(
      color: AppColors.of(context).heroInk,
    );
    return ShrinkToFit(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${parts.sign}${parts.symbol}',
              style: style.copyWith(fontSize: AppText.balanceSymbolSize),
            ),
            TextSpan(text: parts.number),
          ],
        ),
        style: style,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}

/// Expense over income, full at 100% (brief §4.4).
class _ProgressBar extends StatelessWidget {
  const _ProgressBar(this.ratio);

  final double ratio;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = BorderRadius.circular(AppRadius.pill);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: AppSizes.progressBar,
        child: ColoredBox(
          color: colors.heroTrack,
          child: FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: ratio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.heroInk,
                borderRadius: radius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Income and expense side by side, or one above the other when the card
/// is too narrow for both (brief §8).
class _Tiles extends StatelessWidget {
  const _Tiles({required this.totals, required this.currency});

  final CurrencyTotals totals;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final income = _Tile(
      arrow: AppIcons.arrowIn,
      arrowColor: colors.income,
      label: l10n.commonIncome,
      amount: formatMoney(totals.income, currency),
    );
    final expense = _Tile(
      arrow: AppIcons.arrowOut,
      arrowColor: colors.expense,
      label: l10n.commonExpense,
      amount: formatMoney(totals.expense, currency),
    );
    final minWidth = MediaQuery.textScalerOf(
      context,
    ).scale(AppSizes.heroTileMinWidth);
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth < 2 * minWidth + AppSpacing.s12
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s12,
              children: [income, expense],
            )
          : Row(
              spacing: AppSpacing.s12,
              children: [
                Expanded(child: income),
                Expanded(child: expense),
              ],
            ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.arrow,
    required this.arrowColor,
    required this.label,
    required this.amount,
  });

  final List<IconShape> arrow;
  final Color arrowColor;
  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.heroTile,
        borderRadius: BorderRadius.circular(AppRadius.heroTile),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s12),
        child: Row(
          spacing: AppSpacing.s12,
          children: [
            Container(
              width: AppSizes.heroArrow,
              height: AppSizes.heroArrow,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: LineIcon(
                arrow,
                size: AppSizes.iconSmall,
                color: arrowColor,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppText.label.copyWith(color: colors.heroSub),
                  ),
                  ShrinkToFit(
                    child: Text(
                      amount,
                      style: AppText.amount.copyWith(color: colors.heroInk),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
