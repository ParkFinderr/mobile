import 'package:flutter/material.dart';
import '../styles/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.navBarDark : AppColors.navBarLight;
    final borderColor = isDark ? AppColors.borderColorDark : AppColors.borderColorLight;

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
      decoration: BoxDecoration(
        color: navBg,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, 0, Icons.home_outlined, 'Beranda', isDark),
          _buildNavItem(context, 1, Icons.map_outlined, 'Area Parkir', isDark),
          _buildNavItem(context, 2, Icons.directions_car_outlined, 'Status Parkir', isDark),
          _buildNavItem(context, 3, Icons.history_rounded, 'Riwayat', isDark),
          _buildNavItem(context, 4, Icons.person_outline_rounded, 'Profil', isDark),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, bool isDark) {
    final isActive = currentIndex == index;
    const activeColor = Color(0xFFF97316);
    final unselectedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : unselectedColor,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : unselectedColor,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
