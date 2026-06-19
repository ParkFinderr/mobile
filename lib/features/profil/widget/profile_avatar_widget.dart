import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';

/// Widget feature-specific: Avatar profil besar dengan border accent
/// dan efek glow shadow.
///
/// Hanya digunakan di: ProfilWidget.
class ProfileAvatarWidget extends StatelessWidget {
  final double size;
  final String? photoUrl;

  const ProfileAvatarWidget({super.key, this.size = 100, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cardBg2,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
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
                      color: AppColors.accent,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.person, color: Colors.white70, size: size * 0.6),
              ),
            )
          : Icon(Icons.person, color: Colors.white70, size: size * 0.6),
    );
  }
}
