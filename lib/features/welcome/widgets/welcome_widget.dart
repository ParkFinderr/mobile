import 'package:flutter/material.dart';
import 'package:mobile_front/core/routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/styles/app_text_styles.dart';
import '../../../core/config/app_config.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({super.key});

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'ParkFinder FT Unila',
      'subtitle': 'Solusi Pintar Cari & Reservasi Slot Parkir Kampus',
      'description': 'Temukan lokasi parkir yang tersedia secara cepat dan efisien tanpa perlu memutar area kampus.',
      'image': 'lib/assets/welcome/gedung_welcome.png',
      'cdnImage': '${AppConfig.storageUrl}/assets/gedung-wellcome.png',
    },
    {
      'title': 'Denah & Slot Interaktif',
      'subtitle': 'Pilih Slot Sesuai Keinginan Anda',
      'description': 'Lihat ketersediaan slot parkir secara langsung dari peta denah interaktif Fakultas Teknik.',
      'image': 'lib/assets/parking/denah_parkir.png',
      'cdnImage': '${AppConfig.storageUrl}/assets/denah.png',
    },
    {
      'title': 'Scan QR & Status Aktif',
      'subtitle': 'Masuk & Keluar Parkir Lebih Praktis',
      'description': 'Gunakan QR Ticket untuk konfirmasi masuk dan pantau durasi serta status parkir secara realtime.',
      'image': 'lib/assets/home/status_parkir_aktif.png',
      'cdnImage': '${AppConfig.storageUrl}/assets/mobil-tempat-parkir.png',
    },
  ];

  void _onNext() {
    if (_currentIndex < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar (Skip Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.network(
                    '${AppConfig.storageUrl}/logo.png',
                    height: 32,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'lib/assets/logo.png',
                      height: 32,
                      errorBuilder: (_, __, ___) => Text(
                        'PARKFINDER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryLight,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _onSkip,
                    child: Text(
                      'Lewati',
                      style: AppTextStyles.bodySecondary.copyWith(
                        color: AppColors.accentLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image Asset Container
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardBg2Dark : AppColors.cardBg2Light,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                data['cdnImage'] ?? '',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  data['image']!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Icon(
                                      Icons.local_parking_rounded,
                                      size: 100,
                                      color: AppColors.accentLight.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Title & Description
                        Text(
                          data['title']!,
                          style: AppTextStyles.heading1.copyWith(
                            color: isDark ? Colors.white : AppColors.primaryLight,
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['subtitle']!,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: AppColors.accentLight,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data['description']!,
                          style: AppTextStyles.bodySecondary.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Actions (Page Indicators + Next Button)
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding > 0 ? bottomPadding : 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppColors.accentLight
                              : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next Button
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.accentDark : AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentIndex == _onboardingData.length - 1 ? 'Mulai Sekarang' : 'Lanjut',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
