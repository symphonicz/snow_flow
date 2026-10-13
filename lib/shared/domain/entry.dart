import 'package:characters/characters.dart';
import 'package:equatable/equatable.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/map_fields.dart';
import 'package:snow_flow/shared/domain/money.dart';
import 'package:uuid/uuid.dart';

/// A rule from brief §3 that an entry breaks.
enum EntryProblem {
  amountNotPositive,
  amountTooLarge,
  categoryDoesNotFitType,
  noteTooLong,
}

/// One income or expense (brief §3).
class Entry extends Equatable {
  const Entry({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    this.note = '',
    required this.created,
  });

  /// Reads a map written by [toMap]. Throws [FormatException] when a field
  /// is missing or has the wrong type or an unknown value.
  factory Entry.fromMap(Map<dynamic, dynamic> map) {
    final id = requireField<String>(map, 'id');
    if (id.isEmpty) throw const FormatException('Field "id" is empty');
    return Entry(
      id: id,
      type: parseField(map, 'type', EntryType.tryParse),
      amount: Money(requireField<int>(map, 'amount')),
      currency: parseField(map, 'currency', Currency.byCode),
      category: parseField(map, 'category', Categories.byId),
      date: parseField(map, 'date', LocalDate.tryParse),
      note: optionalField<String>(map, 'note', ''),
      created: requireField<int>(map, 'created'),
    );
  }

  static const maxNoteLength = 100;

  static const _uuid = Uuid();

  /// UUID, or any non-empty id kept from an imported backup (#17).
  final String id;
  final EntryType type;
  final Money amount;
  final Currency currency;
  final EntryCategory category;
  final LocalDate date;

  /// Optional; empty when there is none.
  final String note;

  /// When it was saved, in milliseconds since the epoch. Orders entries
  /// within one day.
  final int created;

  static String newId() => _uuid.v4();

  /// Whether [note] is at most 100 characters as people see them (#17), so
  /// "ที่" counts as one.
  static bool noteFits(String note) => note.characters.length <= maxNoteLength;

  Set<EntryProblem> get problems => {
    if (amount.problem == AmountProblem.notPositive)
      EntryProblem.amountNotPositive,
    if (amount.problem == AmountProblem.tooLarge) EntryProblem.amountTooLarge,
    if (!category.allows(type)) EntryProblem.categoryDoesNotFitType,
    if (!noteFits(note)) EntryProblem.noteTooLong,
  };

  /// Field names match the backup file; `amount` is in minor units
  /// (ADR 0002). Never rename a key.
  Map<String, Object> toMap() => {
    'id': id,
    'type': type.name,
    'amount': amount.minorUnits,
    'currency': currency.code,
    'category': category.id,
    'date': '$date',
    'note': note,
    'created': created,
  };

  Entry copyWith({
    String? id,
    EntryType? type,
    Money? amount,
    Currency? currency,
    EntryCategory? category,
    LocalDate? date,
    String? note,
    int? created,
  }) => Entry(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    category: category ?? this.category,
    date: date ?? this.date,
    note: note ?? this.note,
    created: created ?? this.created,
  );

  @override
  List<Object> get props => [
    id,
    type,
    amount,
    currency,
    category,
    date,
    note,
    created,
  ];
}
