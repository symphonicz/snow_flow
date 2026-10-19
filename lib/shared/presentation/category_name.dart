import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';

/// The category's name in the app's language (#14).
/// A new category needs its ARB messages too; the test lists all of them.
String categoryName(AppLocalizations l10n, EntryCategory category) =>
    switch (category) {
      Categories.food => l10n.categoryFood,
      Categories.transport => l10n.categoryTransport,
      Categories.shopping => l10n.categoryShopping,
      Categories.bills => l10n.categoryBills,
      Categories.fun => l10n.categoryFun,
      Categories.health => l10n.categoryHealth,
      Categories.other => l10n.categoryOther,
      Categories.salary => l10n.categorySalary,
      Categories.side => l10n.categorySide,
      Categories.transfer => l10n.categoryTransfer,
      _ => throw ArgumentError.value(category.id, 'category', 'No ARB name'),
    };
