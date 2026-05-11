import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

const String _cdn = 'https://storage.googleapis.com/parkfinderbucket';

/// Enum gambar untuk setiap status card
enum StatusCardImage { tiket, waiting, car }

/// Widget feature-specific: Card status (tiket aktif, booking menunggu,
/// parkir aktif) di halaman Home. Menggunakan gambar dari CDN.
///
/// Hanya digunakan di: HomeWidget (melalui _buildStatusCards)
class StatusCardWidget extends StatelessWidget {
  final String title;
  final StatusCardImage cardImage;
  final String subtitle;
  final double width;
  final List<Widget>? actions;

  const StatusCardWidget({
    super.key,
    required this.title,
    required this.cardImage,
    required this.subtitle,
    required this.width,
    this.actions,
  });

  String get _imageUrl {
    switch (cardImage) {
      case StatusCardImage.tiket:
        return '$_cdn/foto/tiket.png';
      case StatusCardImage.waiting:
        return '$_cdn/foto/wait.png';
      case StatusCardImage.car:
        return '$_cdn/foto/yellow-mobil.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),

          // Gambar dari CDN
          SizedBox(
            height: 48,
            child: Image.network(
              _imageUrl,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              errorBuilder: (_, __, ___) => Icon(
                Icons.image_not_supported,
                color: Colors.white24,
                size: 36,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              height: 1.4,
            ),
          ),

          if (actions != null) ...[
            const SizedBox(height: 8),
            Row(children: actions!),
          ],
        ],
      ),
    );
  }
}

/// Widget teks aksi kecil di dalam StatusCardWidget (contoh: "Lihat Detail").
class CardActionTextWidget extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const CardActionTextWidget({
    super.key,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(
          label,
          style: TextStyle(
            color: isDestructive ? AppColors.red : AppColors.accent,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
