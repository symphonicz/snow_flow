import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';

void main() {
  group('colours follow brief §6', () {
    test('light', () {
      final colors = AppTheme.light.extension<AppColors>()!;
      expect(colors.bg, const Color(0xFFF1F6F8));
      expect(colors.surface, const Color(0xFFFFFFFF));
      expect(colors.surface2, const Color(0xFFE4EEF2));
      expect(colors.line, const Color(0xFFD3E2E8));
      expect(colors.ink, const Color(0xFF0F2A36));
      expect(colors.ink2, const Color(0xFF3E5763));
      expect(colors.ink3, const Color(0xFF56707C));
      expect(colors.brand, const Color(0xFF1F5F75));
      expect(colors.onBrand, const Color(0xFFFFFFFF));
      expect(colors.glacier, const Color(0xFF7FB2C6));
      expect(colors.accent, const Color(0xFFF4A261));
      expect(colors.income, const Color(0xFF0B7A63));
      expect(colors.expense, const Color(0xFFB93E0B));
      expect(colors.heroInk, const Color(0xFF0F2A36));
      expect(colors.heroSub, const Color(0xFF1F4553));
      expect(colors.heroTile, const Color.fromRGBO(255, 255, 255, .45));
      expect(colors.heroTrack, const Color.fromRGBO(15, 42, 54, .16));
      expect(colors.tint, const Color(0xFFE1EFF4));
      expect(colors.scrim, const Color.fromRGBO(15, 42, 54, .5));
    });

    test('dark', () {
      final colors = AppTheme.dark.extension<AppColors>()!;
      expect(colors.bg, const Color(0xFF0C171D));
      expect(colors.surface, const Color(0xFF13222A));
      expect(colors.surface2, const Color(0xFF1C2E37));
      expect(colors.line, const Color(0xFF284049));
      expect(colors.ink, const Color(0xFFE6F1F5));
      expect(colors.ink2, const Color(0xFFAFC6CF));
      expect(colors.ink3, const Color(0xFF8AA4AE));
      expect(colors.brand, const Color(0xFF8FC3D6));
      expect(colors.onBrand, const Color(0xFF0C1F27));
      expect(colors.glacier, const Color(0xFF2A5566));
      expect(colors.accent, const Color(0xFFF4A261));
      expect(colors.income, const Color(0xFF4CC3A6));
      expect(colors.expense, const Color(0xFFF2905F));
      expect(colors.heroInk, const Color(0xFFEAF5F9));
      expect(colors.heroSub, const Color(0xFFB5D3DE));
      expect(colors.heroTile, const Color.fromRGBO(255, 255, 255, .08));
      expect(colors.heroTrack, const Color.fromRGBO(255, 255, 255, .16));
      expect(colors.tint, const Color(0xFF1E3A46));
      expect(colors.scrim, const Color.fromRGBO(0, 0, 0, .6));
    });

    test('Material widgets get the same colours', () {
      for (final (theme, brightness) in [
        (AppTheme.light, Brightness.light),
        (AppTheme.dark, Brightness.dark),
      ]) {
        final colors = theme.extension<AppColors>()!;
        expect(theme.brightness, brightness);
        expect(theme.scaffoldBackgroundColor, colors.bg);
        expect(theme.colorScheme.primary, colors.brand);
        expect(theme.colorScheme.onPrimary, colors.onBrand);
        expect(theme.colorScheme.surface, colors.surface);
        expect(theme.colorScheme.onSurface, colors.ink);
        expect(theme.colorScheme.error, colors.expense);
        // Cards, sheets and menus sit on surface; fields and tracks on
        // surface-2; selected chips and menu items on tint.
        final scheme = theme.colorScheme;
        expect(scheme.surfaceContainerLowest, colors.surface);
        expect(scheme.surfaceContainerLow, colors.surface);
        expect(scheme.surfaceContainer, colors.surface);
        expect(scheme.surfaceContainerHigh, colors.surface2);
        expect(scheme.surfaceContainerHighest, colors.surface2);
        expect(scheme.surfaceTint, Colors.transparent);
        expect(scheme.secondaryContainer, colors.tint);
        expect(scheme.onSecondaryContainer, colors.brand);
      }
    });

    testWidgets('AppColors.of reads the colours of the current theme', (
      tester,
    ) async {
      late AppColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              colors = AppColors.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(colors.bg, const Color(0xFF0C171D));
    });
  });

  group('type scale follows brief §6', () {
    // google_fonts names each loaded weight `<Family>_<variant>` (#51).
    const quicksand = {
      FontWeight.w400: 'Quicksand_regular',
      FontWeight.w600: 'Quicksand_600',
      FontWeight.w700: 'Quicksand_700',
    };
    const notoSansThai = {
      FontWeight.w400: 'NotoSansThai_regular',
      FontWeight.w600: 'NotoSansThai_600',
      FontWeight.w700: 'NotoSansThai_700',
    };

    /// Latin and digits in Quicksand, Thai in Noto Sans Thai of the same
    /// weight.
    void expectFonts(TextStyle style) {
      final weight = style.fontWeight!;
      expect(style.fontFamily, quicksand[weight], reason: '$weight');
      expect(style.fontFamilyFallback, [notoSansThai[weight]]);
    }

    void expectStyle(
      TextStyle style, {
      required double size,
      required double height,
      required FontWeight weight,
    }) {
      expectFonts(style);
      expect(style.fontSize, size);
      expect(style.height, height);
      expect(style.fontWeight, weight);
      expect(style.fontFeatures, [const FontFeature.tabularFigures()]);
    }

    test('styles', () {
      expectStyle(
        AppText.balance,
        size: 44,
        height: 1,
        weight: FontWeight.w700,
      );
      expectStyle(
        AppText.pageTitle,
        size: 30,
        height: 1.2,
        weight: FontWeight.w700,
      );
      expectStyle(
        AppText.pageTitleMobile,
        size: 28,
        height: 1.2,
        weight: FontWeight.w700,
      );
      expectStyle(
        AppText.sectionTitle,
        size: 17,
        height: 1.4,
        weight: FontWeight.w600,
      );
      expectStyle(
        AppText.amount,
        size: 16,
        height: 1.4,
        weight: FontWeight.w600,
      );
      expectStyle(
        AppText.body,
        size: 16,
        height: 1.55,
        weight: FontWeight.w400,
      );
      expectStyle(
        AppText.caption,
        size: 13.5,
        height: 1.45,
        weight: FontWeight.w400,
      );
      expectStyle(
        AppText.label,
        size: 12,
        height: 1.3,
        weight: FontWeight.w600,
      );
    });

    test('every Material text style uses the bundled weights in ink', () {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        final colors = theme.extension<AppColors>()!;
        final text = theme.textTheme;
        for (final style in [
          text.displayLarge!,
          text.headlineSmall!,
          text.titleMedium!,
          text.titleSmall!,
          text.bodyLarge!,
          text.labelLarge!,
          theme.primaryTextTheme.bodyLarge!,
          theme.primaryTextTheme.titleMedium!,
        ]) {
          // Material's own 500 has no bundled file, so it reads as 400.
          expect(quicksand.keys, contains(style.fontWeight));
          expectFonts(style);
          expect(style.fontFeatures, [const FontFeature.tabularFigures()]);
        }
        expect(text.bodyLarge!.fontSize, 16);
        expect(text.bodyLarge!.color, colors.ink);
        expect(text.bodySmall!.fontSize, 13.5);
        expect(text.bodySmall!.color, colors.ink3);
        expect(text.headlineSmall!.fontSize, 28);
        expect(text.titleMedium!.fontSize, 17);
      }
    });
  });

  group('bundled fonts (#51)', () {
    test('the theme never downloads a font', () {
      AppTheme.light;
      expect(GoogleFonts.config.allowRuntimeFetching, isFalse);
    });

    testWidgets('every weight loads from the app assets', (tester) async {
      // google_fonts only prints a failed load, so catch what it prints.
      final printed = <String?>[];
      final original = debugPrint;
      debugPrint = (message, {wrapWidth}) => printed.add(message);
      try {
        await tester.runAsync(loadAppFonts);
      } finally {
        debugPrint = original;
      }

      expect(printed.where((m) => m!.contains('unable to load font')), isEmpty);
    });

    test('the font licences are listed', () async {
      registerFontLicenses();
      final packages = <String>{};
      await for (final license in LicenseRegistry.licenses) {
        packages.addAll(license.packages);
      }
      expect(packages, containsAll(['Quicksand', 'Noto Sans Thai']));
    });
  });

  test('spacing, radii and shadows follow brief §6', () {
    expect(
      [
        AppSpacing.s4,
        AppSpacing.s8,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s20,
        AppSpacing.s24,
        AppSpacing.s40,
      ],
      [4, 8, 12, 16, 20, 24, 40],
    );
    expect(AppSpacing.screenEdge, 20);
    expect(AppSpacing.card, 20);
    expect(AppSpacing.heroCard, 22);
    expect(AppSpacing.webContent, 40);
    expect(AppSpacing.webColumnGap, 20);

    expect(
      [AppRadius.sm, AppRadius.md, AppRadius.lg, AppRadius.xl, AppRadius.pill],
      [10, 14, 20, 26, 999],
    );

    expect(AppShadows.card(Brightness.light), const [
      BoxShadow(
        offset: Offset(0, 2),
        blurRadius: 10,
        color: Color.fromRGBO(15, 42, 54, .06),
      ),
    ]);
    expect(AppShadows.card(Brightness.dark), const [
      BoxShadow(
        offset: Offset(0, 2),
        blurRadius: 10,
        color: Color.fromRGBO(0, 0, 0, .35),
      ),
    ]);
    expect(AppShadows.bar, const [
      BoxShadow(
        offset: Offset(0, -4),
        blurRadius: 20,
        color: Color.fromRGBO(15, 42, 54, .07),
      ),
    ]);
    expect(AppShadows.add, const [
      BoxShadow(
        offset: Offset(0, 12),
        blurRadius: 22,
        color: Color.fromRGBO(31, 95, 117, .35),
      ),
    ]);

    expect(AppSizes.minTouch, 44);
    expect(AppSizes.iconStroke, 1.8);
    expect(AppSizes.webBreakpoint, 900);
  });

  group('no lines (#37)', () {
    for (final (name, theme) in [
      ('light', AppTheme.light),
      ('dark', AppTheme.dark),
    ]) {
      test('$name theme turns off the lines Material draws', () {
        expect(theme.dividerColor, Colors.transparent);
        expect(theme.dividerTheme.color, Colors.transparent);
        expect(theme.colorScheme.outline, Colors.transparent);
        expect(theme.colorScheme.outlineVariant, Colors.transparent);
        expect(theme.tabBarTheme.dividerColor, Colors.transparent);
        final input = theme.inputDecorationTheme;
        for (final border in [
          input.border,
          input.enabledBorder,
          input.focusedBorder,
          input.errorBorder,
          input.focusedErrorBorder,
          input.disabledBorder,
        ]) {
          expect(border, InputBorder.none);
        }
      });

      test('$name theme shows focus as a darker background', () {
        final colors = theme.extension<AppColors>()!;
        final input = theme.inputDecorationTheme;
        expect(input.filled, isTrue);
        final fill = input.fillColor! as WidgetStateColor;
        expect(fill.resolve({}), colors.surface2);
        final focused = fill.resolve({WidgetState.focused});
        expect(focused, isNot(colors.surface2));
        expect(
          focused.computeLuminance(),
          name == 'light'
              ? lessThan(colors.surface2.computeLuminance())
              : greaterThan(colors.surface2.computeLuminance()),
          reason: 'focus stands out from the field in both themes',
        );
        expect(theme.focusColor, isNot(Colors.transparent));
      });
    }
  });

  test('each theme preference picks its theme mode', () {
    expect(themeModeFor(ThemePreference.system), ThemeMode.system);
    expect(themeModeFor(ThemePreference.light), ThemeMode.light);
    expect(themeModeFor(ThemePreference.dark), ThemeMode.dark);
  });
}
