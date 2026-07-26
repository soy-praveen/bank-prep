/// BankPrep design system - mirrors the web app's tokens.
/// Dark default: bg 0E131A, surface 161D27, teal 2DD4BF accent.
library;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Extra semantic colors beyond ColorScheme.
class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color surface;
  final Color raised;
  final Color line;
  final Color ink;
  final Color muted;
  final Color accent;
  final Color good;
  final Color warn;
  final Color danger;
  final Color violet;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.raised,
    required this.line,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.good,
    required this.warn,
    required this.danger,
    required this.violet,
  });

  static const dark = AppColors(
    bg: Color(0xFF0E131A),
    surface: Color(0xFF161D27),
    raised: Color(0xFF1D2631),
    line: Color(0xFF2A3542),
    ink: Color(0xFFE7ECF3),
    muted: Color(0xFF96A2B3),
    accent: Color(0xFF2DD4BF),
    good: Color(0xFF43C88A),
    warn: Color(0xFFE0A63C),
    danger: Color(0xFFFB5F97),
    violet: Color(0xFF818CF8),
  );

  static const light = AppColors(
    bg: Color(0xFFEEF1F5),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFF4F6F9),
    line: Color(0xFFD8DEE7),
    ink: Color(0xFF1A2230),
    muted: Color(0xFF5B6676),
    accent: Color(0xFF0D9488),
    good: Color(0xFF2F9E6B),
    warn: Color(0xFFC9821B),
    danger: Color(0xFFE11D6F),
    violet: Color(0xFF6366F1),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) => t < 0.5 ? this : (other ?? this);
}

extension AppColorsX on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>()!;
}

/// Inter with a variable-weight axis.
TextStyle inter(double w, {double? size, Color? color, double? height, double? ls}) =>
    TextStyle(
      fontFamily: 'Inter',
      fontVariations: [FontVariation('wght', w)],
      fontSize: size,
      color: color,
      height: height,
      letterSpacing: ls,
    );

/// Space Grotesk for display / numbers.
TextStyle grotesk(double w, {double? size, Color? color, double? height, double? ls}) =>
    TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontVariations: [FontVariation('wght', w)],
      fontSize: size,
      color: color,
      height: height,
      letterSpacing: ls,
    );

ThemeData buildTheme(Brightness b) {
  final c = b == Brightness.dark ? AppColors.dark : AppColors.light;

  final scheme = ColorScheme(
    brightness: b,
    primary: c.accent,
    onPrimary: b == Brightness.dark ? const Color(0xFF04211C) : Colors.white,
    secondary: c.violet,
    onSecondary: Colors.white,
    error: c.danger,
    onError: Colors.white,
    surface: c.surface,
    onSurface: c.ink,
    surfaceContainerLowest: c.bg,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.raised,
    surfaceContainerHigh: c.raised,
    outline: c.line,
    outlineVariant: c.line,
    onSurfaceVariant: c.muted,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    fontFamily: 'Inter',
  );

  return base.copyWith(
    extensions: [c],
    textTheme: base.textTheme
        .copyWith(
          displayLarge: grotesk(700, size: 44, color: c.ink, height: 1.05),
          displayMedium: grotesk(700, size: 34, color: c.ink, height: 1.1),
          headlineMedium: grotesk(700, size: 26, color: c.ink, height: 1.15),
          headlineSmall: grotesk(600, size: 21, color: c.ink, height: 1.2),
          titleLarge: inter(650, size: 18, color: c.ink, height: 1.25),
          titleMedium: inter(600, size: 15.5, color: c.ink, height: 1.3),
          titleSmall: inter(600, size: 13.5, color: c.ink),
          bodyLarge: inter(430, size: 15.5, color: c.ink, height: 1.5),
          bodyMedium: inter(430, size: 14, color: c.ink, height: 1.5),
          bodySmall: inter(430, size: 12.5, color: c.muted, height: 1.4),
          labelLarge: inter(600, size: 14, color: c.ink, ls: 0.1),
          labelMedium: inter(600, size: 12, color: c.muted, ls: 0.4),
          labelSmall: inter(650, size: 10.5, color: c.muted, ls: 0.8),
        )
        .apply(),
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: grotesk(650, size: 19, color: c.ink),
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: c.line),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.accent.withValues(alpha: 0.16),
      height: 68,
      surfaceTintColor: Colors.transparent,
      labelTextStyle:
          WidgetStatePropertyAll(inter(600, size: 11.5, color: c.muted)),
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected) ? c.accent : c.muted)),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: c.raised,
      selectedColor: c.accent.withValues(alpha: 0.18),
      labelStyle: inter(550, size: 13, color: c.ink),
      side: BorderSide(color: c.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.accent,
        foregroundColor:
            b == Brightness.dark ? const Color(0xFF04211C) : Colors.white,
        textStyle: inter(650, size: 15),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.ink,
        side: BorderSide(color: c.line),
        textStyle: inter(600, size: 14.5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.accent,
        textStyle: inter(600, size: 14),
      ),
    ),
    dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
      TargetPlatform.linux: FadeThroughPageTransitionsBuilder(),
    }),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.raised,
      contentTextStyle: inter(500, size: 14, color: c.ink),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.line)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
  );
}
