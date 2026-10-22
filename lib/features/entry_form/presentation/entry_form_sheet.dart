import 'package:flutter/material.dart';
import 'package:snow_flow/shared/domain/entry.dart';

/// Opens the entry form over the current page: a new entry, or [entry] to
/// edit (brief §4.1). It has no route of its own, so back closes it and the
/// page under it stays (#18 Q7, #59 Q1).
Future<void> showEntryForm(BuildContext context, {Entry? entry}) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => EntryFormSheet(entry: entry),
    );

/// Placeholder for the form; filled in by the entry form ticket (#61).
class EntryFormSheet extends StatelessWidget {
  const EntryFormSheet({super.key, this.entry});

  /// The entry to edit; null for a new one.
  final Entry? entry;

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: SizedBox(height: 240, width: double.infinity));
  }
}
