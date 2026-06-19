import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/storage/active_ticket_storage.dart';
import '../../../core/storage/active_reservation_storage.dart';
import '../../public_widget/bottom_nav_bar.dart';
import '../../public_widget/search_bar_widget.dart';
import 'floor_tab_widget.dart';
import 'parking_slot_item_widget.dart';
import 'parking_slot_map_widget.dart';
import '../../booking/service/booking_service.dart';
import '../../profil/service/profile_service.dart';
import '../../profil/service/vehicle_service.dart';
import '../../public_widget/no_ticket_dialog.dart';

/// DetailBookingWidget: Composer untuk halaman peta slot parkir.
///
/// Tanggung jawab:
/// - Mengelola state [_selectedFloorTab], [_navIndex]
/// - Menyusun widget: AppBar custom, SearchBar, FloorTabs, ZoneHeader, SlotMap
/// - Menangani navigasi
class DetailBookingWidget extends StatefulWidget {
  final String areaId;

  const DetailBookingWidget({super.key, required this.areaId});

  @override
  State<DetailBookingWidget> createState() => _DetailBookingWidgetState();
}

class _DetailBookingWidgetState extends State<DetailBookingWidget> {
  // ── State ────────────────────────────────────────────────────────────────
  int _selectedFloorTab = 0;
  int _navIndex = 1;
  bool _isLoading = true;

  // ── Data ─────────────────────────────────────────────────────────────────
  List<ParkingSlotData> _leftSlots = [];
  List<ParkingSlotData> _rightSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    if (widget.areaId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final service = BookingService();
    final slots = await service.getSlots(widget.areaId);

    if (mounted) {
      setState(() {
        // Simple division of slots to left and right for UI purpose
        final half = (slots.length / 2).ceil();
        
        SlotStatus mapStatus(String st) {
          switch (st.toLowerCase()) {
            case 'available': return SlotStatus.kosong;
            case 'occupied': return SlotStatus.terisi;
            case 'booked': return SlotStatus.terpesan;
            case 'maintenance': return SlotStatus.pemeliharaan;
            default: return SlotStatus.alatRusak;
          }
        }

        _leftSlots = slots.take(half).map((s) => ParkingSlotData(
          id: s.id,
          label: s.slotNumber, 
          status: mapStatus(s.status)
        )).toList();
        
        _rightSlots = slots.skip(half).map((s) => ParkingSlotData(
          id: s.id,
          label: s.slotNumber, 
          status: mapStatus(s.status)
        )).toList();
        
        _isLoading = false;
      });
    }
  }

  static const _floorTabs = ['Semua', 'Lantai 1', 'Lantai 2'];

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
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ParkingSlotMapWidget(
                  leftSlots: _leftSlots,
                  rightSlots: _rightSlots,
                  onSlotTap: (slot) => _handleSlotBooking(slot),
                ),
              ),
        ),

        // ⑥ Bottom nav
        AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
      ],
    );
  }
  Future<void> _handleSlotBooking(ParkingSlotData slot) async {
    if (slot.status != SlotStatus.kosong) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Slot tidak tersedia.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Get Profile for name and plateNumber
    final profileService = ProfileService();
    final vehicleService = VehicleService();
    final profile = await profileService.getProfile();
    final vehicles = await vehicleService.getVehicles();

    final name = profile?.name ?? 'User';
    final plateNumber = vehicles.isNotEmpty ? vehicles.first.plateNumber : 'UNKNOWN';

    final activeTicket = await ActiveTicketStorage().load();
    final ticketId = activeTicket?.ticketCode ?? 'unknown';

    if (activeTicket == null || activeTicket.status != 'active') {
      if (mounted) {
        setState(() => _isLoading = false);
        NoTicketDialog.show(context);
      }
      return;
    }

    final bookingService = BookingService();
    final result = await bookingService.createReservation(slot.id ?? '', ticketId, name, plateNumber);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result.success && result.reservationId.isNotEmpty) {
        final reservation = ActiveReservation(
          reservationId: result.reservationId,
          status: result.status,
          slotId: slot.id ?? '',
          slotName: slot.label,
          areaId: widget.areaId,
          ticketId: ticketId,
          startTime: DateTime.now().toIso8601String(),
        );
        await ActiveReservationStorage().save(reservation);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.green),
        );
        _fetchSlots();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
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
