/// The one theme file: every design token of brief §6 (#51).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';

/// The colour tokens of brief §6, read with [AppColors.of].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.line,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.brand,
    required this.onBrand,
    required this.glacier,
    required this.accent,
    required this.income,
    required this.expense,
    required this.heroInk,
    required this.heroSub,
    required this.heroTile,
    required this.heroTrack,
    required this.tint,
    required this.scrim,
  });

  static const light = AppColors(
    bg: Color(0xFFF1F6F8),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFE4EEF2),
    line: Color(0xFFD3E2E8),
    ink: Color(0xFF0F2A36),
    ink2: Color(0xFF3E5763),
    ink3: Color(0xFF56707C),
    brand: Color(0xFF1F5F75),
    onBrand: Color(0xFFFFFFFF),
    glacier: Color(0xFF7FB2C6),
    accent: Color(0xFFF4A261),
    income: Color(0xFF0B7A63),
    expense: Color(0xFFB93E0B),
    heroInk: Color(0xFF0F2A36),
    heroSub: Color(0xFF1F4553),
    heroTile: Color.fromRGBO(255, 255, 255, .45),
    heroTrack: Color.fromRGBO(15, 42, 54, .16),
    tint: Color(0xFFE1EFF4),
    scrim: Color.fromRGBO(15, 42, 54, .5),
  );

  static const dark = AppColors(
    bg: Color(0xFF0C171D),
    surface: Color(0xFF13222A),
    surface2: Color(0xFF1C2E37),
    line: Color(0xFF284049),
    ink: Color(0xFFE6F1F5),
    ink2: Color(0xFFAFC6CF),
    ink3: Color(0xFF8AA4AE),
    brand: Color(0xFF8FC3D6),
    onBrand: Color(0xFF0C1F27),
    glacier: Color(0xFF2A5566),
    accent: Color(0xFFF4A261),
    income: Color(0xFF4CC3A6),
    expense: Color(0xFFF2905F),
    heroInk: Color(0xFFEAF5F9),
    heroSub: Color(0xFFB5D3DE),
    heroTile: Color.fromRGBO(255, 255, 255, .08),
    heroTrack: Color.fromRGBO(255, 255, 255, .16),
    tint: Color(0xFF1E3A46),
    scrim: Color.fromRGBO(0, 0, 0, .6),
  );

  /// Page background.
  final Color bg;

  /// Cards, bottom bar, sidebar, form sheet.
  final Color surface;

  /// Text fields, segmented track, secondary buttons.
  final Color surface2;

  /// The chart baseline only.
  final Color line;

  /// Main text.
  final Color ink;

  /// Secondary text.
  final Color ink2;

  /// Descriptions, dates, notes.
  final Color ink3;

  /// Main button, add-entry button, selected tab.
  final Color brand;

  /// Text and icons on [brand] (and on the toasts).
  final Color onBrand;

  /// Balance card background; text on it uses [heroInk], never white.
  final Color glacier;

  /// At most one spot per page (the selected chart bar).
  final Color accent;

  /// Income amounts.
  final Color income;

  /// Expense totals and delete buttons.
  final Color expense;

  /// Text on the balance card.
  final Color heroInk;

  /// Labels on the balance card.
  final Color heroSub;

  /// Tiles and chips on the balance card.
  final Color heroTile;

  /// Progress bar track on the balance card.
  final Color heroTrack;

  /// Selected chip/menu background, ring around the add-entry button.
  final Color tint;

  /// Behind an open form sheet.
  final Color scrim;

  /// A category tile is its category's colour at this opacity (brief §5).
  static const categoryTileAlpha = .15;

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? line,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? brand,
    Color? onBrand,
    Color? glacier,
    Color? accent,
    Color? income,
    Color? expense,
    Color? heroInk,
    Color? heroSub,
    Color? heroTile,
    Color? heroTrack,
    Color? tint,
    Color? scrim,
  }) => AppColors(
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    surface2: surface2 ?? this.surface2,
    line: line ?? this.line,
    ink: ink ?? this.ink,
    ink2: ink2 ?? this.ink2,
    ink3: ink3 ?? this.ink3,
    brand: brand ?? this.brand,
    onBrand: onBrand ?? this.onBrand,
    glacier: glacier ?? this.glacier,
    accent: accent ?? this.accent,
    income: income ?? this.income,
    expense: expense ?? this.expense,
    heroInk: heroInk ?? this.heroInk,
    heroSub: heroSub ?? this.heroSub,
    heroTile: heroTile ?? this.heroTile,
    heroTrack: heroTrack ?? this.heroTrack,
    tint: tint ?? this.tint,
    scrim: scrim ?? this.scrim,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      bg: mix(bg, other.bg),
      surface: mix(surface, other.surface),
      surface2: mix(surface2, other.surface2),
      line: mix(line, other.line),
      ink: mix(ink, other.ink),
      ink2: mix(ink2, other.ink2),
      ink3: mix(ink3, other.ink3),
      brand: mix(brand, other.brand),
      onBrand: mix(onBrand, other.onBrand),
      glacier: mix(glacier, other.glacier),
      accent: mix(accent, other.accent),
      income: mix(income, other.income),
      expense: mix(expense, other.expense),
      heroInk: mix(heroInk, other.heroInk),
      heroSub: mix(heroSub, other.heroSub),
      heroTile: mix(heroTile, other.heroTile),
      heroTrack: mix(heroTrack, other.heroTrack),
      tint: mix(tint, other.tint),
      scrim: mix(scrim, other.scrim),
    );
  }
}

