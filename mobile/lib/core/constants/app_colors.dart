import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Pastel Minimalist Palette
  static const Color primary = Color(0xFFA1E3A1); // Soft pastel green
  static const Color primaryLight = Color(0xFFC7F0C7);
  static const Color primaryDark = Color(0xFF7BCC7B);
  static const Color accent = Color(0xFFFEF0BB); // Soft yellow

  static const Color riskLow = Color(0xFFA1E3A1);
  static const Color riskMedium = Color(0xFFFEF0BB);
  static const Color riskHigh = Color(0xFFFAD1D1);

  // 5-level risk colors (Softened)
  static const Color riskVeryLow = Color(0xFFA1E3A1);      // Soft Green
  static const Color riskLowYellow = Color(0xFFE8E9A1);    // Light Yellow-Green
  static const Color riskMediumOrange = Color(0xFFFEF0BB); // Soft Yellow
  static const Color riskHighRed = Color(0xFFFAD1D1);      // Soft Pink
  static const Color riskVeryHigh = Color(0xFFF4A8A8);     // Soft Red

  static const Color bgLight = Color(0xFFFAFAFA); // Almost white
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B); // Dark slate
  static const Color textSecondary = Color(0xFF64748B); // Slate
  static const Color textHint = Color(0xFF94A3B8);
  static const Color divider = Color(0xFFF1F5F9);
  
  static const Color error = Color(0xFFF4A8A8);
  static const Color success = Color(0xFFA1E3A1);
  static const Color warning = Color(0xFFFEF0BB);

  // Additional Pastel Card Colors
  static const Color cardBlue = Color(0xFFC6EDF4);
  static const Color cardYellow = Color(0xFFFEF0BB);
  static const Color cardPink = Color(0xFFFAD1D1);

  static Color getRiskColor(String level) {
    switch (level) {
      case 'sangat_rendah':
        return riskVeryLow;
      case 'rendah':
        return riskLowYellow;
      case 'sedang':
        return riskMediumOrange;
      case 'tinggi':
        return riskHighRed;
      case 'sangat_tinggi':
        return riskVeryHigh;
      default:
        return textSecondary;
    }
  }
}
