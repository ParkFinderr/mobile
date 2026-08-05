import 'package:flutter/material.dart';
import 'package:mobile_front/core/routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../core/storage/active_ticket_storage.dart';
import '../../../core/storage/active_reservation_storage.dart';
import 'package:mobile_front/shared/widgets/shared_widgets.dart';
import 'parking_slot_item_widget.dart';
import 'package:mobile_front/features/parking/services/booking_service.dart';
import 'package:mobile_front/features/parking/models/parking_area.dart';
import 'package:mobile_front/features/profile/services/profile_service.dart';

class DetailBookingWidget extends StatefulWidget {
  final String areaId;

  const DetailBookingWidget({super.key, required this.areaId});

  @override
  State<DetailBookingWidget> createState() => _DetailBookingWidgetState();
}

class _DetailBookingWidgetState extends State<DetailBookingWidget> {
  int _navIndex = 1;

  List<ParkingSlotData> _leftSlots = [];
  List<ParkingSlotData> _rightSlots = [];
  String _areaName = '';
  String _areaAddress = '';

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    if (widget.areaId.isEmpty) {
      return;
    }

    final service = BookingService();
    ParkingArea? matchingArea;
    try {
      final areas = await service.getAreas();
      for (final a in areas) {
        if (a.id == widget.areaId || a.name.toLowerCase() == widget.areaId.toLowerCase()) {
          matchingArea = a;
          break;
        }
      }
    } catch (_) {}

    final slots = await service.getSlots(widget.areaId);

    if (mounted) {
      setState(() {
        if (matchingArea != null) {
          _areaName = matchingArea.name;
          _areaAddress = matchingArea.address;
        } else {
          _areaName = widget.areaId.isNotEmpty ? widget.areaId : 'Area Parkir';
          _areaAddress = 'Fakultas Teknik Unila';
        }

        final half = (slots.length / 2).ceil();

        SlotStatus mapStatus(String st) {
          switch (st.toLowerCase()) {
            case 'available':
              return SlotStatus.kosong;
            case 'occupied':
            case 'booked':
              return SlotStatus.terisi;
            case 'maintenance':
            default:
              return SlotStatus.pemeliharaan;
          }
        }

        _leftSlots = slots
            .take(half)
            .map((s) => ParkingSlotData(
                id: s.id, label: s.slotNumber, status: mapStatus(s.status)))
            .toList();

        _rightSlots = slots
            .skip(half)
            .map((s) => ParkingSlotData(
                id: s.id, label: s.slotNumber, status: mapStatus(s.status)))
            .toList();
      });
    }
  }

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
        Navigator.pushReplacementNamed(context, AppRoutes.history);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.profil);
        break;
    }
  }

  Future<void> _showSlotConfirmationDialog(ParkingSlotData slot) async {
    if (slot.status != SlotStatus.kosong) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Slot ini sedang terisi atau dalam pemeliharaan.')),
      );
      return;
    }

    final activeTicket = await ActiveTicketStorage().load();
    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCardBg(context);
    final cardBg2 = AppColors.getCardBg2(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    if (activeTicket == null) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Color(0xFF2563EB),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan Tiket Dahulu',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Anda perlu melakukan scan tiket parkir terlebih dahulu sebelum dapat memilih slot.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textSecondary,
                          side: BorderSide(
                            color: isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pushNamed(context, AppRoutes.welcomeScan);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF03192E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Scan Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_parking_rounded,
                  color: Color(0xFF1D4ED8),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Konfirmasi Reservasi',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin memilih Slot ${slot.label} di ${_areaName.isNotEmpty ? _areaName : "Area Parkir"}?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg2,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SLOT PILIHAN',
                            style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Lantai 1 - Sisi Timur',
                            style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Slot ${slot.label}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textSecondary,
                        side: BorderSide(
                          color: isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _handleSlotBooking(slot);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Konfirmasi', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = AppColors.getBackgroundColor(context);
    final cardBg = AppColors.getCardBg(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    final availableCount = _leftSlots.where((s) => s.status == SlotStatus.kosong).length +
        _rightSlots.where((s) => s.status == SlotStatus.kosong).length;
    final totalCount = _leftSlots.length + _rightSlots.length;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar Header
            const UserHeaderWidget(
              name: 'User',
              greeting: '',
              title: 'Peta Parkir',
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Area Title & Location Subtitle
                    Text(
                      _areaName.isNotEmpty ? _areaName : 'Area Parkir',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          _areaAddress.isNotEmpty ? _areaAddress : 'Fakultas Teknik Unila',
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Status Legend Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildLegendItem(const Color(0xFF22C55E), 'Tersedia', isDark),
                          const SizedBox(width: 16),
                          _buildLegendItem(const Color(0xFFDC2626), 'Terisi', isDark),
                          const SizedBox(width: 16),
                          _buildLegendItem(const Color(0xFF94A3B8), 'Pemeliharaan', isDark),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.directions_car_filled_rounded, size: 14, color: Color(0xFF1D4ED8)),
                                const SizedBox(width: 4),
                                Text(
                                  '$availableCount/$totalCount',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Interactive Slot Map Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardBg2Dark : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column (A01 - A05)
                          Expanded(
                            child: Column(
                              children: _leftSlots.map((slot) {
                                return ParkingSlotItemWidget(
                                  slot: slot,
                                  onTap: () => _showSlotConfirmationDialog(slot),
                                );
                              }).toList(),
                            ),
                          ),

                          // Middle Road Divider with Arrows
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              children: [
                                SizedBox(height: 16),
                                Icon(Icons.arrow_upward_rounded, size: 20, color: Color(0xFF1E40AF)),
                                SizedBox(height: 36),
                                Icon(Icons.arrow_upward_rounded, size: 20, color: Color(0xFF1E40AF)),
                                SizedBox(height: 36),
                                Icon(Icons.arrow_upward_rounded, size: 20, color: Color(0xFF1E40AF)),
                                SizedBox(height: 36),
                                Text(
                                  'MASUK\n↑',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E40AF),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Right Column (B01 - B05)
                          Expanded(
                            child: Column(
                              children: _rightSlots.map((slot) {
                                return ParkingSlotItemWidget(
                                  slot: slot,
                                  onTap: () => _showSlotConfirmationDialog(slot),
                                );
                              }).toList(),
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

            // Bottom Navigation Bar
            AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white70 : const Color(0xFF475569),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSlotBooking(ParkingSlotData slot) async {
    final profileService = ProfileService();
    final vehicleService = VehicleService();
    final profile = await profileService.getProfile();
    final vehicles = await vehicleService.getVehicles();

    final name = profile?.name ?? 'User';
    final plateNumber =
        vehicles.isNotEmpty ? vehicles.first.plateNumber : 'UNKNOWN';

    final activeTicket = await ActiveTicketStorage().load();
    final ticketId = activeTicket?.ticketCode ?? 'unknown';

    if (activeTicket == null) {
      if (mounted) {
        NoTicketDialog.show(context);
      }
      return;
    }

    final bookingService = BookingService();
    final result = await bookingService.createReservation(
      slotId: slot.id ?? '',
      ticketId: ticketId,
      name: name,
      plateNumber: plateNumber,
    );

    if (mounted) {
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result.message), backgroundColor: Colors.green),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.statusKendaraan);
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