/// The type scale of brief §6, without colours (the theme adds them).
///
/// Fonts come only through google_fonts, read from the files bundled in
/// `assets/google_fonts/`, never downloaded (#51). Latin and digits are
/// Quicksand; Thai falls back to Noto Sans Thai of the same weight, so mixed
/// text needs nothing extra. Only 400, 600 and 700 are bundled, and
/// google_fonts names each weight its own family: to change a weight, build
/// the style again with [font] instead of `copyWith(fontWeight: …)`.
///
/// Neither font has tabular figures (`tnum`), so [_tabular] changes nothing
/// yet; it stays because brief §6 asks for it (#51).
abstract final class AppText {
  static const _tabular = [FontFeature.tabularFigures()];

  /// [style] in the app's fonts, its weight snapped to a bundled one.
  static TextStyle font(TextStyle style) {
    // Set before the first google_fonts call, which may start a download.
    GoogleFonts.config.allowRuntimeFetching = false;
    final weight = _bundledWeight(style.fontWeight);
    return GoogleFonts.quicksand(
      textStyle: style.copyWith(fontWeight: weight, fontFeatures: _tabular),
    ).copyWith(
      fontFamilyFallback: [
        GoogleFonts.notoSansThai(fontWeight: weight).fontFamily!,
      ],
    );
  }

  static FontWeight _bundledWeight(FontWeight? weight) => switch (weight) {
    FontWeight.w600 => FontWeight.w600,
    FontWeight.w700 || FontWeight.w800 || FontWeight.w900 => FontWeight.w700,
    _ => FontWeight.w400,
  };

  /// The balance number; its currency symbol uses [balanceSymbolSize].
  static final balance = font(
    const TextStyle(fontSize: 44, height: 1, fontWeight: FontWeight.w700),
  );
  static const balanceSymbolSize = 23.0;

  /// Page titles on the web layout.
  static final pageTitle = font(
    const TextStyle(fontSize: 30, height: 1.2, fontWeight: FontWeight.w700),
  );

  /// Page titles on the mobile layout.
  static final pageTitleMobile = font(
    const TextStyle(fontSize: 28, height: 1.2, fontWeight: FontWeight.w700),
  );

  /// Card headings.
  static final sectionTitle = font(
    const TextStyle(fontSize: 17, height: 1.4, fontWeight: FontWeight.w600),
  );

