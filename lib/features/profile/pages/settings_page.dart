import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/styles/theme_provider.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  bool _pushNotif = true;
  bool _pengingatBooking = true;
  bool _sesiDimulai = true;
  bool _sesiSelesai = true;
  bool _salahParkir = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? AppColors.borderColorDark : AppColors.borderColorLight),
                      ),
                      child: Icon(Icons.arrow_back_ios_new,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight, size: 18),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Pengaturan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    Text('Notifikasi',
                        style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Kelola preferensi notifikasi Anda',
                        style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 12)),
                    const SizedBox(height: 12),

                    _buildToggleItem(
                      title: 'Push Notifikasi',
                      subtitle: 'Terima Notifikasi Secara Langsung',
                      value: _pushNotif,
                      onChanged: (v) => setState(() => _pushNotif = v),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildToggleItem(
                      title: 'Pengingat Booking',
                      subtitle: '15 Menit Sebelum waktu',
                      value: _pengingatBooking,
                      onChanged: (v) => setState(() => _pengingatBooking = v),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildToggleItem(
                      title: 'Sesi Dimulai',
                      subtitle: 'Notifikasi Saat Sesi Aktif',
                      value: _sesiDimulai,
                      onChanged: (v) => setState(() => _sesiDimulai = v),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildToggleItem(
                      title: 'Sesi Selesai',
                      subtitle: 'Notifikasi akhir parkir',
                      value: _sesiSelesai,
                      onChanged: (v) => setState(() => _sesiSelesai = v),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildToggleItem(
                      title: 'Peringatan Salah Parkir',
                      subtitle: 'Deteksi Perpindahan Slot',
                      value: _salahParkir,
                      onChanged: (v) => setState(() => _salahParkir = v),
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),

                    Text('Tampilan',
                        style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Personalisasikan tampilan aplikasi',
                        style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 12)),
                    const SizedBox(height: 12),

                    // Tema aplikasi
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? AppColors.borderColorDark : AppColors.borderColorLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tema Aplikasi',
                                    style: TextStyle(
                                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text('Pilih mode tema aplikasi',
                                    style: TextStyle(
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                          Divider(
                              color: isDark ? AppColors.borderColorDark : AppColors.borderColorLight, height: 1),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                _buildThemeOption(context, false, 'Terang', isDark),
                                const SizedBox(width: 32),
                                _buildThemeOption(context, true, 'Gelap', isDark),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Center(
                      child: Text(
                        'Tentang Aplikasi ParkFinder v1.0.0',
                        style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderColorDark : AppColors.borderColorLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accentLight,
            activeTrackColor: AppColors.accentLight.withValues(alpha: 0.3),
            inactiveThumbColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            inactiveTrackColor: isDark ? AppColors.borderColorDark : AppColors.borderColorLight,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, bool isTargetDark, String label, bool isCurrentDark) {
    final isSelected = isTargetDark == isCurrentDark;
    return GestureDetector(
      onTap: () {
        context.read<ThemeProvider>().toggleTheme(isTargetDark);
      },
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.accentLight : (isCurrentDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accentLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: isSelected ? AppColors.accentLight : (isCurrentDark ? Colors.white : AppColors.textPrimaryLight),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
