import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme(String languageCode) {
    final isAr = languageCode != 'en';
    
    
    final baseTheme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        background: AppColors.background,
      ),
    );

    
    
    return baseTheme.copyWith(
      textTheme: isAr
          ? GoogleFonts.cairoTextTheme(baseTheme.textTheme)
          : GoogleFonts.interTextTheme(baseTheme.textTheme),
    );
  }
}