  /// Amounts in entry rows.
  static final amount = font(
    const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600),
  );

  /// General text and text fields.
  static final body = font(
    const TextStyle(fontSize: 16, height: 1.55, fontWeight: FontWeight.w400),
  );

  /// Notes and dates, in ink-3.
  static final caption = font(
    const TextStyle(fontSize: 13.5, height: 1.45, fontWeight: FontWeight.w400),
  );

  /// Menu labels and chips.
  static final label = font(
    const TextStyle(fontSize: 12, height: 1.3, fontWeight: FontWeight.w600),
  );

  /// [label] in bold: "Add entry" under the add-entry button.
  static final labelBold = font(
    const TextStyle(fontSize: 12, height: 1.3, fontWeight: FontWeight.w700),
  );

  /// Material's own styles mapped onto the scale above. The ones not in the
  /// scale get the app's fonts too.
  static TextTheme _textTheme(TextTheme base, AppColors colors) {
    final theme = _withFonts(base)
        .copyWith(
          headlineMedium: pageTitle,
          headlineSmall: pageTitleMobile,
          titleMedium: sectionTitle,
          bodyLarge: body,
          bodyMedium: body,
          bodySmall: caption,
          labelLarge: amount,
          labelMedium: label,
          labelSmall: label,
        )
        .apply(bodyColor: colors.ink, displayColor: colors.ink);
    return theme.copyWith(
      bodySmall: theme.bodySmall!.copyWith(color: colors.ink3),
    );
  }

  static TextTheme _withFonts(TextTheme t) {
    TextStyle? apply(TextStyle? style) => style == null ? null : font(style);
    return TextTheme(
      displayLarge: apply(t.displayLarge),
      displayMedium: apply(t.displayMedium),
      displaySmall: apply(t.displaySmall),
      headlineLarge: apply(t.headlineLarge),
      headlineMedium: apply(t.headlineMedium),
      headlineSmall: apply(t.headlineSmall),
      titleLarge: apply(t.titleLarge),
      titleMedium: apply(t.titleMedium),
      titleSmall: apply(t.titleSmall),
      bodyLarge: apply(t.bodyLarge),
      bodyMedium: apply(t.bodyMedium),
      bodySmall: apply(t.bodySmall),
      labelLarge: apply(t.labelLarge),
      labelMedium: apply(t.labelMedium),
      labelSmall: apply(t.labelSmall),
    );
  }
}

/// Builds both themes and waits until every bundled font has loaded, so the
/// first frame never shows a fallback font. Call before `runApp`.
Future<void> loadAppFonts() async {
  AppTheme.light;
  AppTheme.dark;
  await GoogleFonts.pendingFonts();
}

/// Lists the OFL licences of the bundled fonts on Flutter's licence page,
/// as google_fonts asks.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (package, file) in const [
      ('Quicksand', 'OFL-Quicksand.txt'),
      ('Noto Sans Thai', 'OFL-NotoSansThai.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        package,
      ], await rootBundle.loadString('assets/google_fonts/$file'));
    }
  });
}

/// The spacing scale of brief §6 and the named gaps built from it.
abstract final class AppSpacing {
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s40 = 40.0;

  /// Mobile screen edge.
  static const screenEdge = s20;

  /// Card padding (brief: 18–20).
  static const card = s20;

  /// Balance card padding.
  static const heroCard = 22.0;

  /// Web content padding.
  static const webContent = s40;

  /// Gap between web columns.
  static const webColumnGap = s20;
}

abstract final class AppRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 26.0;
  static const pill = 999.0;

  /// The income and expense tiles on the balance card (brief §8).
  static const heroTile = 16.0;

  /// The category tile (brief §5).
  static const categoryTile = 13.0;
}

/// Shadows stand in for borders everywhere (brief §6).
abstract final class AppShadows {
  static List<BoxShadow> card(Brightness brightness) => [
    BoxShadow(
      offset: const Offset(0, 2),
      blurRadius: 10,
      color: brightness == Brightness.light
          ? const Color.fromRGBO(15, 42, 54, .06)
          : const Color.fromRGBO(0, 0, 0, .35),
    ),
  ];

  /// The mobile bottom bar.
  static const bar = [
    BoxShadow(
      offset: Offset(0, -4),
      blurRadius: 20,
      color: Color.fromRGBO(15, 42, 54, .07),
    ),
  ];

  /// The add-entry button, together with a [AppSizes.addRing] ring of tint.
  static const add = [
    BoxShadow(
      offset: Offset(0, 12),
      blurRadius: 22,
      color: Color.fromRGBO(31, 95, 117, .35),
    ),
  ];
}

/// The colours of the app icon's SVG (brief §9), drawn by AppLogo. They are
/// part of the artwork, so both themes use the same ones.
abstract final class AppLogoColors {
  static const paper = Color(0xFFFFFFFF);
  static const shade = Color(0xFFDCE8EE);
  static const wing = Color(0xFF2E3A44);
  static const ink = Color(0xFF14202A);
}

