import 'package:flutter/material.dart';

/// Centralized color palette derived from the Figma design.
class AppColors {
  AppColors._();

  // Background Colors
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundOffWhite = Color(0xFFF7F9FB);
  
  // Card & Container Colors
  static const Color totalBalanceCardBg = Color(0xFF131B2E);
  static const Color cardStroke = Color(0xFFF1F5F9);
  
  // Quick Action Button Colors
  static const Color actionFundBg = Color(0xFF6CF8BB);
  static const Color actionPayBg = Color(0xFFD8E2FF);
  static const Color actionSwapBg = Color(0xFFDAE2FD);

  // Status & Highlight Colors
  static const Color successGreen = Color(0xFF006C49);
  static const Color successGreenLight = Color(0xFF6FFBBE); // Used for +2.4%
  static const Color successOverlay = Color(0x33006C49); // 0.2 opacity of successGreen
  
  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF7C839B);
  static const Color textDark = Color(0xFF191C1E);
  static const Color textHeading = Color(0xFF0F172A);
}
