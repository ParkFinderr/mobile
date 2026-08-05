import 'package:flutter/material.dart';
import '../../../shared/styles/app_colors.dart';

class StatsCardWidget extends StatelessWidget {
  final String totalParkir;
  final String parkirAktif;

  const StatsCardWidget({
    super.key,
    required this.totalParkir,
    required this.parkirAktif,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCardBg(context);
    final borderColor = AppColors.getBorderColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(value: totalParkir, label: 'Total Parkir'),
            Container(width: 1, height: 44, color: borderColor),
            _StatItem(value: parkirAktif, label: 'Parkir Aktif'),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final textSecondary = AppColors.getTextSecondary(context);

    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF2563EB),
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
