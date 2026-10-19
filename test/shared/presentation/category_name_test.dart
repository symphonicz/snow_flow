import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/presentation/category_name.dart';

Map<String, String> _names(String language) {
  final l10n = lookupAppLocalizations(Locale(language));
  return {
    for (final category in Categories.all)
      category.id: categoryName(l10n, category),
  };
}

void main() {
  test('every category has its Thai name from brief §5', () {
    expect(_names('th'), {
      'food': 'อาหาร',
      'transport': 'เดินทาง',
      'shopping': 'ช้อปปิ้ง',
      'bills': 'บิล/ค่าน้ำไฟ',
      'fun': 'บันเทิง',
      'health': 'สุขภาพ',
      'other': 'อื่นๆ',
      'salary': 'เงินเดือน',
      'side': 'รายได้เสริม',
      'transfer': 'ได้รับโอน',
    });
  });

  test('every category has its English name from brief §5', () {
    expect(_names('en'), {
      'food': 'Food',
      'transport': 'Transport',
      'shopping': 'Shopping',
      'bills': 'Bills',
      'fun': 'Fun',
      'health': 'Health',
      'other': 'Other',
      'salary': 'Salary',
      'side': 'Side income',
      'transfer': 'Received',
    });
  });
}
