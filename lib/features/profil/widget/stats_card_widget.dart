import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget feature-specific: Card statistik profil
/// menampilkan total parkir dan parkir aktif secara berdampingan.
///
/// Hanya digunakan di: ProfilWidget.
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(value: totalParkir, label: 'Total Parkir'),
            Container(
                width: 1, height: 40, color: AppColors.borderColor),
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
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
