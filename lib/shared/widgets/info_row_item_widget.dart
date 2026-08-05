import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget shared: Baris informasi pribadi dengan icon, label, dan nilai.
/// Mendukung styling untuk item terakhir (tanpa border bawah).
///
/// Digunakan di: ProfilWidget (email, nomor telepon, kendaraan).
class InfoRowItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const InfoRowItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.borderColor)),
        color: AppColors.cardBg2.withValues(alpha: 0.5),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(16))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
