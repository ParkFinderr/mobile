import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/storage/active_ticket_storage.dart';
import '../../../core/storage/active_reservation_storage.dart';
import '../../public_widget/bottom_nav_bar.dart';
import '../../../app/app_routes.dart';
import '../../access/service/access_service.dart';
import '../../welcome_scan/service/scan_service.dart';
import '../service/parking_service.dart';
import '../../profil/service/vehicle_service.dart';
import '../../profil/model/vehicle.dart';

class StatusKendaraanPage extends StatefulWidget {
  const StatusKendaraanPage({super.key});

  @override
  State<StatusKendaraanPage> createState() => _StatusKendaraanPageState();
}

class _StatusKendaraanPageState extends State<StatusKendaraanPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glowAnim;
  int _navIndex = 2;

  int _elapsedSeconds = 0;
  Timer? _timer;
  TicketData? _activeTicket;
  ActiveReservation? _activeReservation;
  bool _isCancelling = false;
  bool _isLoading = true;

  // Vehicle data from API
  String _plateNumber = '';
  String _vehicleType = '';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    // Load active ticket from API first, then from storage
    final accessService = AccessService();
    final apiTicket = await accessService.getActiveTicket();
    if (apiTicket != null) {
      await ActiveTicketStorage().save(apiTicket);
    }
    final ticket = await ActiveTicketStorage().load();

    // Load active reservation from local storage
    final reservation = await ActiveReservationStorage().load();

    // Load vehicle data from API
    final vehicleService = VehicleService();
    List<Vehicle> vehicles = [];
    try {
      vehicles = await vehicleService.getVehicles();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _activeTicket = ticket;
        _activeReservation = reservation;

        // Get plate number and vehicle type from vehicle data
        if (vehicles.isNotEmpty) {
          _plateNumber = vehicles.first.plateNumber;
          _vehicleType = vehicles.first.vehicleType;
        } else if (ticket != null && ticket.vehicleType.isNotEmpty) {
          _vehicleType = ticket.vehicleType;
        }

        _isLoading = false;
      });

      // Start timer based on reservation startTime
      _startElapsedTimer();
    }
  }

  void _startElapsedTimer() {
    _timer?.cancel();

    if (_activeReservation != null && _activeReservation!.startTime.isNotEmpty) {
      try {
        final startTime = DateTime.parse(_activeReservation!.startTime);
        _elapsedSeconds = DateTime.now().difference(startTime).inSeconds;
        if (_elapsedSeconds < 0) _elapsedSeconds = 0;
      } catch (_) {
        _elapsedSeconds = 0;
      }
    } else if (_activeTicket != null && _activeTicket!.ticketCode.isNotEmpty && _activeTicket!.status == 'active') {
      // Fallback: start from 0 if no startTime available
      _elapsedSeconds = 0;
    } else {
      return; // No active session, don't start timer
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get _hasActiveSession {
    if (_activeReservation != null && _activeReservation!.reservationId.isNotEmpty) {
      return true;
    }
    if (_activeTicket != null && _activeTicket!.ticketCode.isNotEmpty && _activeTicket!.status == 'active') {
      return true;
    }
    return false;
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
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.history);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.profil);
        break;
    }
  }

  Future<void> _onKeluarParkir() async {
    if (!_hasActiveSession) return;

    setState(() => _isCancelling = true);

    final service = ParkingService();
    CancelResult result;

    if (_activeReservation != null) {
      result = await service.cancelReservation(_activeReservation!.reservationId);
    } else if (_activeTicket != null) {
      result = await service.cancelTicket(_activeTicket!.ticketCode);
    } else {
      await ActiveTicketStorage().clear();
      await ActiveReservationStorage().clear();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }

    if (!mounted) return;

    setState(() => _isCancelling = false);

    if (result.success) {
      _timer?.cancel();
      await ActiveTicketStorage().clear();
      await ActiveReservationStorage().clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Text('Gagal', style: TextStyle(color: Colors.white)),
          content: Text(result.message, style: const TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup', style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    )
                  : _hasActiveSession
                      ? _buildActiveSessionView()
                      : _buildEmptyStateView(),
            ),
            AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
          ],
        ),
      ),
    );
  }

  // ── Empty State (No Active Session) ──────────────────────────────────────

  Widget _buildEmptyStateView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBg,
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                color: AppColors.textSecondary,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tidak Ada Sesi Parkir Aktif',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Anda belum memiliki sesi parkir yang sedang berjalan.\n'
              'Silakan scan tiket dan booking slot parkir terlebih dahulu.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.welcomeScan);
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                    label: const Text('Scan Tiket'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.booking);
                    },
                    icon: const Icon(Icons.local_parking_rounded, size: 18),
                    label: const Text('Cari Parkir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Active Session View ──────────────────────────────────────────────────

  Widget _buildActiveSessionView() {
    final slotName = _activeReservation?.slotName ?? '';
    final areaName = _activeTicket?.areaName ?? '';
    final displayVehicleType = _vehicleType.isNotEmpty
        ? _vehicleType.toUpperCase()
        : 'KENDARAAN';

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Header
          const Text(
            'Kendaraan Berada di Tempat',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),

          // Vehicle type
          Text(
            displayVehicleType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Plate number
          if (_plateNumber.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Text(
                _plateNumber,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],

          const SizedBox(height: 28),

          // Car with glow ring
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (context, _) {
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withOpacity(_glowAnim.value),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(_glowAnim.value * 0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_car_filled,
                    color: Colors.white70,
                    size: 100,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // Info grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Row 1: Plat Nomor + Tipe Kendaraan
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        'Plat Nomor',
                        _plateNumber.isNotEmpty ? _plateNumber : '—',
                        icon: Icons.badge_outlined,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInfoBox(
                        'Tipe Kendaraan',
                        displayVehicleType,
                        icon: Icons.directions_car_outlined,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Row 2: Lokasi Parkir + Slot
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        'Lokasi Parkir',
                        areaName.isNotEmpty ? areaName : '—',
                        icon: Icons.location_on_outlined,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInfoBox(
                        'Slot Parkir',
                        slotName.isNotEmpty ? slotName : '—',
                        icon: Icons.local_parking_rounded,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Row 3: Durasi Parkir (full width)
                _buildInfoBox(
                  'Durasi Parkir',
                  _formatTime(_elapsedSeconds),
                  icon: Icons.timer_outlined,
                  fontSize: 28,
                  fullWidth: true,
                  isHighlighted: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Keluar button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isCancelling ? null : _onKeluarParkir,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isCancelling
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Keluar Parkir',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoBox(
    String label,
    String value, {
    required double fontSize,
    IconData? icon,
    bool fullWidth = false,
    bool isHighlighted = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.accent.withOpacity(0.08)
            : AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted
              ? AppColors.accent.withOpacity(0.3)
              : AppColors.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                color: isHighlighted ? AppColors.accent : Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
}
