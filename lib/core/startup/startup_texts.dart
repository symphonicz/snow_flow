import 'dart:ui';

import 'package:snow_flow/core/startup/app_storage.dart';

/// Thai and English text for the startup screens (#56). Temporary until the
/// ARB files of #52 exist. These screens show before the settings can be
/// read, so the language always follows the device (not Thai → English).
sealed class StartupTexts {
  const StartupTexts();

  factory StartupTexts.of(Locale device) =>
      device.languageCode == 'th' ? const _ThaiTexts() : const _EnglishTexts();

  String get unreadableTitle;

  /// Says which data cannot be read and that nothing was deleted.
  String unreadableBody(Set<StoredData> broken);

  String get unavailableTitle;
  String get unavailableBody;
  String get privateWindowTip;
  String get tryAgain;
  String get startOver;
  String get confirmTitle;

  /// Says exactly what start over deletes, and what stays.
  String confirmBody(Set<StoredData> broken);

  String get confirmDelete;
  String get cancel;
  String get otherTabTitle;
  String get otherTabBody;
  String get useHere;
}

/// The one broken kind, or null when both are broken.
StoredData? _singleBroken(Set<StoredData> broken) =>
    broken.length == 1 ? broken.single : null;

final class _EnglishTexts extends StartupTexts {
  const _EnglishTexts();

  @override
  String get unreadableTitle => "Can't read your data";

  @override
  String unreadableBody(Set<StoredData> broken) => switch (_singleBroken(
    broken,
  )) {
    StoredData.entries =>
      "The entries saved on this device can't be read. "
          'Nothing has been deleted.',
    StoredData.settings =>
      "The settings on this device can't be read. Nothing has been deleted.",
    null =>
      "The entries and settings on this device can't be read. "
          'Nothing has been deleted.',
  };

  @override
  String get unavailableTitle => "Can't open storage";

  @override
  String get unavailableBody =>
      "SnowFlow can't open the storage on this device. "
      'Nothing has been deleted.';

  @override
  String get privateWindowTip =>
      'If this is a private window, try a normal window.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get startOver => 'Start over (delete old data)';

  @override
  String get confirmTitle => 'Delete old data?';

  @override
  String confirmBody(Set<StoredData> broken) => switch (_singleBroken(broken)) {
    StoredData.entries =>
      "All entries will be deleted. Your settings stay. This can't be undone.",
    StoredData.settings =>
      'Settings go back to the defaults. Your entries stay. '
          "This can't be undone.",
    null => "All entries and settings will be deleted. This can't be undone.",
  };

  @override
  String get confirmDelete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get otherTabTitle => 'SnowFlow is open in another tab';

  @override
  String get otherTabBody =>
      "It works in one tab at a time so your data doesn't get mixed up.";

  @override
  String get useHere => 'Use it in this tab instead';
}

final class _ThaiTexts extends StartupTexts {
  const _ThaiTexts();

  @override
  String get unreadableTitle => 'อ่านข้อมูลไม่ได้';

  @override
  String unreadableBody(Set<StoredData> broken) =>
      switch (_singleBroken(broken)) {
        StoredData.entries =>
          'อ่านรายการที่บันทึกไว้ในเครื่องนี้ไม่ได้ แอปยังไม่ได้ลบอะไร',
        StoredData.settings =>
          'อ่านการตั้งค่าในเครื่องนี้ไม่ได้ แอปยังไม่ได้ลบอะไร',
        null => 'อ่านรายการและการตั้งค่าในเครื่องนี้ไม่ได้ แอปยังไม่ได้ลบอะไร',
      };

  @override
  String get unavailableTitle => 'เปิดที่เก็บข้อมูลไม่ได้';

  @override
  String get unavailableBody =>
      'SnowFlow เปิดที่เก็บข้อมูลในเครื่องนี้ไม่ได้ แอปยังไม่ได้ลบอะไร';

  @override
  String get privateWindowTip =>
      'ถ้าเปิดในโหมดส่วนตัวอยู่ ลองเปิดในหน้าต่างปกติ';

  @override
  String get tryAgain => 'ลองใหม่';

  @override
  String get startOver => 'เริ่มใหม่ (ลบข้อมูลเดิม)';

  @override
  String get confirmTitle => 'ลบข้อมูลเดิม?';

  @override
  String confirmBody(Set<StoredData> broken) => switch (_singleBroken(broken)) {
    StoredData.entries =>
      'รายการทั้งหมดจะถูกลบ การตั้งค่ายังอยู่ ลบแล้วกู้คืนไม่ได้',
    StoredData.settings =>
      'การตั้งค่าจะกลับเป็นค่าเริ่มต้น รายการยังอยู่ ลบแล้วกู้คืนไม่ได้',
    null => 'รายการและการตั้งค่าทั้งหมดจะถูกลบ ลบแล้วกู้คืนไม่ได้',
  };

  @override
  String get confirmDelete => 'ลบ';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get otherTabTitle => 'SnowFlow เปิดอยู่ในแท็บอื่น';

  @override
  String get otherTabBody => 'ใช้ได้ทีละแท็บ เพื่อไม่ให้ข้อมูลทับกัน';

  @override
  String get useHere => 'ใช้ที่แท็บนี้แทน';
}
