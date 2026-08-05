import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_front/core/routes/app_routes.dart';
import '../styles/app_colors.dart';
import '../styles/theme_provider.dart';
import 'package:mobile_front/features/notification/services/notification_service.dart';
import 'package:mobile_front/features/notification/models/notification_item.dart';

/// Widget shared: Header halaman dengan avatar (ketuk untuk ke profil),
/// judul, tombol sakelar Tema (Light/Dark Mode), dan modal notifikasi.
class UserHeaderWidget extends StatelessWidget {
  final String name;
  final String greeting;
  final String? photoUrl;
  final String title;
  final VoidCallback? onNotificationTap;

  const UserHeaderWidget({
    super.key,
    required this.name,
    required this.greeting,
    this.title = 'Beranda',
    this.photoUrl,
    this.onNotificationTap,
  });

  void _showNotificationsDialog(BuildContext context) {
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Realtime',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            FutureBuilder<List<NotificationItem>>(
              future: NotificationService().getNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                }

                final notifs = snapshot.data ?? [];
                if (notifs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Tidak ada notifikasi baru.',
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notifs.length > 5 ? 5 : notifs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final item = notifs[idx];
                    return _buildNotifItem(
                      icon: item.icon,
                      iconColor: item.iconColor,
                      title: item.title,
                      subtitle: item.subtitle,
                      time: item.time,
                      isDark: isDark,
                      cardBg2: cardBg2,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),

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
                  'Tutup',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isDark,
    required Color cardBg2,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCardBg(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);
    final borderColor = AppColors.getBorderColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          // Avatar (Clicking navigates to Profile)
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.profil);
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardBg2Dark : const Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              child: photoUrl != null && photoUrl!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: photoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF2563EB),
                          size: 24,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Title / Name & Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isNotEmpty ? title : name,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (greeting.isNotEmpty)
                  Text(
                    greeting,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          // Theme Toggle Icon
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: isDark ? Colors.amber : const Color(0xFF2563EB),
              size: 22,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme(!isDark);
            },
            tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
          ),

          // Notification Bell Icon (Opens Notifications Modal)
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF2563EB),
              size: 24,
            ),
            onPressed: onNotificationTap ?? () => _showNotificationsDialog(context),
            tooltip: 'Notifikasi',
          ),
        ],
      ),
    );
  }
}
