import 'package:flutter/material.dart';
import '../styles/app_colors.dart';

/// Widget shared: Tombol melayang (Floating Action Button) di pojok kanan bawah
/// bertanda logo "?" yang menampilkan modal tutorial cara penggunaan aplikasi.
class FloatingTutorialWidget extends StatelessWidget {
  const FloatingTutorialWidget({super.key});

  static void showTutorialModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCardBg(context);
    final cardBg2 = AppColors.getCardBg2(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF97316),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panduan Penggunaan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'Cara mudah menggunakan ParkFinder FT Unila',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tutorial Steps
            _buildStepItem(
              number: '1',
              title: 'Scan Tiket Masuk',
              description: 'Ambil tiket di gerbang masuk, lalu scan barcode tiket melalui tombol Scan.',
              icon: Icons.qr_code_scanner_rounded,
              iconColor: const Color(0xFF2563EB),
              isDark: isDark,
              cardBg2: cardBg2,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 10),

            _buildStepItem(
              number: '2',
              title: 'Pilih Area & Slot Parkir',
              description: 'Pilih gedung parkir dan tentukan slot berwarna Hijau (Tersedia).',
              icon: Icons.local_parking_rounded,
              iconColor: const Color(0xFF10B981),
              isDark: isDark,
              cardBg2: cardBg2,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 10),

            _buildStepItem(
              number: '3',
              title: 'Konfirmasi Reservasi',
              description: 'Konfirmasikan reservasi slot pilihan Anda pada popup konfirmasi.',
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFFF97316),
              isDark: isDark,
              cardBg2: cardBg2,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 10),

            _buildStepItem(
              number: '4',
              title: 'Tiba di Tempat Parkir',
              description: 'Ikuti denah rute, lalu tekan tombol "Saya Sudah Sampai" untuk mulai parkir.',
              icon: Icons.navigation_rounded,
              iconColor: const Color(0xFF8B5CF6),
              isDark: isDark,
              cardBg2: cardBg2,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 20),

            // Button Mengerti
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF1E3A5F) : const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Saya Mengerti',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStepItem({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required Color cardBg2,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
