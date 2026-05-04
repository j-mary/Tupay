import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized ThemeData for the application.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final textTheme = _publicSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundOffWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.totalBalanceCardBg,
        onPrimary: AppColors.textWhite,
        secondary: AppColors.actionFundBg,
        onSecondary: AppColors.textDark,
        surface: AppColors.backgroundWhite,
        onSurface: AppColors.textDark,
        error: AppColors.error,
        onError: AppColors.textWhite,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: _publicSans(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: AppColors.textWhite,
          letterSpacing: -0.9,
        ),
        displayMedium: _publicSans(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: AppColors.textWhite,
        ),
        titleLarge: _publicSans(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.textHeading,
        ),
        bodyLarge: _publicSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
        ),
        bodyMedium: _publicSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textGrey,
        ),
        labelMedium: _publicSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        labelSmall: _publicSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.successGreenLight,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundOffWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textHeading,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.totalBalanceCardBg,
          foregroundColor: AppColors.textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.backgroundWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cardStroke),
        ),
      ),
    );
  }

  static TextTheme _publicSansTextTheme() {
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return ThemeData.light().textTheme;
    }
    return GoogleFonts.publicSansTextTheme();
  }

  static TextStyle _publicSans({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
  }) {
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );
    }
    return GoogleFonts.publicSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
