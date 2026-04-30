import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class TutorPopupPage extends StatefulWidget {
  const TutorPopupPage({super.key});

  @override
  State<TutorPopupPage> createState() => _TutorPopupPageState();
}

class _TutorPopupPageState extends State<TutorPopupPage> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': '3 Langkah Mudah\nAmankan Parkir Anda',
      'desc':
          'Tidak perlu repot, cukup ikuti langkah ini untuk mendapatkan tempat parkir sebelum Anda tiba.',
      'icon': Icons.person,
    },
    {
      'title': 'Langkah 1',
      'desc':
          'Gunakan kolom pencarian untuk menemukan gedung parkir, dan klik gedung parkir teratas untuk melihat area parkir secara detail',
      'icon': Icons.search,
    },
    {
      'title': 'Langkah 2',
      'desc':
          'Pilih lantai dan slot parkir yang tersedia, kemudian lakukan booking',
      'icon': Icons.map,
    },
    {
      'title': 'Langkah 3',
      'desc':
          'Scan tiket parkir Anda saat tiba di lokasi untuk mengaktifkan sesi parkir',
      'icon': Icons.qr_code_scanner,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Preview card
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D3B6B), Color(0xFF0A1628)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.cardBg2,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 2),
                      ),
                      child: Icon(
                        _steps[_currentStep]['icon'] as IconData,
                        color: AppColors.accent,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info panel
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  Text(
                    _steps[_currentStep]['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _steps[_currentStep]['desc'] as String,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentStep < _steps.length - 1) {
                          setState(() => _currentStep++);
                        } else {
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.home);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardBg,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _currentStep < _steps.length - 1
                            ? 'Selanjutnya'
                            : 'Mulai',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _currentStep ? 20 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _currentStep
                              ? AppColors.accent
                              : AppColors.borderColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
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
