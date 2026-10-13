import 'package:equatable/equatable.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/map_fields.dart';

enum ThemePreference { system, light, dark }

/// The language the user picked. AppSettings.lang is null until they pick
/// one, and the app follows the device meanwhile (#54).
enum AppLanguage { th, en }

/// Time of the daily reminder, stored as `HH:mm`.
class ReminderTime extends Equatable {
  const ReminderTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60);

  static final _format = RegExp(r'^(\d{2}):(\d{2})$');

  final int hour;
  final int minute;

  static ReminderTime? tryParse(String text) {
    final match = _format.firstMatch(text);
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return ReminderTime(hour, minute);
  }

  @override
  List<Object> get props => [hour, minute];

  @override
  String toString() =>
      '${'$hour'.padLeft(2, '0')}:${'$minute'.padLeft(2, '0')}';
}

/// The settings of brief §3 with their defaults.
class AppSettings extends Equatable {
  const AppSettings({
    this.theme = ThemePreference.system,
    this.lang,
    this.currency = Currency.thb,
    this.remind = true,
    this.remindTime = const ReminderTime(20, 0),
    this.cycleStartDay = 1,
    this.sideOpen = false,
  }) : assert(cycleStartDay >= 1 && cycleStartDay <= 31);

  /// Reads a map written by [toMap]. A missing field takes its default, so
  /// new settings need no migration (ADR 0002). Throws [FormatException]
  /// for a value of the wrong type or out of range.
  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    const defaults = AppSettings();
    final cycleStartDay = optionalField<int>(
      map,
      'cycleStartDay',
      defaults.cycleStartDay,
    );
    if (cycleStartDay < 1 || cycleStartDay > 31) {
      throw FormatException('Field "cycleStartDay" is $cycleStartDay');
    }
    return AppSettings(
      theme: parseOptionalField(
        map,
        'theme',
        (name) => ThemePreference.values.asNameMap()[name],
        defaults.theme,
      ),
      lang: parseOptionalField(
        map,
        'lang',
        (name) => AppLanguage.values.asNameMap()[name],
        null,
      ),
      currency: parseOptionalField(
        map,
        'currency',
        Currency.byCode,
        defaults.currency,
      ),
      remind: optionalField<bool>(map, 'remind', defaults.remind),
      remindTime: parseOptionalField(
        map,
        'remindTime',
        ReminderTime.tryParse,
        defaults.remindTime,
      ),
      cycleStartDay: cycleStartDay,
      sideOpen: optionalField<bool>(map, 'sideOpen', defaults.sideOpen),
    );
  }

  final ThemePreference theme;

  /// Null until the user picks a language; follow the device meanwhile.
  final AppLanguage? lang;

  /// Default currency for the balance card and for new entries when no
  /// entry exists yet.
  final Currency currency;
  final bool remind;
  final ReminderTime remindTime;

  /// Day each month cycle starts, 1–31 (brief §4.4).
  final int cycleStartDay;

  /// Web: whether the sidebar is expanded.
  final bool sideOpen;

  /// Never rename a key.
  Map<String, Object?> toMap() => {
    'theme': theme.name,
    'lang': lang?.name,
    'currency': currency.code,
    'remind': remind,
    'remindTime': '$remindTime',
    'cycleStartDay': cycleStartDay,
    'sideOpen': sideOpen,
  };

  /// [lang] cannot go back to null: once picked, the language stays (#54).
  AppSettings copyWith({
    ThemePreference? theme,
    AppLanguage? lang,
    Currency? currency,
    bool? remind,
    ReminderTime? remindTime,
    int? cycleStartDay,
    bool? sideOpen,
  }) => AppSettings(
    theme: theme ?? this.theme,
    lang: lang ?? this.lang,
    currency: currency ?? this.currency,
    remind: remind ?? this.remind,
    remindTime: remindTime ?? this.remindTime,
    cycleStartDay: cycleStartDay ?? this.cycleStartDay,
    sideOpen: sideOpen ?? this.sideOpen,
  );

  @override
  List<Object?> get props => [
    theme,
    lang,
    currency,
    remind,
    remindTime,
    cycleStartDay,
    sideOpen,
  ];
}
