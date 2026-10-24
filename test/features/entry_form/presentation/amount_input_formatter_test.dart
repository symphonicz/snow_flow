import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/features/entry_form/presentation/amount_input_formatter.dart';
import 'package:snow_flow/shared/domain/currency.dart';

/// [text] with the cursor where `|` is.
TextEditingValue _value(String text) {
  final cursor = text.indexOf('|');
  return TextEditingValue(
    text: text.replaceFirst('|', ''),
    selection: TextSelection.collapsed(offset: cursor),
  );
}

/// The field after going from [before] to [after], shown with `|` at the
/// cursor.
String _edit(String before, String after, {Currency currency = Currency.thb}) {
  final value = AmountInputFormatter(
    currency,
  ).formatEditUpdate(_value(before), _value(after));
  final offset = value.selection.extentOffset;
  return '${value.text.substring(0, offset)}|${value.text.substring(offset)}';
}

void main() {
  test('groups thousands as you type', () {
    expect(_edit('120|', '1200|'), '1,200|');
  });

  test('keeps the cursor after the same digit when a comma comes or goes', () {
    expect(_edit('1,2|00', '1,2|00'.replaceFirst('2|', '|')), '1|00');
    expect(_edit('1|00', '15|00'), '1,5|00');
    expect(_edit('1,5|00', '1,55|00'), '15,5|00');
  });

  test('takes decimals and groups only the whole part', () {
    expect(_edit('1200|', '1200.|'), '1,200.|');
    expect(_edit('1,200.|', '1,200.5|'), '1,200.5|');
    expect(_edit('1,200.5|', '1,200.50|'), '1,200.50|');
  });

  group('ignores a key that would break the rules', () {
    test('a tenth digit, past 999,999,999.99 (#37)', () {
      expect(_edit('999,999,999|', '9999999999|'), '999,999,999|');
      expect(_edit('999,999,999.99|', '999,999,999.999|'), '999,999,999.99|');
    });

    test('a third decimal', () {
      expect(_edit('60.50|', '60.505|'), '60.50|');
    });

    test('any decimal in JPY, KRW, VND and LAK (#12)', () {
      for (final currency in [
        Currency.jpy,
        Currency.krw,
        Currency.vnd,
        Currency.lak,
      ]) {
        expect(_edit('500|', '500.|', currency: currency), '500|');
      }
    });

    test('a second dot, a letter or a minus', () {
      expect(_edit('60.5|', '60.5.|'), '60.5|');
      expect(_edit('60|', '60a|'), '60|');
      expect(_edit('|60', '-|60'), '|60');
    });
  });

  group('a comma key (#61 Q6)', () {
    test('at the end with no dot yet is the decimal point', () {
      expect(_edit('1,200|', '1,200,|'), '1,200.|');
    });

    test('where it cannot be a decimal point changes nothing', () {
      expect(_edit('1,200.5|', '1,200.5,|'), '1,200.5|');
      expect(_edit('500|', '500,|', currency: Currency.jpy), '500|');
    });
  });

  test('takes a pasted grouped amount', () {
    expect(_edit('|', '1,200.50|'), '1,200.50|');
    expect(_edit('|', ' 60.50 |'), '60.50|');
  });

  test('drops leading zeros but keeps the one before the dot', () {
    expect(_edit('0|', '05|'), '5|');
    expect(_edit('|', '.|'), '0.|');
    expect(_edit('0.|', '0.5|'), '0.5|');
  });
}
