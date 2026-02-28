import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Thème de l'application TCG Matchmaker
/// Basé sur les couleurs du logo : bleu foncé + violet/lavande + blanc
class AppTheme {
  AppTheme._();

  // ==========================================================================
  // COULEURS DU LOGO
  // ==========================================================================
  static const Color _darkBackground = Color(0xFF1A1A2E);
  static const Color _darkSurface = Color(0xFF232340);
  static const Color _purple = Color(0xFF8B7EC8);
  static const Color _purpleLight = Color(0xFFB8ACE6);
  static const Color _purpleDark = Color(0xFF5E5791);

  // ==========================================================================
  // COULEURS DES STATUTS DE PARTIES
  // ==========================================================================
  static const Color statusOpen = Color(0xFF4CAF50); // Vert
  static const Color statusFull = Color(0xFFFF9800); // Orange
  static const Color statusInProgress = _purple; // Violet (primary)
  static const Color statusFinished = Color(0xFF9E9E9E); // Gris
  static const Color statusCancelled = Color(0xFFF44336); // Rouge

  // ==========================================================================
  // COULEURS DES CARTES DE PARTIES
  // ==========================================================================
  static const Color gameCardColor1 = Color(0xFF2A2D4E); // Bleu-gris foncé
  static const Color gameCardColor2 = Color(0xFF1E3A3A); // Teal foncé
  static const Color gameCardHighlight1 = Color(0xFF3D4070);
  static const Color gameCardHighlight2 = Color(0xFF2A4F4F);

  // ==========================================================================
  // DARK THEME (Principal - correspond au logo)
  // ==========================================================================
  static const _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    // Primary - Violet/Lavande
    primary: _purple,
    onPrimary: Colors.white,
    primaryContainer: _purpleDark,
    onPrimaryContainer: _purpleLight,
    // Secondary
    secondary: _purpleLight,
    onSecondary: _darkBackground,
    secondaryContainer: Color(0xFF3D3D5C),
    onSecondaryContainer: _purpleLight,
    // Tertiary
    tertiary: Color(0xFFE0B8D0),
    onTertiary: Color(0xFF3E2A36),
    tertiaryContainer: Color(0xFF57404C),
    onTertiaryContainer: Color(0xFFFFD8E8),
    // Error
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    // Background & Surface - Bleu très foncé
    surface: _darkSurface,
    onSurface: Colors.white,
    surfaceContainerHighest: Color(0xFF2D2D4A),
    onSurfaceVariant: Color(0xFFCAC4D0),
    // Outline
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
    // Inverse
    inverseSurface: Color(0xFFE6E1E5),
    onInverseSurface: Color(0xFF1C1B1F),
    inversePrimary: _purpleDark,
    // Scrim
    scrim: Colors.black,
  );

  // ==========================================================================
  // LIGHT THEME (Alternative)
  // ==========================================================================
  static const _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: _purpleDark,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE8DEFF),
    onPrimaryContainer: _purpleDark,
    secondary: Color(0xFF625B71),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE8DEF8),
    onSecondaryContainer: Color(0xFF1E192B),
    tertiary: Color(0xFF7D5260),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFD8E4),
    onTertiaryContainer: Color(0xFF31101D),
    error: Color(0xFFB3261E),
    onError: Colors.white,
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: Color(0xFFFFFBFE),
    onSurface: Color(0xFF1C1B1F),
    surfaceContainerHighest: Color(0xFFE7E0EC),
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: _purpleLight,
    scrim: Colors.black,
  );

  // ==========================================================================
  // TYPOGRAPHY - Ranchers (display) + Poppins (body)
  // ==========================================================================
  static TextStyle get _displayFont => GoogleFonts.ranchers();
  static TextStyle get _bodyFont => GoogleFonts.poppins();

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: _displayFont.copyWith(fontSize: 57, color: textColor),
      displayMedium: _displayFont.copyWith(fontSize: 45, color: textColor),
      displaySmall: _displayFont.copyWith(fontSize: 36, color: textColor),
      headlineLarge: _displayFont.copyWith(fontSize: 32, color: textColor),
      headlineMedium: _displayFont.copyWith(fontSize: 28, color: textColor),
      headlineSmall: _displayFont.copyWith(fontSize: 24, color: textColor),
      titleLarge: _displayFont.copyWith(fontSize: 22, color: textColor),
      titleMedium: _bodyFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: _bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: _bodyFont.copyWith(fontSize: 16, color: textColor),
      bodyMedium: _bodyFont.copyWith(fontSize: 14, color: textColor),
      bodySmall: _bodyFont.copyWith(fontSize: 12, color: textColor),
      labelLarge: _bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: _bodyFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: _bodyFont.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }

  // ==========================================================================
  // THEME DATA
  // ==========================================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: _lightColorScheme.surface,
      textTheme: _buildTextTheme(_lightColorScheme.onSurface),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _lightColorScheme.surface,
        foregroundColor: _lightColorScheme.onSurface,
        titleTextStyle: _displayFont.copyWith(
          fontSize: 22,
          color: _lightColorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _lightColorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightColorScheme.primary,
          foregroundColor: _lightColorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      iconTheme: IconThemeData(color: _lightColorScheme.onSurface),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: _darkBackground,
      textTheme: _buildTextTheme(_darkColorScheme.onSurface),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _darkBackground,
        foregroundColor: _darkColorScheme.onSurface,
        titleTextStyle: _displayFont.copyWith(
          fontSize: 22,
          color: _darkColorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkColorScheme.primary,
          foregroundColor: _darkColorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      iconTheme: IconThemeData(color: _darkColorScheme.onSurface),
    );
  }
}
