import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';

/// Sample entries for tests: [lunch] (THB) was created after [salary] (JPY).
final lunch = Entry(
  id: 'lunch',
  type: EntryType.expense,
  amount: const Money(6050),
  currency: Currency.thb,
  category: Categories.food,
  date: LocalDate(2026, 10, 3),
  note: 'ข้าวมันไก่',
  created: 1790000000000,
);

final salary = Entry(
  id: 'salary',
  type: EntryType.income,
  amount: const Money(3000000),
  currency: Currency.jpy,
  category: Categories.salary,
  date: LocalDate(2026, 10, 1),
  created: 1789800000000,
);
