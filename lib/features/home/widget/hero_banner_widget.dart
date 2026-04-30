import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget feature-specific: Hero banner gradien di halaman Home
/// dengan ilustrasi gedung parkir dan teks PARKFINDER.
///
/// Hanya digunakan di: HomeWidget.
class HeroBannerWidget extends StatelessWidget {
  const HeroBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A5C), Color(0xFF0D1628)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Row(
          children: [
            // Bagian kiri: label gedung parkir
            Expanded(
              flex: 2,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2C5C8A), Color(0xFF1A3A5C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      color: const Color(0xFF0D1E35),
                      child: const Text(
                        'PARKFINDER 150',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      color: const Color(0xFF0D1E35),
                      child: const Text(
                        'PARKFINDER',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bagian kanan: ilustrasi kendaraan
            Expanded(
              flex: 3,
              child: Container(
                color: const Color(0xFF0A1828),
                child: const Center(
                  child: Icon(Icons.directions_car_filled,
                      color: AppColors.textMuted, size: 80),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
