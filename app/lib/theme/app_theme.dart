import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF4CAF50); // Vert
  static const Color secondaryColor = Color(0xFF8BC34A); // Vert clair
  static const Color accentColor = Color(0xFFFFC107); // Jaune
  static const Color errorColor = Color(0xFFF44336); // Rouge
  static const Color backgroundColor = Color(0xFFF5F5F5); // Gris clair
  static const Color surfaceColor = Colors.white;
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF212121);
  static const Color onError = Colors.white;

  // Méthode pour obtenir le thème clair
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        onSurface: onBackground,
        onBackground: onBackground,
        onError: onError,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        titleTextStyle: TextStyle(
          color: onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(color: onPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.bold, color: onBackground),
        displayMedium: TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: onBackground),
        displaySmall: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: onBackground),
        headlineMedium: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: onBackground),
        headlineSmall: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: onBackground),
        titleLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: onBackground),
        bodyLarge: TextStyle(fontSize: 16, color: onSurface),
        bodyMedium: TextStyle(fontSize: 14, color: onSurface),
        bodySmall: TextStyle(fontSize: 12, color: onSurface),
      ),
      fontFamily: 'Poppins',
    );
  }

  // Thème sombre (optionnel)
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      error: errorColor,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: onError,
      brightness: Brightness.dark,
    ),
    // Personnalisations supplémentaires pour le thème sombre
  );
}
