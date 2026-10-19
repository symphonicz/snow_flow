import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th'),
  ];

  /// No description provided for @commonAddEntry.
  ///
  /// In th, this message translates to:
  /// **'จดรายการ'**
  String get commonAddEntry;

  /// No description provided for @commonEntries.
  ///
  /// In th, this message translates to:
  /// **'รายการ'**
  String get commonEntries;

  /// No description provided for @commonIncome.
  ///
  /// In th, this message translates to:
  /// **'รายรับ'**
  String get commonIncome;

  /// No description provided for @commonExpense.
  ///
  /// In th, this message translates to:
  /// **'รายจ่าย'**
  String get commonExpense;

  /// No description provided for @commonBalance.
  ///
  /// In th, this message translates to:
  /// **'คงเหลือ'**
  String get commonBalance;

  /// No description provided for @commonSummary.
  ///
  /// In th, this message translates to:
  /// **'สรุป'**
  String get commonSummary;

  /// No description provided for @commonSettings.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่า'**
  String get commonSettings;

  /// No description provided for @commonSave.
  ///
  /// In th, this message translates to:
  /// **'บันทึก'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิก'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In th, this message translates to:
  /// **'ลบ'**
  String get commonDelete;

  /// No description provided for @commonTryAgain.
  ///
  /// In th, this message translates to:
  /// **'ลองอีกครั้ง'**
  String get commonTryAgain;

  /// No description provided for @commonExportBackup.
  ///
  /// In th, this message translates to:
  /// **'ส่งออกไฟล์สำรอง'**
  String get commonExportBackup;

  /// No description provided for @commonToday.
  ///
  /// In th, this message translates to:
  /// **'วันนี้'**
  String get commonToday;

  /// No description provided for @commonYesterday.
  ///
  /// In th, this message translates to:
  /// **'เมื่อวาน'**
  String get commonYesterday;

  /// No description provided for @commonBack.
  ///
  /// In th, this message translates to:
  /// **'กลับ'**
  String get commonBack;

  /// No description provided for @categoryFood.
  ///
  /// In th, this message translates to:
  /// **'อาหาร'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In th, this message translates to:
  /// **'เดินทาง'**
  String get categoryTransport;

  /// No description provided for @categoryShopping.
  ///
  /// In th, this message translates to:
  /// **'ช้อปปิ้ง'**
  String get categoryShopping;

  /// No description provided for @categoryBills.
  ///
  /// In th, this message translates to:
  /// **'บิล/ค่าน้ำไฟ'**
  String get categoryBills;

  /// No description provided for @categoryFun.
  ///
  /// In th, this message translates to:
  /// **'บันเทิง'**
  String get categoryFun;

  /// No description provided for @categoryHealth.
  ///
  /// In th, this message translates to:
  /// **'สุขภาพ'**
  String get categoryHealth;

  /// No description provided for @categoryOther.
  ///
  /// In th, this message translates to:
  /// **'อื่นๆ'**
  String get categoryOther;

  /// No description provided for @categorySalary.
  ///
  /// In th, this message translates to:
  /// **'เงินเดือน'**
  String get categorySalary;

  /// No description provided for @categorySide.
  ///
  /// In th, this message translates to:
  /// **'รายได้เสริม'**
  String get categorySide;

  /// No description provided for @categoryTransfer.
  ///
  /// In th, this message translates to:
  /// **'ได้รับโอน'**
  String get categoryTransfer;

  /// Read out for the toast's ✕ button.
  ///
  /// In th, this message translates to:
  /// **'ปิด'**
  String get toastClose;

  /// No description provided for @startupUnreadableTitle.
  ///
  /// In th, this message translates to:
  /// **'อ่านข้อมูลไม่ได้'**
  String get startupUnreadableTitle;

  /// Says which data cannot be read and that nothing was deleted. broken is entries, settings, or both.
  ///
  /// In th, this message translates to:
  /// **'{broken, select, entries{อ่านรายการที่บันทึกไว้ในเครื่องนี้ไม่ได้ แอปยังไม่ได้ลบอะไร} settings{อ่านการตั้งค่าในเครื่องนี้ไม่ได้ แอปยังไม่ได้ลบอะไร} other{อ่านรายการและการตั้งค่าในเครื่องนี้ไม่ได้ แอปยังไม่ได้ลบอะไร}}'**
  String startupUnreadableBody(String broken);

  /// No description provided for @startupUnavailableTitle.
  ///
  /// In th, this message translates to:
  /// **'เปิดที่เก็บข้อมูลไม่ได้'**
  String get startupUnavailableTitle;

  /// No description provided for @startupUnavailableBody.
  ///
  /// In th, this message translates to:
  /// **'SnowFlow เปิดที่เก็บข้อมูลในเครื่องนี้ไม่ได้ แอปยังไม่ได้ลบอะไร'**
  String get startupUnavailableBody;

  /// No description provided for @startupPrivateWindowTip.
  ///
  /// In th, this message translates to:
  /// **'ถ้าเปิดในโหมดส่วนตัวอยู่ ลองเปิดในหน้าต่างปกติ'**
  String get startupPrivateWindowTip;

  /// No description provided for @startupStartOver.
  ///
  /// In th, this message translates to:
  /// **'เริ่มใหม่ (ลบข้อมูลเดิม)'**
  String get startupStartOver;

  /// No description provided for @startupConfirmTitle.
  ///
  /// In th, this message translates to:
  /// **'ลบข้อมูลเดิม?'**
  String get startupConfirmTitle;

  /// Says exactly what start over deletes, and what stays. broken is entries, settings, or both.
  ///
  /// In th, this message translates to:
  /// **'{broken, select, entries{รายการทั้งหมดจะถูกลบ การตั้งค่ายังอยู่ ลบแล้วกู้คืนไม่ได้} settings{การตั้งค่าจะกลับเป็นค่าเริ่มต้น รายการยังอยู่ ลบแล้วกู้คืนไม่ได้} other{รายการและการตั้งค่าทั้งหมดจะถูกลบ ลบแล้วกู้คืนไม่ได้}}'**
  String startupConfirmBody(String broken);

  /// No description provided for @startupOtherTabTitle.
  ///
  /// In th, this message translates to:
  /// **'SnowFlow เปิดอยู่ในแท็บอื่น'**
  String get startupOtherTabTitle;

  /// No description provided for @startupOtherTabBody.
  ///
  /// In th, this message translates to:
  /// **'ใช้ได้ทีละแท็บ เพื่อไม่ให้ข้อมูลทับกัน'**
  String get startupOtherTabBody;

  /// No description provided for @startupUseHere.
  ///
  /// In th, this message translates to:
  /// **'ใช้ที่แท็บนี้แทน'**
  String get startupUseHere;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
