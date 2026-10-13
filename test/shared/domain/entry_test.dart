import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';

void main() {
  final lunch = Entry(
    id: 'abc123',
    type: EntryType.expense,
    amount: const Money(6050),
    currency: Currency.thb,
    category: Categories.food,
    date: LocalDate(2026, 10, 3),
    note: 'ข้าวมันไก่',
    created: 1790000000000,
  );

  const lunchMap = {
    'id': 'abc123',
    'type': 'expense',
    'amount': 6050,
    'currency': 'THB',
    'category': 'food',
    'date': '2026-10-03',
    'note': 'ข้าวมันไก่',
    'created': 1790000000000,
  };

  group('toMap / fromMap', () {
    test('toMap uses the backup field names with amount in minor units', () {
      expect(lunch.toMap(), lunchMap);
    });

    test('fromMap reads what toMap wrote', () {
      expect(Entry.fromMap(lunchMap), lunch);
      expect(Entry.fromMap(lunch.toMap()), lunch);
    });

    test('fromMap accepts the untyped maps hive_ce returns', () {
      expect(Entry.fromMap(Map<dynamic, dynamic>.of(lunchMap)), lunch);
    });

    test('fromMap treats a missing note as empty', () {
      final map = {...lunchMap}..remove('note');
      expect(Entry.fromMap(map).note, '');
    });

    test('fromMap throws FormatException for a broken map', () {
      final broken = <String, Map<String, Object?>>{
        'missing id': {...lunchMap}..remove('id'),
        'empty id': {...lunchMap, 'id': ''},
        'unknown type': {...lunchMap, 'type': 'gift'},
        'amount as text': {...lunchMap, 'amount': '6050'},
        'amount as decimal': {...lunchMap, 'amount': 60.5},
        'missing amount': {...lunchMap}..remove('amount'),
        'unknown currency': {...lunchMap, 'currency': 'XXX'},
        'lowercase currency': {...lunchMap, 'currency': 'thb'},
        'unknown category': {...lunchMap, 'category': 'pets'},
        'bad date': {...lunchMap, 'date': '2026-02-30'},
        'note not text': {...lunchMap, 'note': 5},
        'missing created': {...lunchMap}..remove('created'),
      };
      for (final MapEntry(key: reason, value: map) in broken.entries) {
        expect(() => Entry.fromMap(map), throwsFormatException, reason: reason);
      }
    });
  });

  test('newId makes a random UUID', () {
    final uuid = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    final a = Entry.newId();
    expect(a, matches(uuid));
    expect(Entry.newId(), isNot(a));
  });

  test('copyWith changes only the given fields', () {
    final edited = lunch.copyWith(
      amount: const Money(7000),
      note: '',
      date: LocalDate(2026, 10, 2),
    );
    expect(edited.toMap(), {
      ...lunchMap,
      'amount': 7000,
      'note': '',
      'date': '2026-10-02',
    });
  });

  group('problems', () {
    test('is empty for a valid entry', () {
      expect(lunch.problems, isEmpty);
    });

    test('names a broken amount', () {
      expect(lunch.copyWith(amount: const Money(0)).problems, {
        EntryProblem.amountNotPositive,
      });
      expect(
        lunch.copyWith(amount: const Money(Money.maxMinorUnits + 1)).problems,
        {EntryProblem.amountTooLarge},
      );
    });

    test('names a category that does not fit the type', () {
      expect(lunch.copyWith(type: EntryType.income).problems, {
        EntryProblem.categoryDoesNotFitType,
      });
      expect(
        lunch
            .copyWith(type: EntryType.income, category: Categories.other)
            .problems,
        isEmpty,
      );
    });

    test('names a note longer than 100 characters', () {
      expect(lunch.copyWith(note: 'a' * 101).problems, {
        EntryProblem.noteTooLong,
      });
    });
  });

  group('noteFits counts characters as people see them', () {
    test('allows up to 100', () {
      expect(Entry.noteFits(''), isTrue);
      expect(Entry.noteFits('a' * 100), isTrue);
      expect(Entry.noteFits('a' * 101), isFalse);
    });

    test('Thai vowels and tone marks join their consonant', () {
      // "ที่" is 3 code units but 1 character on screen.
      expect(Entry.noteFits('ที่' * 100), isTrue);
      expect(Entry.noteFits('ที่' * 101), isFalse);
    });

    test('an emoji made of several parts counts as one', () {
      expect(Entry.noteFits('👨‍👩‍👧' * 100), isTrue);
      expect(Entry.noteFits('👨‍👩‍👧' * 101), isFalse);
    });
  });
}
