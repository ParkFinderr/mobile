import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../public_widget/bottom_nav_bar.dart';
import '../../public_widget/parking_list_item_widget.dart';
import '../../public_widget/search_bar_widget.dart';

/// BookingWidget: Composer untuk halaman pencarian dan pemilihan gedung parkir.
///
/// Tanggung jawab:
/// - Mengelola state [_searchCtrl], [_navIndex], filter hasil pencarian
/// - Menyusun widget: Header, SearchBar, ListView dengan ParkingListItemWidget
/// - Menangani navigasi ke DetailBooking
class BookingWidget extends StatefulWidget {
  const BookingWidget({super.key});

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  // ── State ────────────────────────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  int _navIndex = 1;

  // ── Data ─────────────────────────────────────────────────────────────────
  final List<ParkingItemData> _allParking = const [
    ParkingItemData(name: 'Jurusan Teknik Elektro Universitas Lampung', occupancyPercent: 78, availableSlotLabel: '4/5 Kosong'),
    ParkingItemData(name: 'Mall Boemi Kedaton', occupancyPercent: 81, availableSlotLabel: '635/1384 Kosong'),
    ParkingItemData(name: 'Jurusan Teknik Elektro Universitas Lampung', occupancyPercent: 78, availableSlotLabel: '4/5 Kosong'),
    ParkingItemData(name: 'Lampung City Mall', occupancyPercent: 81, availableSlotLabel: '635/1384 Kosong'),
    ParkingItemData(name: 'Jurusan Teknik Elektro Universitas Lampung', occupancyPercent: 78, availableSlotLabel: '4/5 Kosong'),
    ParkingItemData(name: 'Lampung City Mall', occupancyPercent: 81, availableSlotLabel: '635/1384 Kosong'),
    ParkingItemData(name: 'Mall Boemi Kedaton', occupancyPercent: 81, availableSlotLabel: '635/1384 Kosong'),
    ParkingItemData(name: 'Mall Boemi Kedaton', occupancyPercent: 81, availableSlotLabel: '635/1384 Kosong'),
    ParkingItemData(name: 'Jurusan Teknik Elektro Universitas Lampung', occupancyPercent: 78, availableSlotLabel: '4/5 Kosong'),
    ParkingItemData(name: 'Lampung City Mall', occupancyPercent: 81, availableSlotLabel: '635/1384 Kosong'),
    ParkingItemData(name: 'Lampung City Mall', occupancyPercent: 81, availableSlotLabel: '635/1384 Kosong'),
    ParkingItemData(name: 'Jurusan Teknik Elektro Universitas Lampung', occupancyPercent: 78, availableSlotLabel: '4/5 Kosong'),
    ParkingItemData(name: 'Jurusan Teknik Elektro Universitas Lampung', occupancyPercent: 78, availableSlotLabel: '4/5 Kosong'),
    ParkingItemData(name: 'Mall Boemi Kedaton', occupancyPercent: 81, availableSlotLabel: '635/1384 Kosong'),
    ParkingItemData(name: 'Jurusan Teknik Elektro Universitas Lampung', occupancyPercent: 78, availableSlotLabel: '4/5 Kosong'),
    ParkingItemData(name: 'Jurusan Teknik Elektro Universitas Lampung', occupancyPercent: 78, availableSlotLabel: '4/5 Kosong'),
  ];

  List<ParkingItemData> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _allParking;
    return _allParking
        .where((e) => e.name.toLowerCase().contains(q))
        .toList();
  }

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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Build (Composer) ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ① Header
              _BookingHeaderWidget(),
              const SizedBox(height: 12),

              // ② Search bar
              SearchBarWidget(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // ③ Daftar gedung parkir (filtered)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) => ParkingListItemWidget(
                    item: _filtered[i],
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.detailBooking),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ④ Bottom nav
        AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
      ],
    );
  }
}

// ── Private feature header (hanya di booking) ─────────────────────────────────

class _BookingHeaderWidget extends StatelessWidget {
  const _BookingHeaderWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Carilah Tempat parkir anda',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }
}
