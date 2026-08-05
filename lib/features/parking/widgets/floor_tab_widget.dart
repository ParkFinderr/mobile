import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget feature-specific: Pill tab filter lantai
/// (Semua / Lantai 1 / Lantai 2, dst).
///
/// Hanya digunakan di: DetailBookingWidget.
class FloorTabWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FloorTabWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
