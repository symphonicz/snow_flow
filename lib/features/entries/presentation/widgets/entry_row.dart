import 'package:flutter/material.dart';
import 'package:snow_flow/core/format/money_format.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/money.dart';
import 'package:snow_flow/shared/presentation/category_name.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';
import 'package:snow_flow/shared/presentation/shrink_to_fit.dart';

/// One entry (brief §8): category tile | category and note | amount. The
/// whole row is tappable and has no divider. The note is one line cut with
/// "…" on purpose; the amount shrinks rather than cuts (#37).
class EntryRow extends StatelessWidget {
  const EntryRow({super.key, required this.entry, required this.onTap});

  final Entry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final income = entry.type == EntryType.income;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              spacing: AppSpacing.s12,
              children: [
                _CategoryTile(entry.category),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName(
                          AppLocalizations.of(context),
                          entry.category,
                        ),
                        style: AppText.amount.copyWith(color: colors.ink),
                      ),
                      if (entry.note.isNotEmpty)
                        Text(
                          entry.note,
                          style: AppText.caption.copyWith(color: colors.ink3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * AppSizes.rowAmountShare,
                  ),
                  child: ShrinkToFit(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      // Expense in ink with "−", income in income with "+".
                      formatMoney(
                        income ? entry.amount : const Money(0) - entry.amount,
                        entry.currency,
                        signed: true,
                      ),
                      style: AppText.amount.copyWith(
                        color: income ? colors.income : colors.ink,
                      ),
                      maxLines: 1,
                      softWrap: false,
                    ),
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

/// The category icon on its colour at 15% (brief §5).
class _CategoryTile extends StatelessWidget {
  const _CategoryTile(this.category);

  final EntryCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.categoryTile,
      height: AppSizes.categoryTile,
      decoration: BoxDecoration(
        color: categoryColor(
          context,
          category,
        ).withValues(alpha: AppColors.categoryTileAlpha),
        borderRadius: BorderRadius.circular(AppRadius.categoryTile),
      ),
      alignment: Alignment.center,
      child: CategoryIcon(category),
    );
  }
}
