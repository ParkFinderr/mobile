import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// PrimaryButton — Tombol utama full-width dengan border accent.
///
/// Widget reusable yang digunakan di seluruh aplikasi sebagai CTA utama.
/// Menggantikan `PrimaryButtonWidget` dari features/public_widget/.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double height;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 52,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          disabledBackgroundColor:
              (backgroundColor ?? AppColors.primary).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
