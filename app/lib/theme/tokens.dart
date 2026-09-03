import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Field-sky Swiss system from UI/UX Pro Max + Trovey horizon identity.
class TroveyColors {
  static const sky = Color(0xFFE8F4FA);
  static const stone = sky;
  static const skyDeep = Color(0xFFC9E3F0);
  static const paper = Color(0xFFFFFFFF);
  static const ticket = paper;
  static const ink = Color(0xFF13404A);
  static const stub = Color(0xFF0E6E8A);
  static const brass = Color(0xFF0E6E8A);
  static const dawn = Color(0xFFD97706);
  static const stamp = Color(0xFFDC2626);
  static const cleared = Color(0xFF0F766E);
  static const line = Color(0xFFC5D9E4);
  static const muted = Color(0xFF4B6570);
  static const nightBg = Color(0xFF0F1C24);
  static const nightTicket = Color(0xFF173044);
  static const nightInk = Color(0xFFE8F4FA);
}

class TroveySpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class TroveyTheme {
  static const sans = 'Atkinson Hyperlegible';
  static const monoFamily = 'Atkinson Hyperlegible';

  static TextTheme _text(Color ink, Color muted) {
    final base = GoogleFonts.atkinsonHyperlegibleTextTheme();
    return base.copyWith(
      displaySmall: GoogleFonts.atkinsonHyperlegible(
        fontSize: 30,
        height: 36 / 30,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      headlineMedium: GoogleFonts.atkinsonHyperlegible(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      headlineSmall: GoogleFonts.atkinsonHyperlegible(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleLarge: GoogleFonts.atkinsonHyperlegible(
        fontSize: 18,
        height: 28 / 18,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: GoogleFonts.atkinsonHyperlegible(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      bodyLarge: GoogleFonts.atkinsonHyperlegible(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      bodyMedium: GoogleFonts.atkinsonHyperlegible(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      labelLarge: GoogleFonts.atkinsonHyperlegible(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      labelMedium: GoogleFonts.atkinsonHyperlegible(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: muted,
      ),
    );
  }

  static ThemeData paper() {
    final scheme = const ColorScheme.light(
      primary: TroveyColors.brass,
      onPrimary: Colors.white,
      secondary: TroveyColors.dawn,
      onSecondary: Color(0xFF1A1204),
      surface: TroveyColors.paper,
      onSurface: TroveyColors.ink,
      error: TroveyColors.stamp,
      onError: Colors.white,
      outline: TroveyColors.line,
    );
    return _base(
      brightness: Brightness.light,
      scheme: scheme,
      scaffold: TroveyColors.sky,
      text: _text(TroveyColors.ink, TroveyColors.muted),
      navBg: TroveyColors.paper,
      indicator: TroveyColors.skyDeep,
      fieldFill: Colors.white,
    );
  }

  static ThemeData night() {
    final scheme = const ColorScheme.dark(
      primary: Color(0xFF5CB8D1),
      onPrimary: Color(0xFF0F1C24),
      secondary: TroveyColors.dawn,
      onSecondary: Color(0xFF1A1204),
      surface: TroveyColors.nightTicket,
      onSurface: TroveyColors.nightInk,
      error: Color(0xFFF07171),
      onError: Color(0xFF1A0A0A),
      outline: Color(0xFF2C4A5C),
    );
    return _base(
      brightness: Brightness.dark,
      scheme: scheme,
      scaffold: TroveyColors.nightBg,
      text: _text(TroveyColors.nightInk, const Color(0xFF9BB4C0)),
      navBg: TroveyColors.nightTicket,
      indicator: const Color(0xFF1E4A5C),
      fieldFill: const Color(0xFF122838),
    );
  }

  static ThemeData _base({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffold,
    required TextTheme text,
    required Color navBg,
    required Color indicator,
    required Color fieldFill,
  }) {
    final radius = BorderRadius.circular(16);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: text,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navBg,
        indicatorColor: indicator,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      ),
      chipTheme: ChipThemeData(
        selectedColor: scheme.primary.withValues(alpha: 0.16),
        backgroundColor: scheme.surface,
        side: BorderSide(color: scheme.outline),
        labelStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: scheme.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: scheme.outline)),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
    );
  }

  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double letterSpacing = 0.4,
  }) {
    return GoogleFonts.atkinsonHyperlegible(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.35,
    );
  }
}
