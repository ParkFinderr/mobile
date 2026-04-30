import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../public_widget/bottom_nav_bar.dart';
import '../../public_widget/search_bar_widget.dart';
import 'floor_tab_widget.dart';
import 'parking_slot_item_widget.dart';
import 'parking_slot_map_widget.dart';

/// DetailBookingWidget: Composer untuk halaman peta slot parkir.
///
/// Tanggung jawab:
/// - Mengelola state [_selectedFloorTab], [_navIndex]
/// - Menyusun widget: AppBar custom, SearchBar, FloorTabs, ZoneHeader, SlotMap
/// - Menangani navigasi
class DetailBookingWidget extends StatefulWidget {
  const DetailBookingWidget({super.key});

  @override
  State<DetailBookingWidget> createState() => _DetailBookingWidgetState();
}

class _DetailBookingWidgetState extends State<DetailBookingWidget> {
  // ── State ────────────────────────────────────────────────────────────────
  int _selectedFloorTab = 0;
  int _navIndex = 1;

  // ── Data ─────────────────────────────────────────────────────────────────
  final List<ParkingSlotData> _leftSlots = const [
    ParkingSlotData(label: 'A20', status: SlotStatus.alatRusak),
    ParkingSlotData(label: 'A19', status: SlotStatus.alatRusak),
    ParkingSlotData(label: 'A18', status: SlotStatus.alatRusak),
    ParkingSlotData(label: 'A17', status: SlotStatus.alatRusak),
    ParkingSlotData(label: 'A16', status: SlotStatus.alatRusak),
    ParkingSlotData(label: 'A15', status: SlotStatus.alatRusak),
    ParkingSlotData(label: 'A14', status: SlotStatus.alatRusak),
    ParkingSlotData(label: 'A13', status: SlotStatus.alatRusak),
    ParkingSlotData(label: 'A12', status: SlotStatus.alatRusak),
    ParkingSlotData(label: 'A11', status: SlotStatus.alatRusak),
  ];

  final List<ParkingSlotData> _rightSlots = const [
    ParkingSlotData(label: 'A01', status: SlotStatus.terisi),
    ParkingSlotData(label: 'A02', status: SlotStatus.kosong),
    ParkingSlotData(label: 'A03', status: SlotStatus.terpesan),
    ParkingSlotData(label: 'A04', status: SlotStatus.kosong),
    ParkingSlotData(label: 'A05', status: SlotStatus.kosong),
    ParkingSlotData(label: 'A06', status: SlotStatus.pemeliharaan),
    ParkingSlotData(label: 'A07', status: SlotStatus.alatRusak),
    ParkingSlotData(label: 'A08', status: SlotStatus.alatRusak),
    ParkingSlotData(label: 'A09', status: SlotStatus.alatRusak),
    ParkingSlotData(label: 'A10', status: SlotStatus.alatRusak),
  ];

  static const _floorTabs = ['Semua', 'Lantai 1', 'Lantai 2'];

  // ── Handlers ───────────────────────────────────────────────────────────────
  void _onNavTap(int idx) {
    setState(() => _navIndex = idx);
    switch (idx) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.history);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.profil);
        break;
    }
  }

  // ── Build (Composer) ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ① Custom app bar
        _DetailAppBarWidget(
          title: 'Teknik Elektro Universitas Lampung',
          onBack: () => Navigator.pop(context),
        ),

        // ② Search bar (read-only mock)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: SearchBarWidget(
            hintText: 'Cari slot , contoh (lantai 1 Slot A4)',
            readOnly: true,
          ),
        ),

        // ③ Floor tabs
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: _floorTabs.asMap().entries.map((e) {
              return Padding(
                padding: EdgeInsets.only(right: e.key < _floorTabs.length - 1 ? 8 : 0),
                child: FloorTabWidget(
                  label: e.value,
                  isSelected: _selectedFloorTab == e.key,
                  onTap: () =>
                      setState(() => _selectedFloorTab = e.key),
                ),
              );
            }).toList(),
          ),
        ),

        // ④ Zone header
        const _ZoneHeaderWidget(zoneName: 'Zona A - Lantai 1'),

        // ⑤ Peta slot parkir
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ParkingSlotMapWidget(
              leftSlots: _leftSlots,
              rightSlots: _rightSlots,
            ),
          ),
        ),

        // ⑥ Bottom nav
        AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
      ],
    );
  }
}

// ── Private feature-specific widgets ─────────────────────────────────────────

class _DetailAppBarWidget extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _DetailAppBarWidget(
      {required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }
}

class _ZoneHeaderWidget extends StatelessWidget {
  final String zoneName;

  const _ZoneHeaderWidget({required this.zoneName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.arrow_back_ios,
              color: AppColors.textSecondary, size: 16),
          Text(
            zoneName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          const Icon(Icons.arrow_forward_ios,
              color: AppColors.textSecondary, size: 16),
        ],
      ),
    );
  }
}
