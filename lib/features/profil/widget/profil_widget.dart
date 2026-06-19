import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../public_widget/bottom_nav_bar.dart';
import '../../public_widget/info_row_item_widget.dart';
import '../../public_widget/settings_row_item_widget.dart';
import 'profile_avatar_widget.dart';
import 'stats_card_widget.dart';
import '../service/profile_service.dart';
import '../service/vehicle_service.dart';
import '../model/vehicle.dart';
import '../../login/service/auth_service.dart';

/// ProfilWidget: Composer untuk halaman profil pengguna.
///
/// Tanggung jawab:
/// - Mengelola state [_navIndex]
/// - Menyusun widget: Avatar, nama, stats, info pribadi, pengaturan, tombol aksi
/// - Menangani navigasi
class ProfilWidget extends StatefulWidget {
  const ProfilWidget({super.key});

  @override
  State<ProfilWidget> createState() => _ProfilWidgetState();
}

class _ProfilWidgetState extends State<ProfilWidget> {
  // ── State ────────────────────────────────────────────────────────────────
  int _navIndex = 4;
  bool _isLoading = true;
  ProfileData? _profileData;
  List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profileService = ProfileService();
    final vehicleService = VehicleService();
    final profile = await profileService.getProfile();
    final vehicles = await vehicleService.getVehicles();
    
    if (mounted) {
      setState(() {
        _profileData = profile;
        _vehicles = vehicles;
        _isLoading = false;
      });
    }
  }

  Future<void> _doLogout() async {
    final auth = AuthService();
    await auth.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  // ── Handlers ───────────────────────────────────────────────────────────────
  void _onNavTap(int idx) {
    setState(() => _navIndex = idx);
    switch (idx) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.booking);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.statusKendaraan);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.history);
        break;
    }
  }

  // ── Build (Composer) ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ① Avatar
                ProfileAvatarWidget(photoUrl: _profileData?.photoUrl),
                const SizedBox(height: 12),

                // ② Nama & keterangan
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      Text(
                        _profileData?.name ?? 'Nama Tidak Diketahui',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Member Aktif',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 20),

                      // ③ Kartu statistik
                      const StatsCardWidget(
                        totalParkir: '0',
                        parkirAktif: '0',
                      ),
                      const SizedBox(height: 16),

                      // ④ Section informasi pribadi
                      _ProfileSectionCardWidget(
                        title: 'Informasi Pribadi',
                        children: [
                          InfoRowItemWidget(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: _profileData?.email ?? '-',
                          ),
                          InfoRowItemWidget(
                            icon: Icons.phone_outlined,
                            label: 'Nomor Telpon',
                            value: _profileData?.phoneNumber ?? '-',
                          ),
                          InfoRowItemWidget(
                            icon: Icons.directions_car_outlined,
                            label: 'Kendaraan',
                            value: _vehicles.isEmpty
                                ? 'Belum ada kendaraan'
                                : _vehicles.length == 1
                                    ? _vehicles.first.plateNumber
                                    : '${_vehicles.first.plateNumber} (+${_vehicles.length - 1} lainnya)',
                            isLast: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 14),

                // ⑤ Section pengaturan
                _ProfileSectionCardWidget(
                  title: 'Pengaturan',
                  children: [
                    SettingsRowItemWidget(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profil',
                      subtitle: 'Ubah Informasi Profil Anda',
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.editProfil).then((_) {
                        _loadProfile();
                      }),
                    ),
                    SettingsRowItemWidget(
                      icon: Icons.directions_car_outlined,
                      title: 'Manajemen Kendaraan',
                      subtitle: 'Tambah & Hapus Kendaraan Anda',
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.vehicleManagement).then((_) {
                        // Refresh profil setelah kembali dari vehicle management
                        _loadProfile();
                      }),
                    ),
                    SettingsRowItemWidget(
                      icon: Icons.settings_outlined,
                      title: 'Preferensi',
                      subtitle: 'Ubah Pengaturan Personal Anda',
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.pengaturan),
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ⑥ Tombol aksi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.home),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.borderColor),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Kembali Ke Beranda',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _doLogout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                          ),
                          child: const Text('Keluar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ⑦ Bottom nav
        AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
      ],
    );
  }
}

// ── Private section card container ───────────────────────────────────────────

class _ProfileSectionCardWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSectionCardWidget({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
