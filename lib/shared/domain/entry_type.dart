/// Income or expense. [name] is the value stored and written to backups.
enum EntryType {
  expense,
  income;

  /// Reads a stored value exactly; null when it is neither.
  static EntryType? tryParse(String name) => values.asNameMap()[name];
}
