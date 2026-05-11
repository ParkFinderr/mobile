import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

const String _cdn = 'https://storage.googleapis.com/parkfinderbucket';

/// Hero banner di halaman Home:
/// - Background foto gedung parkir dari CDN
/// - Mobil McLaren di kanan atas sebagai overlay
class HeroBannerWidget extends StatelessWidget {
  const HeroBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 168,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF0A1828),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Layer 1: Foto background gedung parkir ──────────
            Image.network(
              '$_cdn/background/bg-home.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A3A5C), Color(0xFF0D1628)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // ── Layer 2: Gradient overlay bawah supaya teks terbaca ──
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.35),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // ── Layer 3: Mobil McLaren ───────────────────────────
            Positioned(
              right: -10,
              bottom: -8,
              child: Image.network(
                '$_cdn/foto/mclaren-depan.png',
                height: 155,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.directions_car_filled,
                  color: Colors.white38,
                  size: 90,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
