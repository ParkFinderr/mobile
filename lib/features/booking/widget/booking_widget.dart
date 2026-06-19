import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../public_widget/bottom_nav_bar.dart';
import '../../public_widget/parking_list_item_widget.dart';
import '../../public_widget/search_bar_widget.dart';
import '../service/booking_service.dart';

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
  bool _isLoading = true;

  // ── Data ─────────────────────────────────────────────────────────────────
  List<ParkingItemData> _allParking = [];

  @override
  void initState() {
    super.initState();
    _fetchAreas();
  }

  Future<void> _fetchAreas() async {
    final service = BookingService();
    final areas = await service.getAreas();
    
    if (mounted) {
      setState(() {
        _allParking = areas.map((a) {
          final total = a.totalSlot;
          final available = a.availableSlots;
          final occupancy = total > 0 ? ((total - available) / total * 100) : 0.0;
          return ParkingItemData(
            id: a.id,
            name: a.name,
            occupancyPercent: occupancy,
            availableSlotLabel: '$available/$total Kosong',
          );
        }).toList();
        _isLoading = false;
      });
    }
  }

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
      case 2:
        Navigator.pushNamed(context, AppRoutes.statusKendaraan);
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
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) => ParkingListItemWidget(
                        item: _filtered[i],
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.detailBooking,
                            arguments: _filtered[i].id,
                          );
                        },
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
