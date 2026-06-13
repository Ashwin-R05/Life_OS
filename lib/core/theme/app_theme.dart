import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Theme Accent Colors
  static const Color darkBackground = Color(0xFF090D16);
  static const Color darkCardBackground = Color(0x0FFFFFFF);
  static const Color darkBorderColor = Color(0x1BFFFFFF);
  static const Color darkPrimaryGlow = Color(0xFF00FFF0); // Neon Cyan
  static const Color darkSecondaryGlow = Color(0xFFBD00FF); // Neon Purple

  static const Color lightBackground = Color(0xFFF4F7FB);
  static const Color lightCardBackground = Color(0x66FFFFFF);
  static const Color lightBorderColor = Color(0x33000000);
  static const Color lightPrimaryGlow = Color(0xFF007A87); // Deep Cyan
  static const Color lightSecondaryGlow = Color(0xFF7B0099); // Deep Purple

  // Background Mesh Blob Colors
  static const List<Color> darkBlobColors = [
    Color(0x3C00FFF0), // Semi-transparent Neon Cyan
    Color(0x28BD00FF), // Semi-transparent Neon Purple
    Color(0x1E002BFF), // Deep Blue
  ];

  static const List<Color> lightBlobColors = [
    Color(0x2800D1FF),
    Color(0x1CFF00E5),
    Color(0x147700FF),
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimaryGlow,
        secondary: darkSecondaryGlow,
        surface: Color(0xFF0F172A),
        onPrimary: Colors.black,
        onSecondary: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.9),
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkPrimaryGlow, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: lightPrimaryGlow,
        secondary: lightSecondaryGlow,
        surface: Color(0xFFFFFFFF),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: Colors.black,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black.withValues(alpha: 0.9),
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black.withValues(alpha: 0.7),
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black.withValues(alpha: 0.6),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightPrimaryGlow, width: 1.5),
        ),
      ),
    );
  }
}
