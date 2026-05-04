import 'package:flutter/material.dart';

/// Centralized color palette derived from the Figma design.
class AppColors {
  AppColors._();

  // Background Colors
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundOffWhite = Color(0xFFF7F9FB);
  static const Color transferBackground = Color(0xFFF7F9FB);
  static const Color receiptDark = Color(0xFF131B2E);

  // Card & Container Colors
  static const Color totalBalanceCardBg = Color(0xFF131B2E);
  static const Color cardStroke = Color(0xFFF1F5F9);
  static const Color fieldFill = Color(0xFFF1F5F9);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFC6C6CD);
  static const Color receiptDivider = Color(0xFF3F465C);

  // Quick Action Button Colors
  static const Color actionFundBg = Color(0xFF6CF8BB);
  static const Color actionPayBg = Color(0xFFD8E2FF);
  static const Color actionSwapBg = Color(0xFFDAE2FD);

  // Status & Highlight Colors
  static const Color successPrimary = Color(0xFF006C49);
  static const Color successGreenLight = Color(0xFF6FFBBE);
  static const Color successOverlay = Color(
    0x33006C49,
  ); // 0.2 opacity of successGreen

  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF7C839B);
  static const Color mutedText = Color(0xFF64748B);
  static const Color supportingText = Color(0xFF45464D);
  static const Color iconMuted = Color(0xFF94A3B8);
  static const Color textDark = Color(0xFF191C1E);
  static const Color textHeading = Color(0xFF0F172A);
  static const Color shadow = Color(0x0D000000);
  static const Color error = Color(0xFFFF5252);
}
