import 'package:flutter/material.dart';
import 'package:snow_flow/core/format/date_format.dart';
import 'package:snow_flow/core/format/money_format.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/features/entries/domain/day_groups.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/presentation/shrink_to_fit.dart';

/// The heading of one day (brief §4.2): "วันนี้", "เมื่อวาน" or the day's
/// name and date, then the day's net per currency. A net is coloured like
/// an EntryRow: income with "+", expense in ink with "−", zero in ink-3
/// (#60). Several currencies wrap onto more lines.
class DayHeader extends StatelessWidget {
  const DayHeader({super.key, required this.day, required this.today});

  final DayGroup day;
  final LocalDate today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final title = switch (day.relativeTo(today)) {
      RelativeDay.today => l10n.commonToday,
      RelativeDay.yesterday => l10n.commonYesterday,
      RelativeDay.other => formatDayHeader(
        day.date,
        Localizations.localeOf(context),
        today: today,
      ),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s12,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: AppText.label.copyWith(color: colors.ink2)),
        ),
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSpacing.s8,
            children: [
              for (final MapEntry(key: currency, value: net) in day.net.entries)
                ShrinkToFit(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    formatMoney(net, currency, signed: true),
                    style: AppText.label.copyWith(
                      color: net.minorUnits > 0
                          ? colors.income
                          : net.minorUnits < 0
                          ? colors.ink
                          : colors.ink3,
                    ),
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
