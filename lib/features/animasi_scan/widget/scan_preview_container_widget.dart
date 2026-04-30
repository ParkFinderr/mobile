import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'scan_preview_content_widget.dart';

/// Widget feature-specific: Container area preview scan dengan border accent,
/// clip rounded, dan animasi arrow hint pada step pertama.
///
/// Hanya digunakan di: AnimasiScanPage.
class ScanPreviewContainerWidget extends StatelessWidget {
  final Animation<double> scanAnimation;
  final int currentStep;

  const ScanPreviewContainerWidget({
    super.key,
    required this.scanAnimation,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Konten mock UI preview
            const ScanPreviewContentWidget(),
            // Animated arrow hint (hanya muncul di step 0)
            AnimatedBuilder(
              animation: scanAnimation,
              builder: (context, _) {
                if (currentStep == 0) {
                  return Positioned(
                    top: 60 + scanAnimation.value * 10,
                    left: 16,
                    child: const Icon(
                      Icons.arrow_forward,
                      color: AppColors.accent,
                      size: 28,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
