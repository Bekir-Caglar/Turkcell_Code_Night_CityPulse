import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF26377B);
  static const Color primaryYellow = Color(0xFFFFC900);
  static const Color accentBlue = Color(0xFF00A4E4);
  static const Color backgroundColor = Color(0xFFF4F6F8);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color successGreen = Color(0xFF2ECC71);
  static const Color alertRed = Color(0xFFE74C3C);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textOnPrimaryBlue = Color(0xFFFFFFFF);
  static const Color textOnPrimaryYellow = Color(0xFF26377B);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryYellow,
        tertiary: AppColors.accentBlue,
        surface: AppColors.surfaceColor,
        background: AppColors.backgroundColor,
        onPrimary: AppColors.textOnPrimaryBlue,
        onSecondary: AppColors.textOnPrimaryYellow,
        onSurface: AppColors.textPrimary,
        error: AppColors.alertRed,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textOnPrimaryBlue,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textOnPrimaryBlue,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textOnPrimaryBlue,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
