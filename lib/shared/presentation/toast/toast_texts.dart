import 'dart:ui';

/// The toast's own Thai and English text (#51). Temporary until the ARB
/// files of #52 exist. Follows the app's language, not Thai → English.
sealed class ToastTexts {
  const ToastTexts();

  factory ToastTexts.of(Locale app) =>
      app.languageCode == 'th' ? const _ThaiTexts() : const _EnglishTexts();

  String get tryAgain;

  /// Read out for the ✕ button.
  String get close;
}

final class _EnglishTexts extends ToastTexts {
  const _EnglishTexts();

  @override
  String get tryAgain => 'Try again';

  @override
  String get close => 'Close';
}

final class _ThaiTexts extends ToastTexts {
  const _ThaiTexts();

  @override
  String get tryAgain => 'ลองอีกครั้ง';

  @override
  String get close => 'ปิด';
}
