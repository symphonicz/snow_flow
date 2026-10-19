import 'package:flutter/material.dart';

/// Opens the entry form over the current page. It has no route of its own,
/// so back closes it and the page under it stays (#18 Q7, #59 Q1).
Future<void> showEntryForm(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (context) => const EntryFormSheet(),
);

/// Placeholder for the form; filled in by the entry form ticket (#61).
class EntryFormSheet extends StatelessWidget {
  const EntryFormSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: SizedBox(height: 240, width: double.infinity));
  }
}
