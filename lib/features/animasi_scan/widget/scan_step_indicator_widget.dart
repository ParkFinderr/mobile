import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget feature-specific: Row dots animasi sebagai step indicator.
/// Dot aktif lebih lebar dari dot non-aktif.
///
/// Hanya digunakan di: AnimasiScanPage.
class ScanStepIndicatorWidget extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const ScanStepIndicatorWidget({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalSteps,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == currentStep ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == currentStep
                ? AppColors.accent
                : AppColors.borderColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
