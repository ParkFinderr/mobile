import 'package:flutter/material.dart';
import '../styles/app_colors.dart';

class SettingsRowItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  const SettingsRowItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);
    final borderColor = AppColors.getBorderColor(context);
    final cardBg2 = AppColors.getCardBg2(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: borderColor)),
          color: cardBg2,
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF1D4ED8), size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: textSecondary, size: 14),
          ],
        ),
      ),
    );
  }
}