/// Sizes that are not spacing: touch targets, icons, widths.
abstract final class AppSizes {
  /// Smallest height of anything tappable.
  static const minTouch = 44.0;

  /// Line icons are 20–24 px with a 1.8 px stroke on a 24 px grid.
  static const iconSmall = 20.0;
  static const icon = 24.0;
  static const iconStroke = 1.8;

  /// The icon above a full-screen message (the startup screens).
  static const iconLarge = 48.0;

  /// Tint ring around the add-entry button.
  static const addRing = 6.0;

  /// The mobile add-entry button, and how far it rises above the bar.
  static const addButton = 58.0;
  static const addLift = 28.0;

  /// The app logo in the mobile header.
  static const logo = 32.0;

  /// The category tile at the start of an entry row (brief §5).
  static const categoryTile = 42.0;

  /// Widest an entry row's amount gets, as a share of the row, so the
  /// category and note always keep some room.
  static const rowAmountShare = .45;

  /// The see-through circle off the balance card's top right (brief §8).
  static const heroCircle = 200.0;

  /// The balance card's progress bar (brief §8).
  static const progressBar = 8.0;

  /// The surface circle holding the arrow on an income or expense tile.
  static const heroArrow = 32.0;

  /// Narrowest an income or expense tile gets before the two stack
  /// (brief §8), at text scale 1.
  static const heroTileMinWidth = 150.0;

  /// From this width on, the web/tablet layout is used.
  static const webBreakpoint = 900.0;

  /// Widest a full-screen message gets.
  static const messageMaxWidth = 420.0;

  /// Widest a toast gets on the web layout (#20).
  static const toastMaxWidth = 320.0;
}

/// The light and dark [ThemeData] built from the tokens.
abstract final class AppTheme {
  static final light = _build(Brightness.light, AppColors.light);
  static final dark = _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final base = ThemeData(brightness: brightness);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: colors.brand,
          brightness: brightness,
        ).copyWith(
          primary: colors.brand,
          onPrimary: colors.onBrand,
          surface: colors.surface,
          onSurface: colors.ink,
          onSurfaceVariant: colors.ink2,
          error: colors.expense,
          onError: colors.onBrand,
          // Material's cards, sheets and menus use these, not surface.
          surfaceContainerLowest: colors.surface,
          surfaceContainerLow: colors.surface,
          surfaceContainer: colors.surface,
          surfaceContainerHigh: colors.surface2,
          surfaceContainerHighest: colors.surface2,
          surfaceTint: Colors.transparent,
          secondaryContainer: colors.tint,
          onSecondaryContainer: colors.brand,
          // Material draws its outlines and dividers in these two (#37).
          outline: Colors.transparent,
          outlineVariant: Colors.transparent,
        );
    // Keyboard focus is a darker (in dark mode: brighter) background,
    // never a ring (#37).
    final focus = colors.brand.withValues(alpha: .14);
    final focusFill = Color.alphaBlend(focus, colors.surface2);
    return ThemeData(
      brightness: brightness,
      textTheme: AppText._textTheme(base.textTheme, colors),
      primaryTextTheme: AppText._withFonts(base.primaryTextTheme),
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.bg,
      focusColor: focus,
      dividerColor: Colors.transparent,
      dividerTheme: const DividerThemeData(color: Colors.transparent),
      tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
      // Fields are surface-2 without a border. Rounded corners come from the
      // field widget clipping the fill, because InputBorder.none fills a
      // plain rectangle.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? focusFill
              : colors.surface2,
        ),
        hoverColor: focus,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      // The mobile entry form sheet: rounded top with a handle (brief §7).
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: colors.scrim,
        showDragHandle: true,
        dragHandleColor: colors.ink3.withValues(alpha: .4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        barrierColor: colors.scrim,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      iconTheme: IconThemeData(color: colors.ink2, size: AppSizes.icon),
      extensions: [colors],
    );
  }
}

/// The theme mode for the user's theme setting.
ThemeMode themeModeFor(ThemePreference preference) => switch (preference) {
  ThemePreference.system => ThemeMode.system,
  ThemePreference.light => ThemeMode.light,
  ThemePreference.dark => ThemeMode.dark,
};
