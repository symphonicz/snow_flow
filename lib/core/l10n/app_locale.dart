import 'dart:ui';

import 'package:snow_flow/shared/domain/app_settings.dart';

const thai = Locale('th');
const english = Locale('en');

/// The languages with an ARB file, Thai first (the main language).
const appLocales = [thai, english];

/// The app language for the device's languages: only the first one counts,
/// and only its language code; anything but Thai gets English (#14).
Locale deviceLocale(List<Locale>? device) =>
    device != null &&
        device.isNotEmpty &&
        device.first.languageCode == thai.languageCode
    ? thai
    : english;

/// The locale to hand `MaterialApp.locale`: null follows the device through
/// [deviceLocale] until the user picks a language (#54).
Locale? pickedLocale(AppLanguage? lang) => switch (lang) {
  null => null,
  AppLanguage.th => thai,
  AppLanguage.en => english,
};
