part of 'entry_form_cubit.dart';

/// Where saving or deleting stands; the sheet closes or shows a toast on
/// each change (#61 Q4).
enum EntryFormStatus {
  editing,

  /// Saving or deleting; the buttons are off so a double tap adds nothing
  /// twice.
  busy,
  saved,
  deleted,
  saveFailed,
  deleteFailed,

  /// The entry being edited was deleted meanwhile (#61 Q4).
  gone,
}

final class EntryFormState extends Equatable {
  const EntryFormState({
    required this.original,
    required this.type,
    required this.amountText,
    required this.currency,
    required this.category,
    required this.date,
    required this.note,
    required this.today,
    this.showAmountError = false,
    this.status = EntryFormStatus.editing,
  });

  /// The entry as saved, when editing one; null for a new entry.
  final Entry? original;

  final EntryType type;

  /// What is in the amount field, grouped as typed, e.g. `1,200.5`.
  final String amountText;

  /// Null only until a new entry has read its default currency.
  final Currency? currency;

  final EntryCategory category;
  final LocalDate date;
  final String note;

  /// The last day the date picker offers (brief §4.1).
  final LocalDate today;

  /// Whether "ใส่จำนวนเงินที่มากกว่า 0" shows under the amount (brief §4.1).
  final bool showAmountError;

  final EntryFormStatus status;

  bool get isEditing => original != null;

  EntryFormState copyWith({
    EntryType? type,
    String? amountText,
    Currency? currency,
    EntryCategory? category,
    LocalDate? date,
    String? note,
    bool? showAmountError,
    EntryFormStatus? status,
  }) => EntryFormState(
    original: original,
    type: type ?? this.type,
    amountText: amountText ?? this.amountText,
    currency: currency ?? this.currency,
    category: category ?? this.category,
    date: date ?? this.date,
    note: note ?? this.note,
    today: today,
    showAmountError: showAmountError ?? this.showAmountError,
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [
    original,
    type,
    amountText,
    currency,
    category,
    date,
    note,
    today,
    showAmountError,
    status,
  ];
}
