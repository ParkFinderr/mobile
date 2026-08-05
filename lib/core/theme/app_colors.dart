import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color background = Color(0xFFF8FAFF);
  static const Color backgroundLight = Color(0xFFF1F5FF);
  static const Color surface = Colors.white;

  // Card backgrounds
  static const Color cardBg = Colors.white;
  static const Color cardBg2 = Color(0xFFEAF1FF);

  // Accent / Cyan
  static const Color accent = Color(0xFF2563EB);
  static const Color accentDark = Color(0xFF0A438F);
  static const Color primary = Color(0xFF062A58);
  static const Color orange = Color(0xFFFF7A1A);

  // Text
  static const Color textPrimary = Color(0xFF10213B);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textMuted = Color(0xFF98A2B3);

  // Status colors
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFEF5350);
  static const Color orangeWarning = Color(0xFFFFA726);
  static const Color yellow = Color(0xFFFFEB3B);

  // Navigation
  static const Color navBar = Color(0xFFF9FBFF);
  static const Color navBarLight = Color(0xFFEAF1FF);

  // Border
  static const Color borderColor = Color(0xFFE4EAF4);
  static const Color borderAccent = Color(0xFF2563EB);

  // Gradient
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF0A438F), Color(0xFF062A58)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFF8FAFF), Color(0xFFF1F5FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient welcomeGradient = LinearGradient(
    colors: [Color(0xFFF2F6FF), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
