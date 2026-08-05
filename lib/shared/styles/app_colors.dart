import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const Color primaryLight = Color(0xFF061E3D);
  static const Color accentLight = Color(0xFF2563EB);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color cardBgLight = Colors.white;
  static const Color cardBg2Light = Color(0xFFF1F5F9);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color borderColorLight = Color(0xFFE2E8F0);
  static const Color navBarLight = Color(0xFFF8FAFC);

  // Dark Mode Colors
  static const Color primaryDark = Color(0xFF070E1A);
  static const Color accentDark = Color(0xFF3B82F6);
  static const Color backgroundDark = Color(0xFF070E1A);
  static const Color surfaceDark = Color(0xFF0F203C);
  static const Color cardBgDark = Color(0xFF0F203C);
  static const Color cardBg2Dark = Color(0xFF162B4D);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color borderColorDark = Color(0xFF1E3A5F);
  static const Color navBarDark = Color(0xFF0F203C);

  // Constant Brand & Accent Colors
  static const Color brandNavy = Color(0xFF061E3D);
  static const Color orange = Color(0xFFF97316);
  static const Color orangeDark = Color(0xFFC2410C);
  static const Color green = Color(0xFF10B981);
  static const Color greenLight = Color(0xFFD1FAE5);
  static const Color red = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFFEE2E2);
  static const Color yellow = Color(0xFFEAB308);

  // Backward compatible static properties (resolving dynamically based on context brightness)
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  static Color getCardBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardBgDark
        : cardBgLight;
  }

  static Color getCardBg2(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardBg2Dark
        : cardBg2Light;
  }

  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimaryLight;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondaryDark
        : textSecondaryLight;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? borderColorDark
        : borderColorLight;
  }

  // Static constants for fallback
  static const Color primary = primaryLight;
  static const Color accent = accentLight;
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color cardBg = cardBgLight;
  static const Color cardBg2 = cardBg2Light;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textMuted = textMutedLight;
  static const Color borderColor = borderColorLight;
  static const Color navBar = navBarLight;
}
