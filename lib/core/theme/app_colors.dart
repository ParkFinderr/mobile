import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color background = Color(0xFF0D1628);
  static const Color backgroundLight = Color(0xFFF0F4F8);

  // Card backgrounds
  static const Color cardBg = Color(0xFF132136);
  static const Color cardBg2 = Color(0xFF1A2D47);

  // Accent / Cyan
  static const Color accent = Color(0xFF00D2FF);
  static const Color accentDark = Color(0xFF0088AA);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8BA3BC);
  static const Color textMuted = Color(0xFF4A6080);

  // Status colors
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFEF5350);
  static const Color orange = Color(0xFFFFA726);
  static const Color yellow = Color(0xFFFFEB3B);

  // Navigation
  static const Color navBar = Color(0xFF0D1E35);
  static const Color navBarLight = Color(0xFF1A2D47);

  // Border
  static const Color borderColor = Color(0xFF1E3A5F);
  static const Color borderAccent = Color(0xFF00D2FF);

  // Gradient
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D2FF), Color(0xFF0066AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0D1628), Color(0xFF132136)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient welcomeGradient = LinearGradient(
    colors: [Color(0xFF1A3A6B), Color(0xFF0D1628)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
