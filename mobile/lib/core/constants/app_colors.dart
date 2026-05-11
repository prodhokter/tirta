import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accent = Color(0xFFFFC107);

  static const Color riskLow = Color(0xFF2E7D32);
  static const Color riskMedium = Color(0xFFF57C00);
  static const Color riskHigh = Color(0xFFB71C1C);

  static const Color bgLight = Color(0xFFF5F7FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);

  static Color getRiskColor(String level) {
    switch (level) {
      case 'rendah':
        return riskLow;
      case 'sedang':
        return riskMedium;
      case 'tinggi':
        return riskHigh;
      default:
        return textSecondary;
    }
  }
}
