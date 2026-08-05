import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// EmptyStateWidget — Tampilan saat data kosong.
///
/// Digunakan ketika list kosong, history kosong, dsb.
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData icon;
  final VoidCallback? onRetry;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.subMessage,
    this.icon = Icons.inbox_outlined,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textMuted, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                subMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ErrorStateWidget — Tampilan saat terjadi error.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
