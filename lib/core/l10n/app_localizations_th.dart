// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get commonAddEntry => 'จดรายการ';

  @override
  String get commonEntries => 'รายการ';

  @override
  String get commonIncome => 'รายรับ';

  @override
  String get commonExpense => 'รายจ่าย';

  @override
  String get commonBalance => 'คงเหลือ';

  @override
  String get commonSummary => 'สรุป';

  @override
  String get commonSettings => 'ตั้งค่า';

  @override
  String get commonSave => 'บันทึก';

  @override
  String get commonCancel => 'ยกเลิก';

  @override
  String get commonDelete => 'ลบ';

  @override
  String get commonTryAgain => 'ลองอีกครั้ง';

  @override
  String get commonExportBackup => 'ส่งออกไฟล์สำรอง';

  @override
  String get commonToday => 'วันนี้';

  @override
  String get commonYesterday => 'เมื่อวาน';

  @override
  String get commonBack => 'กลับ';

  @override
  String get categoryFood => 'อาหาร';

  @override
  String get categoryTransport => 'เดินทาง';

  @override
  String get categoryShopping => 'ช้อปปิ้ง';

  @override
  String get categoryBills => 'บิล/ค่าน้ำไฟ';

  @override
  String get categoryFun => 'บันเทิง';

  @override
  String get categoryHealth => 'สุขภาพ';

  @override
  String get categoryOther => 'อื่นๆ';

  @override
  String get categorySalary => 'เงินเดือน';

  @override
  String get categorySide => 'รายได้เสริม';

  @override
  String get categoryTransfer => 'ได้รับโอน';

  @override
  String get toastClose => 'ปิด';

  @override
  String get startupUnreadableTitle => 'อ่านข้อมูลไม่ได้';

  @override
  String startupUnreadableBody(String broken) {
    String _temp0 = intl.Intl.selectLogic(broken, {
      'entries': 'อ่านรายการที่บันทึกไว้ในเครื่องนี้ไม่ได้ แอปยังไม่ได้ลบอะไร',
      'settings': 'อ่านการตั้งค่าในเครื่องนี้ไม่ได้ แอปยังไม่ได้ลบอะไร',
      'other': 'อ่านรายการและการตั้งค่าในเครื่องนี้ไม่ได้ แอปยังไม่ได้ลบอะไร',
    });
    return '$_temp0';
  }

  @override
  String get startupUnavailableTitle => 'เปิดที่เก็บข้อมูลไม่ได้';

  @override
  String get startupUnavailableBody =>
      'SnowFlow เปิดที่เก็บข้อมูลในเครื่องนี้ไม่ได้ แอปยังไม่ได้ลบอะไร';

  @override
  String get startupPrivateWindowTip =>
      'ถ้าเปิดในโหมดส่วนตัวอยู่ ลองเปิดในหน้าต่างปกติ';

  @override
  String get startupStartOver => 'เริ่มใหม่ (ลบข้อมูลเดิม)';

  @override
  String get startupConfirmTitle => 'ลบข้อมูลเดิม?';

  @override
  String startupConfirmBody(String broken) {
    String _temp0 = intl.Intl.selectLogic(broken, {
      'entries': 'รายการทั้งหมดจะถูกลบ การตั้งค่ายังอยู่ ลบแล้วกู้คืนไม่ได้',
      'settings':
          'การตั้งค่าจะกลับเป็นค่าเริ่มต้น รายการยังอยู่ ลบแล้วกู้คืนไม่ได้',
      'other': 'รายการและการตั้งค่าทั้งหมดจะถูกลบ ลบแล้วกู้คืนไม่ได้',
    });
    return '$_temp0';
  }

  @override
  String get startupOtherTabTitle => 'SnowFlow เปิดอยู่ในแท็บอื่น';

  @override
  String get startupOtherTabBody => 'ใช้ได้ทีละแท็บ เพื่อไม่ให้ข้อมูลทับกัน';

  @override
  String get startupUseHere => 'ใช้ที่แท็บนี้แทน';

  @override
  String get entriesBalanceTitle => 'คงเหลือเดือนนี้';

  @override
  String entriesSpent(int percent) {
    return 'ใช้ไปแล้ว $percent% ของรายรับเดือนนี้';
  }

  @override
  String get entriesNoIncome => 'ยังไม่มีรายรับเดือนนี้';

  @override
  String get entriesOtherCurrencies => 'มีรายการสกุลอื่นด้วย ดูในสรุป';

  @override
  String get entriesEmpty => 'ยังไม่มีรายการ กดจดรายการเพื่อเริ่ม';

  @override
  String get entriesUnreadable => 'อ่านรายการไม่ได้';
}
