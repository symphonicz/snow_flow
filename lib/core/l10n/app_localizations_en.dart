// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonAddEntry => 'Add entry';

  @override
  String get commonIncome => 'Income';

  @override
  String get commonExpense => 'Expense';

  @override
  String get commonBalance => 'Balance';

  @override
  String get commonSummary => 'Summary';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonExportBackup => 'Export backup';

  @override
  String get commonToday => 'Today';

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryBills => 'Bills';

  @override
  String get categoryFun => 'Fun';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryOther => 'Other';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categorySide => 'Side income';

  @override
  String get categoryTransfer => 'Received';

  @override
  String get toastClose => 'Close';

  @override
  String get startupUnreadableTitle => 'Can\'t read your data';

  @override
  String startupUnreadableBody(String broken) {
    String _temp0 = intl.Intl.selectLogic(broken, {
      'entries':
          'The entries saved on this device can\'t be read. Nothing has been deleted.',
      'settings':
          'The settings on this device can\'t be read. Nothing has been deleted.',
      'other':
          'The entries and settings on this device can\'t be read. Nothing has been deleted.',
    });
    return '$_temp0';
  }

  @override
  String get startupUnavailableTitle => 'Can\'t open storage';

  @override
  String get startupUnavailableBody =>
      'SnowFlow can\'t open the storage on this device. Nothing has been deleted.';

  @override
  String get startupPrivateWindowTip =>
      'If this is a private window, try a normal window.';

  @override
  String get startupStartOver => 'Start over (delete old data)';

  @override
  String get startupConfirmTitle => 'Delete old data?';

  @override
  String startupConfirmBody(String broken) {
    String _temp0 = intl.Intl.selectLogic(broken, {
      'entries':
          'All entries will be deleted. Your settings stay. This can\'t be undone.',
      'settings':
          'Settings go back to the defaults. Your entries stay. This can\'t be undone.',
      'other':
          'All entries and settings will be deleted. This can\'t be undone.',
    });
    return '$_temp0';
  }

  @override
  String get startupOtherTabTitle => 'SnowFlow is open in another tab';

  @override
  String get startupOtherTabBody =>
      'It works in one tab at a time so your data doesn\'t get mixed up.';

  @override
  String get startupUseHere => 'Use it in this tab instead';
}
