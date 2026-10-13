import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';

void main() {
  test('has the 10 categories of brief §5 in table order', () {
    expect(Categories.all.map((c) => c.id), [
      'food', 'transport', 'shopping', 'bills', 'fun', 'health', //
      'other', 'salary', 'side', 'transfer',
    ]);
  });

  test('byId finds a category or returns null', () {
    expect(Categories.byId('food')?.nameTh, 'อาหาร');
    expect(Categories.byId('transfer')?.nameEn, 'Received');
    expect(Categories.byId('other_e'), isNull);
    expect(Categories.byId('Food'), isNull);
  });

  test('forType lists expense categories with other last', () {
    expect(Categories.forType(EntryType.expense).map((c) => c.id), [
      'food',
      'transport',
      'shopping',
      'bills',
      'fun',
      'health',
      'other',
    ]);
  });

  test('forType lists income categories with other last', () {
    expect(Categories.forType(EntryType.income).map((c) => c.id), [
      'salary',
      'side',
      'transfer',
      'other',
    ]);
  });

  test('allows checks the entry type', () {
    expect(Categories.food.allows(EntryType.expense), isTrue);
    expect(Categories.food.allows(EntryType.income), isFalse);
    expect(Categories.salary.allows(EntryType.expense), isFalse);
    expect(Categories.other.allows(EntryType.expense), isTrue);
    expect(Categories.other.allows(EntryType.income), isTrue);
  });

  test('colors match brief §5; only salary changes in dark mode', () {
    expect(Categories.food.lightColor, 0xFFE07B39);
    expect(Categories.food.darkColor, 0xFFE07B39);
    expect(Categories.salary.lightColor, 0xFF0B7A63);
    expect(Categories.salary.darkColor, 0xFF4CC3A6);
    expect(Categories.all.where((c) => c.lightColor != c.darkColor), [
      Categories.salary,
    ]);
  });

  test('icons keep the shapes of brief §5', () {
    expect(Categories.side.icon, const [
      PathShape('M12 15V9'),
      PathShape('M12 10.5c0-3 2-5 5-5 0 3-2 5-5 5Z'),
      PathShape('M12 12c0-2.4-1.6-4-4-4 0 2.4 1.6 4 4 4Z'),
      EllipseShape(cx: 12, cy: 18, rx: 7, ry: 2.5),
    ]);
    expect(Categories.other.icon, const [
      CircleShape(cx: 6, cy: 12, r: 1.2),
      CircleShape(cx: 12, cy: 12, r: 1.2),
      CircleShape(cx: 18, cy: 12, r: 1.2),
    ]);
    expect(
      Categories.transport.icon.first,
      const RectShape(x: 5, y: 4, width: 14, height: 13, rx: 2.5),
    );
  });

  test('every category has names and an icon', () {
    for (final category in Categories.all) {
      expect(category.nameTh, isNotEmpty, reason: category.id);
      expect(category.nameEn, isNotEmpty, reason: category.id);
      expect(category.icon, isNotEmpty, reason: category.id);
    }
  });
}
