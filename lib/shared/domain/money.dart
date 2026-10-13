import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

/// Why an amount is not allowed (brief §3).
enum AmountProblem { invalid, tooManyDecimals, notPositive, tooLarge }

/// An amount in minor units: always ×100, whatever the currency (ADR 0002).
/// 60.50 → 6050, ¥500 → 50000.
class Money extends Equatable {
  const Money(this.minorUnits);

  /// 999,999,999.99
  static const maxMinorUnits = 99999999999;

  static final _number = RegExp(r'^(-?)(\d*)(?:\.(\d*))?$');

  final int minorUnits;

  /// Reads a typed amount such as `60.50` without going through a double.
  static Either<AmountProblem, Money> parse(String text) {
    final match = _number.firstMatch(text.trim());
    final whole = match?.group(2) ?? '';
    final fraction = match?.group(3) ?? '';
    if (match == null || whole.isEmpty && fraction.isEmpty) {
      return const Left(AmountProblem.invalid);
    }
    if (fraction.length > 2) return const Left(AmountProblem.tooManyDecimals);

    final digits = '$whole${fraction.padRight(2, '0')}'.replaceFirst(
      RegExp('^0+'),
      '',
    );
    if (digits.isEmpty || match.group(1)!.isNotEmpty) {
      return const Left(AmountProblem.notPositive);
    }
    // Longer than the limit would overflow int before we could compare.
    if (digits.length > '$maxMinorUnits'.length) {
      return const Left(AmountProblem.tooLarge);
    }
    final money = Money(int.parse(digits));
    final problem = money.problem;
    return problem == null ? Right(money) : Left(problem);
  }

  /// The broken rule, or null when the amount can be saved.
  AmountProblem? get problem => switch (minorUnits) {
    <= 0 => AmountProblem.notPositive,
    > maxMinorUnits => AmountProblem.tooLarge,
    _ => null,
  };

  /// The decimal written to the backup file: 6050 → 60.5, 50000 → 500.
  num toDecimal() =>
      minorUnits % 100 == 0 ? minorUnits ~/ 100 : minorUnits / 100;

  Money operator +(Money other) => Money(minorUnits + other.minorUnits);

  Money operator -(Money other) => Money(minorUnits - other.minorUnits);

  @override
  List<Object> get props => [minorUnits];

  @override
  String toString() => 'Money($minorUnits)';
}
