import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/shared/domain/category_ranking.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/money.dart';

void main() {
  test('ranks categories from the most spent, with their share', () {
    final ranking = rankCategories({
      Categories.food: const Money(25000),
      Categories.bills: const Money(75000),
    });

    expect(ranking, [
      const CategoryShare(
        category: Categories.bills,
        amount: Money(75000),
        ratio: 0.75,
        percent: 75,
      ),
      const CategoryShare(
        category: Categories.food,
        amount: Money(25000),
        ratio: 0.25,
        percent: 25,
      ),
    ]);
  });

  test('equal amounts keep the category order of brief §5 (#19)', () {
    final ranking = rankCategories({
      Categories.health: const Money(100),
      Categories.food: const Money(100),
      Categories.transport: const Money(100),
    });

    expect(ranking.map((share) => share.category), [
      Categories.food,
      Categories.transport,
      Categories.health,
    ]);
  });

  group('percent (#58)', () {
    test('always adds up to 100, the higher rank taking the extra', () {
      final ranking = rankCategories({
        Categories.health: const Money(100),
        Categories.food: const Money(100),
        Categories.transport: const Money(100),
      });

      expect(ranking.map((share) => share.percent), [34, 33, 33]);
    });

    test('goes to the largest remainders, not by rounding each', () {
      // 46.6%, 26.7%, 26.7% → rounding each gives 47 + 27 + 27 = 101.
      final ranking = rankCategories({
        Categories.food: const Money(466),
        Categories.bills: const Money(267),
        Categories.fun: const Money(267),
      });

      expect(ranking.map((share) => share.percent), [46, 27, 27]);
    });

    test('a tiny category shows 0 while its bar keeps the exact ratio', () {
      final ranking = rankCategories({
        Categories.food: const Money(997),
        Categories.fun: const Money(3),
      });

      expect(ranking.last.percent, 0);
      expect(ranking.last.ratio, 0.003);
      expect(ranking.first.percent, 100);
    });

    test('a single category is 100', () {
      final ranking = rankCategories({Categories.food: const Money(6050)});

      expect(ranking.single.percent, 100);
      expect(ranking.single.ratio, 1.0);
    });
  });

  test('nothing spent ranks nothing', () {
    expect(rankCategories({}), isEmpty);
  });
}
