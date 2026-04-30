import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget feature-specific: Avatar profil besar dengan border accent
/// dan efek glow shadow.
///
/// Hanya digunakan di: ProfilWidget.
class ProfileAvatarWidget extends StatelessWidget {
  final double size;

  const ProfileAvatarWidget({super.key, this.size = 100});

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
      child: Icon(Icons.person, color: Colors.white70, size: size * 0.6),
    );
  }
}
