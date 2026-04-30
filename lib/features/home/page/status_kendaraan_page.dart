import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../public_widget/bottom_nav_bar.dart';
import '../../../app/app_routes.dart';

class StatusKendaraanPage extends StatefulWidget {
  const StatusKendaraanPage({super.key});

  @override
  State<StatusKendaraanPage> createState() => _StatusKendaraanPageState();
}

class _StatusKendaraanPageState extends State<StatusKendaraanPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glowAnim;
  int _navIndex = 2;

  // Timer simulation
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')} : ${m.toString().padLeft(2, '0')} : ${s.toString().padLeft(2, '0')} Detik';
  }

  void _onNavTap(int idx) {
    setState(() => _navIndex = idx);
    switch (idx) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.booking);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.history);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.profil);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Kendaraan Berada di Tempat',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'McLaren  Senna',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'D 12345 FE',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  // Car with glow ring
                  AnimatedBuilder(
                    animation: _glowAnim,
                    builder: (context, _) {
                      return Container(
                        width: 200,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent
                                .withOpacity(_glowAnim.value),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent
                                  .withOpacity(_glowAnim.value * 0.4),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.directions_car_filled,
                            color: Colors.white70,
                            size: 120,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Info grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoBox(
                                'Slot parkir yang digunakan',
                                'A3',
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInfoBox(
                                'Lantai yang digunakan',
                                'Lantai 1',
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildInfoBox(
                          'Waktu yang dihabiskan',
                          '03 : 10 : 32 Detik',
                          fontSize: 22,
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Keluar button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.home);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Keluar Parkir',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value,
      {required double fontSize, bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
}
