import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget shared: Baris pengaturan dengan icon, judul, subjudul, dan tanda panah.
/// Mendukung styling untuk item terakhir (tanpa border bawah).
///
/// Digunakan di: ProfilWidget (Edit Profil, Preferensi).
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.borderColor)),
          color: AppColors.cardBg2.withOpacity(0.5),
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
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,
                color: AppColors.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }
}
