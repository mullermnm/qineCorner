import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.accentMint,
      scaffoldBackgroundColor: AppColors.lightBackground,
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      ),

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentMint,
        secondary: AppColors.accentMint,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurfaceBackground,
        onBackground: AppColors.lightTextPrimary,
        onSurface: AppColors.lightTextPrimary,
        onPrimary: AppColors.lightBackground,
      ),

      // Text Theme
      textTheme: AppTypography.getTextTheme(false),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        color: AppColors.lightBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.accentMint,
      scaffoldBackgroundColor: AppColors.darkBackground,
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentMint,
        secondary: AppColors.accentMint,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurfaceBackground,
        onBackground: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
        onPrimary: AppColors.darkBackground,
      ),

      // Text Theme
      textTheme: AppTypography.getTextTheme(true),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        color: AppColors.darkBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
