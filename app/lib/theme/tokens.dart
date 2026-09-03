import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _seed = Color(0xFF0E6E8A);

abstract final class TroveySpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class TroveyRadii {
  static const Radius md = Radius.circular(16);
  static const BorderRadius card = BorderRadius.all(md);
  static const BorderRadius pill = BorderRadius.all(Radius.circular(24));
}

class TroveyColors {
  static const sky = Color(0xFFF4F7F8);
  static const ink = Color(0xFF12262D);
  static const dawn = Color(0xFFB45309);
  static const cleared = Color(0xFF0F766E);
  static const line = Color(0xFFD5DEE2);
  static const muted = Color(0xFF4B6570);
  static const nightBg = Color(0xFF101416);
  static const nightInk = Color(0xFFE8F0F3);
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.success, required this.warning});
  final Color success;
  final Color warning;

  @override
  AppColors copyWith({Color? success, Color? warning}) =>
      AppColors(success: success ?? this.success, warning: warning ?? this.warning);

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

class TroveyTheme {
  static const sans = 'Atkinson Hyperlegible';
  static const monoFamily = 'Atkinson Hyperlegible';

  static TextTheme _text(ColorScheme scheme) {
    TextStyle role(double size, FontWeight weight, double height) {
      return GoogleFonts.atkinsonHyperlegible(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: scheme.onSurface,
      );
    }

    return TextTheme(
      displaySmall: role(30, FontWeight.w700, 1.2),
      headlineMedium: role(24, FontWeight.w700, 1.25),
      headlineSmall: role(20, FontWeight.w700, 1.25),
      titleLarge: role(18, FontWeight.w700, 1.25),
      titleMedium: role(16, FontWeight.w700, 1.35),
      bodyLarge: role(16, FontWeight.w400, 1.5),
      bodyMedium: role(14, FontWeight.w400, 1.45),
      labelLarge: role(16, FontWeight.w700, 1.25),
      labelMedium: role(12, FontWeight.w600, 1.35),
    );
  }

  static ThemeData paper() => _build(
        ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.light,
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        ).copyWith(
          surface: const Color(0xFFF4F7F8),
          onSurface: TroveyColors.ink,
          onSurfaceVariant: TroveyColors.muted,
          outlineVariant: TroveyColors.line,
        ),
        const AppColors(success: TroveyColors.cleared, warning: TroveyColors.dawn),
      );

  static ThemeData night() => _build(
        ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        ).copyWith(
          surface: TroveyColors.nightBg,
          onSurface: TroveyColors.nightInk,
        ),
        const AppColors(success: Color(0xFF5EEAD4), warning: Color(0xFFFBBF24)),
      );

  static ThemeData _build(ColorScheme scheme, AppColors extras) {
    final text = _text(scheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      extensions: [extras],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: TroveyRadii.card,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: TroveyRadii.card)),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: TroveyRadii.card)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      ),
      chipTheme: ChipThemeData(
        selectedColor: scheme.secondaryContainer,
        backgroundColor: scheme.surfaceContainerLowest,
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: TroveyRadii.card, borderSide: BorderSide(color: scheme.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: TroveyRadii.card, borderSide: BorderSide(color: scheme.outlineVariant)),
        focusedBorder: OutlineInputBorder(
          borderRadius: TroveyRadii.card,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: TroveyRadii.card,
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: TroveyRadii.card),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
    );
  }

  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double letterSpacing = 0.2,
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
