import 'package:flutter/material.dart';

/// Reference palette (screenshot spec): deep blue, off-white canvas, green / orange / red accents.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1E56A0);
  static const Color primaryDark = Color(0xFF153D75);
  static const Color primaryLight = Color(0xFFE8EEF5);

  static const Color secondary = Color(0xFF6825EA);
  static const Color accent = Color(0xFFEC24ED);

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF0288D1);
  static const Color pending = Color(0xFFFF9800);

  static const Color leaveAccent = Color(0xFFFFC107);
  static const Color expenseAccent = Color(0xFFE53935);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);

  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  static const Color fieldFill = Color(0xFFF0F2F5);
  static const Color segmentTrack = Color(0xFFE8ECF2);

  static const Color iconBox1 = Color(0xFF6825EA);
  static const Color iconBox2 = Color(0xFF1E56A0);
  static const Color iconBox3 = Color(0xFFEC24ED);
  static const Color iconBox4 = Color(0xFFAD27EA);

  /// Dashboard reference (second screenshot): header, clock card, clock-in CTA.
  static const Color dashboardHeaderBlue = Color(0xFF1E5FA9);
  static const Color dashboardClockCardBlue = Color(0xFF3B69A5);
  static const Color dashboardClockInGreen = Color(0xFF5CB85C);
  static const Color dashboardQuickLeaveOrange = Color(0xFFFF9800);
  static const Color dashboardQuickExpenseCoral = Color(0xFFFF7043);

  static const Color navBadge = Color(0xFFE53935);
}
