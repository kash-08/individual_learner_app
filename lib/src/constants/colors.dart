import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4361EE);
  static const Color secondary = Color(0xFF3A0CA3);
  static const Color accent = Color(0xFF7209B7);
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color success = Color(0xFF4CC9F0);
  static const Color warning = Color(0xFFF72585);
  static const Color progressBackground = Color(0xFFE9ECEF);

  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}