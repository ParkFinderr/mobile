import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

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

  // 0=Terang, 1=Gelap, 2=Otomatis
  int _temaIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Pengaturan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
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

                    // Notifikasi section
                    const Text('Notifikasi',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Kelola preferensi notifikasi Anda',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 12),

                    _buildToggleItem(
                      title: 'Push Notifikasi',
                      subtitle: 'Terima Notifikasi Secara Langsung',
                      value: _pushNotif,
                      onChanged: (v) => setState(() => _pushNotif = v),
                    ),
                    const SizedBox(height: 8),
                    _buildToggleItem(
                      title: 'Pengingat Booking',
                      subtitle: '15 Menit Sebelum waktu',
                      value: _pengingatBooking,
                      onChanged: (v) =>
                          setState(() => _pengingatBooking = v),
                    ),
                    const SizedBox(height: 8),
                    _buildToggleItem(
                      title: 'Sesi Dimulai',
                      subtitle: 'Notifikasi Saat Sesi Aktif',
                      value: _sesiDimulai,
                      onChanged: (v) => setState(() => _sesiDimulai = v),
                    ),
                    const SizedBox(height: 8),
                    _buildToggleItem(
                      title: 'Sesi Selesai',
                      subtitle: 'Notifikasi akhir parkir',
                      value: _sesiSelesai,
                      onChanged: (v) => setState(() => _sesiSelesai = v),
                    ),
                    const SizedBox(height: 8),
                    _buildToggleItem(
                      title: 'Peringatan Salah Parkir',
                      subtitle: 'Deteksi Perpindahan Slot',
                      value: _salahParkir,
                      onChanged: (v) => setState(() => _salahParkir = v),
                    ),

                    const SizedBox(height: 24),

                    // Tampilan section
                    const Text('Tampilan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Personalisasikan tampilan aplikasi',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 12),

                    // Tema aplikasi
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tema Aplikasi',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 2),
                                Text('Pilih tema aplikasi',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                          const Divider(color: AppColors.borderColor, height: 1),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                _buildThemeOption(0, 'Terang'),
                                const SizedBox(width: 24),
                                _buildThemeOption(1, 'Gelap'),
                                const SizedBox(width: 24),
                                _buildThemeOption(2, 'Otomatis'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // About
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'tentang Aplikasi',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.textSecondary),
                        ),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withOpacity(0.3),
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.borderColor,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(int index, String label) {
    final isSelected = _temaIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _temaIndex = index),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: isSelected ? AppColors.accent : Colors.white,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
