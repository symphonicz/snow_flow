import 'package:flutter/services.dart';
import 'package:snow_flow/shared/domain/currency.dart';

/// Keeps the amount field grouped as `1,200.50` while typing (#61 Q6).
class AmountInputFormatter extends TextInputFormatter {
  AmountInputFormatter(this.currency);

  final Currency currency;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var raw = newValue.text;
    var cursor = newValue.selection.isValid
        ? newValue.selection.extentOffset
        : raw.length;
    // A "," key, as some keypads have instead of ".", is the decimal point
    // when one may still come; other commas are grouping and are dropped.
    if (raw == '${oldValue.text},') {
      if (oldValue.text.contains('.') || currency.fractionDigits == 0) {
        return oldValue;
      }
      raw = '${oldValue.text}.';
    }
    // Spaces from a paste.
    cursor = raw.substring(0, cursor).replaceAll(_space, '').length;
    raw = raw.replaceAll(_space, '');
    final match = _amount.firstMatch(raw.replaceAll(',', ''));
    if (match == null) return oldValue;
    final typedWhole = match.group(1)!;
    final hasDot = match.group(2) != null;
    final fraction = match.group(3) ?? '';
    if (hasDot && currency.fractionDigits == 0 ||
        fraction.length > currency.fractionDigits) {
      return oldValue;
    }
    var whole = typedWhole.replaceFirst(RegExp('^0+'), '');
    if (whole.isEmpty && (typedWhole.isNotEmpty || hasDot)) whole = '0';
    // 999,999,999.99 is the most an entry may hold (#37).
    if (whole.length > _maxWholeDigits) return oldValue;

    final text = '${_group(whole)}${hasDot ? '.$fraction' : ''}';
    // Zeros taken off the front, or the 0 put before a dot, move the rest.
    final kept =
        raw.substring(0, cursor).replaceAll(',', '').length +
        whole.length -
        typedWhole.length;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: _offsetAfter(text, kept < 0 ? 0 : kept),
      ),
    );
  }
}

final _amount = RegExp(r'^(\d*)(\.(\d*))?$');

final _space = RegExp(r'\s');

const _maxWholeDigits = 9;

String _group(String whole) => whole.replaceAllMapped(
  RegExp(r'\d(?=(\d{3})+$)'),
  (match) => '${match[0]},',
);

/// Where the cursor goes in [text] to stay after [kept] characters that are
/// not grouping commas.
int _offsetAfter(String text, int kept) {
  var seen = 0;
  for (var i = 0; i < text.length; i++) {
    if (seen == kept) return i;
    if (text[i] != ',') seen++;
  }
  return text.length;
}
