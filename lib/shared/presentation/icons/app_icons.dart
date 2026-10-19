import 'package:snow_flow/shared/domain/entry_category.dart';

/// The app's own line icons, drawn with LineIcon on the 24×24 grid of brief
/// §6 (#51). Drawn for SnowFlow, not taken from an icon set: plump, round
/// shapes after the round bird of the app icon, and a "snow dot" — a tiny
/// circle in the gap of an open ring, or as a detail — as the signature.
/// Arrows and ✕ have no dot so they stay easy to read.
abstract final class AppIcons {
  /// A ring of radius 8.8 open at the top right, with its snow dot.
  static const _snowRing = [
    PathShape('M19.77 7.87A8.8 8.8 0 1 1 16.13 4.23'),
    CircleShape(cx: 18.22, cy: 5.78, r: .5),
  ];

  static const chevronDown = [
    PathShape('M7 10c1.7 1.9 3.3 3.3 5 4.5 1.7-1.2 3.3-2.6 5-4.5'),
  ];

  static const calendar = [
    RectShape(x: 3.5, y: 5, width: 17, height: 15.5, rx: 5),
    PathShape('M3.5 10h17M8.5 3.5v3M15.5 3.5v3'),
    CircleShape(cx: 15.5, cy: 15.2, r: .5),
  ];

  static const clock = [..._snowRing, PathShape('M12 8v4.2l2.6 1.6')];

  /// The add-entry button (never a plus sign, brief §6).
  static const pencil = [
    PathShape(
      'M14.9 5.1a2.9 2.9 0 0 1 4.1 4.1L9.5 18.6c-.5.5-1.1.8-1.8.95l-2.6.5'
      'a.9.9 0 0 1-1.05-1.05l.5-2.6c.15-.7.45-1.3.95-1.8Z',
    ),
    PathShape('M13.2 6.8l4.1 4.1'),
    CircleShape(cx: 19.4, cy: 15.4, r: .5),
  ];

  /// The settings gear: eight round petals around an open ring.
  static const settings = [
    PathShape(
      'M10.38 4.98A1.9 1.9 0 1 1 13.62 4.98A7.2 7.2 0 0 1 15.82 5.89'
      'A1.9 1.9 0 1 1 18.11 8.18A7.2 7.2 0 0 1 19.02 10.38'
      'A1.9 1.9 0 1 1 19.02 13.62A7.2 7.2 0 0 1 18.11 15.82'
      'A1.9 1.9 0 1 1 15.82 18.11A7.2 7.2 0 0 1 13.62 19.02'
      'A1.9 1.9 0 1 1 10.38 19.02A7.2 7.2 0 0 1 8.18 18.11'
      'A1.9 1.9 0 1 1 5.89 15.82A7.2 7.2 0 0 1 4.98 13.62'
      'A1.9 1.9 0 1 1 4.98 10.38A7.2 7.2 0 0 1 5.89 8.18'
      'A1.9 1.9 0 1 1 8.18 5.89A7.2 7.2 0 0 1 10.38 4.98Z',
    ),
    PathShape('M14.59 11.77A2.6 2.6 0 1 1 12.23 9.41'),
    CircleShape(cx: 13.84, cy: 10.16, r: .45),
  ];

  /// A padlock whose keyhole is the snow dot, next to "data stays on this
  /// device" (#51).
  static const lock = [
    RectShape(x: 4.5, y: 10, width: 15, height: 10.5, rx: 4.5),
    PathShape('M8 10V8.5a4 4 0 0 1 8 0V10'),
    CircleShape(cx: 12, cy: 15.2, r: .6),
  ];

  /// Success toast.
  static const circleCheck = [
    ..._snowRing,
    PathShape('M8.8 12.3c.8.7 1.6 1.5 2.3 2.3 1.2-1.7 2.6-3.2 4.1-4.6'),
  ];

  /// Error toast and the unreadable-data screen.
  static const circleAlert = [
    ..._snowRing,
    PathShape('M12 8.3v4.4'),
    CircleShape(cx: 12, cy: 15.9, r: .5),
  ];

  /// Info toast.
  static const info = [
    ..._snowRing,
    PathShape('M12 11.4V16'),
    CircleShape(cx: 12, cy: 8.2, r: .5),
  ];

  /// ✕
  static const close = [PathShape('M8.2 8.2l7.6 7.6M15.8 8.2l-7.6 7.6')];

  /// The open-in-another-tab screen.
  static const appWindow = [
    RectShape(x: 3, y: 4.5, width: 18, height: 15, rx: 4.5),
    PathShape('M3 9.5h18'),
    CircleShape(cx: 6.8, cy: 7, r: .45),
    CircleShape(cx: 9.3, cy: 7, r: .45),
  ];

  /// The storage-unavailable screen.
  static const database = [
    EllipseShape(cx: 12, cy: 6.3, rx: 7.5, ry: 3),
    PathShape(
      'M4.5 6.3v11.4c0 1.66 3.36 3 7.5 3s7.5-1.34 7.5-3V6.3'
      'M4.5 12c0 1.66 3.36 3 7.5 3s7.5-1.34 7.5-3',
    ),
  ];

  static const all = {
    'chevronDown': chevronDown,
    'calendar': calendar,
    'clock': clock,
    'pencil': pencil,
    'settings': settings,
    'lock': lock,
    'circleCheck': circleCheck,
    'circleAlert': circleAlert,
    'info': info,
    'close': close,
    'appWindow': appWindow,
    'database': database,
  };
}
