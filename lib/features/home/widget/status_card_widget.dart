import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget feature-specific: Card status (tiket aktif, booking menunggu,
/// parkir aktif) di halaman Home. Mendukung action buttons opsional.
///
/// Hanya digunakan di: HomeWidget (melalui StatusCardsRowWidget).
class StatusCardWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String subtitle;
  final double width;
  final List<Widget>? actions;

  const StatusCardWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.subtitle,
    required this.width,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Icon(icon, color: iconColor, size: 36),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 10),
          ),
          if (actions != null) ...[
            const SizedBox(height: 8),
            Row(children: actions!),
          ],
        ],
      ),
    );
  }
}

/// Widget teks aksi kecil di dalam StatusCardWidget (contoh: "Lihat Detail").
class CardActionTextWidget extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const CardActionTextWidget({
    super.key,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(
          label,
          style: TextStyle(
            color: isDestructive ? AppColors.red : AppColors.accent,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
