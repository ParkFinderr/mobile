import 'package:flutter/material.dart';
import '../styles/app_colors.dart';

/// ConfirmationDialog — Dialog konfirmasi reusable dengan tema terpusat (Light/Dark).
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color? confirmColor;
  final bool isDangerous;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Ya',
    this.cancelLabel = 'Batal',
    this.confirmColor,
    this.isDangerous = false,
  });

  /// Tampilkan dialog dan kembalikan true jika dikonfirmasi, false jika dibatalkan.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Ya',
    String cancelLabel = 'Batal',
    bool isDangerous = false,
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDangerous: isDangerous,
        confirmColor: confirmColor,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.getCardBg(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    final effectiveConfirmColor =
        confirmColor ?? (isDangerous ? const Color(0xFFEF4444) : const Color(0xFF2563EB));

    return AlertDialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        title,
        style: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(color: textSecondary, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelLabel,
            style: TextStyle(color: textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveConfirmColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            confirmLabel,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
