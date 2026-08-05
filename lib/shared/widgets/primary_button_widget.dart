import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget shared: Tombol utama full-width dengan border accent.
///
/// Digunakan di: AnimasiScanWidget (Selanjutnya/Mulai Scan).
class PrimaryButtonWidget extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double height;

  const PrimaryButtonWidget({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: AppColors.accent),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
