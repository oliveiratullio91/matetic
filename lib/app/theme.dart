import 'package:flutter/material.dart';

class ThemePalette {
  const ThemePalette({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.canvas,
    required this.surface,
    required this.text,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
  final Color canvas;
  final Color surface;
  final Color text;
}

ThemeData buildMateticTheme({
  required String themeId,
  required bool highContrast,
}) {
  final palette = _paletteForThemeId(themeId, highContrast: highContrast);
  final primary = palette.primary;
  final secondary = palette.secondary;
  final accent = palette.accent;
  final canvas = palette.canvas;
  final surface = palette.surface;
  final text = palette.text;

  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    primary: primary,
    secondary: secondary,
    surface: surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: canvas,
    textTheme: TextTheme(
      displayLarge: TextStyle(color: text, fontWeight: FontWeight.w800),
      displayMedium: TextStyle(color: text, fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(color: text, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(color: text, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: text, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: text, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: text, height: 1.45),
      bodyMedium: TextStyle(color: text, height: 1.45),
      labelLarge: TextStyle(color: text, fontWeight: FontWeight.w700),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: text,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: primary.withValues(alpha: 0.08)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        minimumSize: const Size.fromHeight(56),
        side: BorderSide(color: primary.withValues(alpha: 0.18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primary.withValues(alpha: 0.08),
      selectedColor: accent.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      labelStyle: TextStyle(color: text, fontWeight: FontWeight.w600),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: primary.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: primary.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: primary, width: 1.4),
      ),
    ),
  );
}

ThemePalette _paletteForThemeId(String themeId, {required bool highContrast}) {
  if (highContrast) {
    return const ThemePalette(
      primary: Color(0xFF0F172A),
      secondary: Color(0xFFFFB703),
      accent: Color(0xFF00D084),
      canvas: Color(0xFFF8FAFC),
      surface: Colors.white,
      text: Color(0xFF020617),
    );
  }

  return switch (themeId) {
    'theme_sunset' => const ThemePalette(
        primary: Color(0xFFFF7B54),
        secondary: Color(0xFFFFB703),
        accent: Color(0xFF2EC4B6),
        canvas: Color(0xFFFFF7F2),
        surface: Colors.white,
        text: Color(0xFF2D1E1A),
      ),
    'theme_mint' => const ThemePalette(
        primary: Color(0xFF13C4A3),
        secondary: Color(0xFF2D55FF),
        accent: Color(0xFFFFB703),
        canvas: Color(0xFFF1FFFB),
        surface: Colors.white,
        text: Color(0xFF12302A),
      ),
    'theme_cosmic' => const ThemePalette(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFF2D55FF),
        accent: Color(0xFFFFB703),
        canvas: Color(0xFFF6F4FF),
        surface: Colors.white,
        text: Color(0xFF1E1B4B),
      ),
    'theme_lava' => const ThemePalette(
        primary: Color(0xFFEF476F),
        secondary: Color(0xFFFF7B54),
        accent: Color(0xFFFFD166),
        canvas: Color(0xFFFFF4F6),
        surface: Colors.white,
        text: Color(0xFF381922),
      ),
    'theme_comet' => const ThemePalette(
        primary: Color(0xFF8E5CFF),
        secondary: Color(0xFF2D55FF),
        accent: Color(0xFFFFB703),
        canvas: Color(0xFFF7F3FF),
        surface: Colors.white,
        text: Color(0xFF281B45),
      ),
    _ => const ThemePalette(
        primary: Color(0xFF2D55FF),
        secondary: Color(0xFFFFB703),
        accent: Color(0xFF13C4A3),
        canvas: Color(0xFFF5F7FF),
        surface: Colors.white,
        text: Color(0xFF14213D),
      ),
  };
}
