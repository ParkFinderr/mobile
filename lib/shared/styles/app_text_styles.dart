import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryLight,
    letterSpacing: 0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondaryLight,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondaryLight,
  );

  static const TextStyle accentText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.accentLight,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
  );
}
