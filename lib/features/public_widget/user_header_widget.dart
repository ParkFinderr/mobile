import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget shared: Header halaman dengan avatar, nama user, greeting,
/// dan tombol notifikasi.
///
/// Digunakan di: HomeWidget, HistoryWidget.
class UserHeaderWidget extends StatelessWidget {
  final String name;
  final String greeting;
  final VoidCallback? onNotificationTap;

  const UserHeaderWidget({
    super.key,
    required this.name,
    required this.greeting,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.cardBg2,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: const Icon(Icons.person, color: Colors.white70, size: 28),
          ),
          const SizedBox(width: 12),
          // Nama & Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                greeting,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          // Tombol Notifikasi
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: Colors.white70, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
