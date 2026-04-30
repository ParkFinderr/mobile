import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../public_widget/bottom_nav_bar.dart';
import '../../public_widget/user_header_widget.dart';
import '../../public_widget/search_bar_widget.dart';
import '../../public_widget/section_title_widget.dart';
import '../../public_widget/parking_list_item_widget.dart';
import '../../public_widget/end_session_dialog_widget.dart';
import 'hero_banner_widget.dart';
import 'status_card_widget.dart';

/// HomeWidget: Composer untuk halaman utama (dashboard).
///
/// Tanggung jawab:
/// - Mengelola state [_navIndex] dan data [_parkingList]
/// - Menyusun widget: Header, Banner, StatusCards, SearchBar, ParkingList
/// - Menangani navigasi dan dialog akhiri sesi
class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  // ── State ────────────────────────────────────────────────────────────────
  int _navIndex = 0;

  // ── Data (akan digantikan ViewModel/Repository) ──────────────────────────
  final List<ParkingItemData> _parkingList = const [
    ParkingItemData(
      name: 'Jurusan Teknik Elektro Universitas Lampung',
      occupancyPercent: 78,
      availableSlotLabel: '4/5 Kosong',
    ),
    ParkingItemData(
      name: 'Mall Boemi Kedaton',
      occupancyPercent: 81,
      availableSlotLabel: '635/1384 Kosong',
    ),
    ParkingItemData(
      name: 'Lampung City Mall',
      occupancyPercent: 81,
      availableSlotLabel: '635/1384 Kosong',
    ),
  ];

  // ── Handlers ───────────────────────────────────────────────────────────────
  void _onNavTap(int idx) {
    setState(() => _navIndex = idx);
    switch (idx) {
      case 1:
        Navigator.pushNamed(context, AppRoutes.booking);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.history);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.profil);
        break;
    }
  }

  void _showEndSessionDialog() {
    showDialog(
      context: context,
      builder: (_) => EndSessionDialogWidget(
        vehiclePlate: 'D 12345 FE',
        parkingDuration: '3 Jam 10 Menit',
        onConfirm: () => Navigator.pop(context),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  // ── Build (Composer) ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ① Header pengguna
                UserHeaderWidget(
                  name: 'Imam Ariadi',
                  greeting: 'Selamat Pagi',
                ),
                const SizedBox(height: 16),

                // ② Hero banner
                const HeroBannerWidget(),
                const SizedBox(height: 16),

                // ③ Status cards (horizontal scroll)
                _buildStatusCards(),
                const SizedBox(height: 20),

                // ④ Search bar (read-only, navigasi ke booking)
                SearchBarWidget(
                  readOnly: true,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.booking),
                ),
                const SizedBox(height: 20),

                // ⑤ Section parkir tersedia
                const SectionTitleWidget(
                  title: 'Gedung Parkir yang Tersedia',
                ),
                const SizedBox(height: 12),

                // ⑥ Daftar parkir
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: _parkingList
                        .map((item) => ParkingListItemWidget(
                              item: item,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.detailBooking),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ⑦ Bottom nav bar
        AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
      ],
    );
  }

  // ── Private Builders ───────────────────────────────────────────────────────

  Widget _buildStatusCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          StatusCardWidget(
            title: 'Status Tiket\nAktif',
            icon: Icons.confirmation_number_outlined,
            iconColor: Colors.orange,
            subtitle: 'Diaktifkan Sejak\n01:43:02',
            width: 130,
          ),
          const SizedBox(width: 10),
          StatusCardWidget(
            title: 'Status Booking\nMenunggu Aktivasi',
            icon: Icons.timelapse,
            iconColor: AppColors.accent,
            subtitle: 'Slot A4 – Lantai 1\nAktivasi dalam 15 menit',
            width: 148,
          ),
          const SizedBox(width: 10),
          StatusCardWidget(
            title: 'Parkir Aktif\nLantai 1 - Zona A- Slot A3',
            icon: Icons.directions_car,
            iconColor: AppColors.orange,
            subtitle: '01:43:02',
            width: 140,
            actions: [
              CardActionTextWidget(
                label: 'Lihat Detail',
                onTap: () {},
              ),
              CardActionTextWidget(
                label: 'Akhiri Sesi',
                onTap: _showEndSessionDialog,
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
