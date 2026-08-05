import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/styles/app_colors.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final double size;
  final String? photoUrl;

  const ProfileAvatarWidget({super.key, this.size = 100, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg2 = AppColors.getCardBg2(context);
    final textSecondary = AppColors.getTextSecondary(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cardBg2,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2563EB), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.3 : 0.15),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.person_rounded, color: textSecondary, size: size * 0.6),
              ),
            )
          : Icon(Icons.person_rounded, color: const Color(0xFF2563EB), size: size * 0.6),
    );
  }
}
