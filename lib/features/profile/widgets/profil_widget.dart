import 'package:flutter/material.dart';
import 'package:mobile_front/core/routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import 'package:mobile_front/shared/widgets/shared_widgets.dart';
import 'profile_avatar_widget.dart';
import 'stats_card_widget.dart';
import 'package:mobile_front/features/profile/services/profile_service.dart';
import 'package:mobile_front/features/profile/models/vehicle.dart';
import 'package:mobile_front/features/profile/models/profile_data.dart';
import 'package:mobile_front/features/auth/services/auth_service.dart';
import 'package:mobile_front/features/history/services/history_service.dart';
import 'package:mobile_front/core/storage/active_reservation_storage.dart';
import 'package:mobile_front/core/storage/active_ticket_storage.dart';

class ProfilWidget extends StatefulWidget {
  const ProfilWidget({super.key});

  @override
  State<ProfilWidget> createState() => _ProfilWidgetState();
}

class _ProfilWidgetState extends State<ProfilWidget> {
  int _navIndex = 4;
  bool _isLoading = true;
  ProfileData? _profileData;
  List<Vehicle> _vehicles = [];
  int _totalParkir = 0;
  int _parkirAktif = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profileService = ProfileService();
    final vehicleService = VehicleService();
    final historyService = HistoryService();

    final profile = await profileService.getProfile();
    final vehicles = await vehicleService.getVehicles();

    int totalCount = 0;
    int activeCount = 0;

    if (profile != null) {
      final history = await historyService.getHistory(profile.userId);
      totalCount = history.length;
      activeCount = history.where((h) {
        final st = h.status.toLowerCase();
        return st == 'active' ||
            st == 'pending' ||
            st == 'arrived' ||
            st == 'booked' ||
            st == 'claimed';
      }).length;
    }

    final activeRes = await ActiveReservationStorage().load();
    final activeTicket = await ActiveTicketStorage().load();
    if (activeCount == 0 &&
        ((activeRes != null && activeRes.reservationId.isNotEmpty) ||
            (activeTicket != null && activeTicket.isActive))) {
      activeCount = 1;
    }

    if (mounted) {
      setState(() {
        _profileData = profile;
        _vehicles = vehicles;
        _totalParkir = totalCount;
        _parkirAktif = activeCount;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = AppColors.getBackgroundColor(context);
    final cardBg = AppColors.getCardBg(context);
    final cardBg2 = AppColors.getCardBg2(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // User Header
                UserHeaderWidget(
                  name: _profileData?.name ?? 'User',
                  greeting: '',
                  title: 'ParkFinder',
                  photoUrl: _profileData?.photoUrl,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Avatar & Name Header
                        ProfileAvatarWidget(photoUrl: _profileData?.photoUrl),
                        const SizedBox(height: 12),

                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          Column(
                            children: [
                              Text(
                                _profileData?.name ?? 'Imam Ariadi',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Member sejak Januari 2026',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Kartu Statistik
                              StatsCardWidget(
                                totalParkir: '$_totalParkir',
                                parkirAktif: '$_parkirAktif',
                              ),
                              const SizedBox(height: 20),

                              // Section Informasi Pribadi
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Informasi Pribadi',
                                        style: TextStyle(
                                          color: textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      _buildInfoCard(
                                        icon: Icons.email_outlined,
                                        label: 'Email',
                                        value: _profileData?.email ?? 'imamariadi775@gmail.com',
                                        isDark: isDark,
                                        cardBg2: cardBg2,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                      ),
                                      const SizedBox(height: 12),

                                      _buildInfoCard(
                                        icon: Icons.phone_outlined,
                                        label: 'Nomor Telpon',
                                        value: _profileData?.phoneNumber ?? '085788322061',
                                        isDark: isDark,
                                        cardBg2: cardBg2,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                      ),
                                      const SizedBox(height: 12),

                                      _buildInfoCard(
                                        icon: Icons.directions_car_outlined,
                                        label: 'Kendaraan Utama (Mobil)',
                                        value: _vehicles.isEmpty
                                            ? 'BE 1234 AB (Mobil)'
                                            : '${_vehicles.first.plateNumber} (Mobil)',
                                        isDark: isDark,
                                        cardBg2: cardBg2,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 20),

                        // Section Pengaturan & Akses
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pengaturan',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                SettingsRowItemWidget(
                                  icon: Icons.edit_outlined,
                                  title: 'Edit Profil',
                                  subtitle: 'Ubah Informasi Profil Anda',
                                  onTap: () =>
                                      Navigator.pushNamed(context, AppRoutes.editProfil)
                                          .then((_) => _loadProfile()),
                                ),
                                SettingsRowItemWidget(
                                  icon: Icons.directions_car_outlined,
                                  title: 'Manajemen Kendaraan',
                                  subtitle: 'Kelola Kendaraan Mobil Anda',
                                  onTap: () => Navigator.pushNamed(
                                          context, AppRoutes.vehicleManagement)
                                      .then((_) => _loadProfile()),
                                ),
                                SettingsRowItemWidget(
                                  icon: Icons.settings_outlined,
                                  title: 'Preferensi & Tema',
                                  subtitle: 'Ubah Pengaturan Tema (Light/Dark Mode)',
                                  onTap: () =>
                                      Navigator.pushNamed(context, AppRoutes.pengaturan),
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Button Keluar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _doLogout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Keluar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Navigation Bar
                AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
              ],
            ),
            const FloatingTutorialWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color cardBg2,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1D4ED8), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
