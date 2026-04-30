import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget feature-specific: Teks informasi per step tutorial scan
/// (judul langkah & deskripsi).
///
/// Hanya digunakan di: AnimasiScanPage.
class ScanStepInfoWidget extends StatelessWidget {
  final String title;
  final String description;

  const ScanStepInfoWidget({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
