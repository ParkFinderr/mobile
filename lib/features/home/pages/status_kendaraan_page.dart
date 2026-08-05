import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../core/storage/active_ticket_storage.dart';
import '../../../core/storage/active_reservation_storage.dart';
import 'package:mobile_front/shared/widgets/shared_widgets.dart';
import 'package:mobile_front/core/routes/app_routes.dart';
import 'package:mobile_front/features/scan/services/scan_service.dart';
import 'package:mobile_front/features/scan/models/ticket_data.dart';
import 'package:mobile_front/features/profile/services/profile_service.dart';
import 'package:mobile_front/features/profile/models/vehicle.dart';
import 'package:mobile_front/features/history/services/history_service.dart';
import 'package:mobile_front/features/history/models/reservation_history.dart';
import 'package:mobile_front/features/parking/services/booking_service.dart';
import 'package:mobile_front/features/parking/models/parking_slot.dart';

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
  bool _isArriving = false;

  String _plateNumber = '';

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    var ticket = await ActiveTicketStorage().load();

    final accessService = AccessService();
    final apiTicket = await accessService.getActiveTicket();
    if (apiTicket != null) {
      await ActiveTicketStorage().save(apiTicket);
      ticket = apiTicket;
    }

    ActiveReservation? reservation = await ActiveReservationStorage().load();
    try {
      final profile = await ProfileService().getProfile();
      if (profile != null) {
        final historyList =
            await HistoryService().getHistory(profile.userId);

        ReservationHistory? activeResFromApi;
        for (final r in historyList) {
          final st = r.status.toLowerCase();
          if (st == 'active' ||
              st == 'pending' ||
              st == 'arrived' ||
              st == 'booked' ||
              st == 'claimed') {
            activeResFromApi = r;
            break;
          }
        }

        if (activeResFromApi != null) {
          reservation = ActiveReservation(
            reservationId: activeResFromApi.reservationId,
            status: activeResFromApi.status.toLowerCase(),
            slotId: activeResFromApi.slotId,
            slotName: activeResFromApi.slotName,
            areaId: activeResFromApi.areaId,
            ticketId: activeResFromApi.ticketId,
            startTime: activeResFromApi.timestamps.created ??
                DateTime.now().toIso8601String(),
          );
          await ActiveReservationStorage().save(reservation);
        } else {
          await ActiveReservationStorage().clear();
          reservation = null;
        }
      }
    } catch (e) {
      debugPrint('Sync active reservation error: $e');
    }

    final vehicleService = VehicleService();
    List<Vehicle> vehicles = [];
    try {
      vehicles = await vehicleService.getVehicles();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _activeTicket = ticket;
        _activeReservation = reservation;

        if (vehicles.isNotEmpty) {
          _plateNumber = vehicles.first.plateNumber;
        }
        _isLoading = false;
      });

      _startElapsedTimer();
    }
  }

  void _startElapsedTimer() {
    _timer?.cancel();

    if (_activeReservation != null &&
        _activeReservation!.startTime.isNotEmpty) {
      try {
        final startTime = DateTime.parse(_activeReservation!.startTime);
        _elapsedSeconds = DateTime.now().difference(startTime).inSeconds;
        if (_elapsedSeconds < 0) _elapsedSeconds = 0;
      } catch (_) {
        _elapsedSeconds = 0;
      }
    } else if (_activeTicket != null &&
        _activeTicket!.ticketCode.isNotEmpty &&
        (_activeTicket!.status == 'active' ||
            _activeTicket!.status == 'claimed')) {
      if (_activeTicket!.claimedAt.isNotEmpty) {
        try {
          final claimedTime = DateTime.parse(_activeTicket!.claimedAt);
          _elapsedSeconds = DateTime.now().difference(claimedTime).inSeconds;
          if (_elapsedSeconds < 0) _elapsedSeconds = 0;
        } catch (_) {
          _elapsedSeconds = 0;
        }
      } else {
        _elapsedSeconds = 0;
      }
    } else {
      return;
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
    if (_activeReservation != null &&
        _activeReservation!.reservationId.isNotEmpty) {
      return true;
    }
    if (_activeTicket != null &&
        _activeTicket!.ticketCode.isNotEmpty &&
        (_activeTicket!.status == 'active' ||
            _activeTicket!.status == 'claimed')) {
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

    final service = BookingService();
    bool isSuccess = false;
    String message = 'Sesi parkir telah diselesaikan.';

    if (_activeReservation != null &&
        (_activeReservation!.status.toLowerCase() == 'active' ||
            _activeReservation!.status.toLowerCase() == 'arrived')) {
      final result =
          await service.completeReservation(_activeReservation!.reservationId);
      isSuccess = result.success;
      message = result.message;
    } else if (_activeReservation != null) {
      final result =
          await service.cancelReservation(_activeReservation!.reservationId);
      isSuccess = result.success;
      message = result.message;
    } else if (_activeTicket != null) {
      final result = await service.cancelTicket(_activeTicket!.ticketCode);
      isSuccess = result.success;
      message = result.message;
    } else {
      isSuccess = true;
    }

    if (!mounted) return;
    setState(() => _isCancelling = false);

    _timer?.cancel();
    await ActiveTicketStorage().clear();
    await ActiveReservationStorage().clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSuccess ? message : 'Sesi parkir lokal telah dibersihkan.'),
          backgroundColor: isSuccess ? Colors.green : Colors.orange,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  void _showErrorDialog(String msg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardBgDark : Colors.white,
        title: Text('Gagal',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimaryLight)),
        content: Text(msg,
            style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup',
                style: TextStyle(color: AppColors.accentLight)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = AppColors.getBackgroundColor(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const UserHeaderWidget(
                  name: 'User',
                  greeting: '',
                  title: 'Status Parkir Aktif',
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accentLight),
                        )
                      : _hasActiveSession
                          ? _buildActiveSessionView(isDark)
                          : _buildEmptyStateView(isDark),
                ),
                AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
              ],
            ),
            const FloatingTutorialWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateView(bool isDark) {
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.cardBgDark : Colors.white,
                border: Border.all(
                  color: isDark
                      ? AppColors.borderColorDark
                      : const Color(0xFFE2E8F0),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                color: Color(0xFF2563EB),
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak Ada Sesi Parkir Aktif',
              style: TextStyle(
                color: textPrimary,
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
                color: textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
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
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFF2563EB)),
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
                      backgroundColor: const Color(0xFF2563EB),
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

  Widget _buildActiveSessionView(bool isDark) {
    final rawSlot = _activeReservation?.slotName ?? '';
    final slotName = rawSlot.isNotEmpty
        ? rawSlot
        : (_activeReservation?.slotId.isNotEmpty == true
            ? _activeReservation!.slotId
            : 'Belum Dipilih');

    final rawArea = _activeReservation?.areaId.isNotEmpty == true
        ? _activeReservation!.areaId
        : (_activeTicket?.areaName.isNotEmpty == true ? _activeTicket!.areaName : '');
    String areaName = rawArea.isNotEmpty ? rawArea : 'Fakultas Teknik Unila';
    if (rawArea.toLowerCase().contains('elektro')) {
      areaName = 'Gedung Teknik Elektro';
    } else if (rawArea.toLowerCase().contains('mastek') || rawArea.toLowerCase().contains('dekanat')) {
      areaName = 'Gedung Dekanat / Mastek';
    } else if (rawArea.toLowerCase().contains('mbk') || rawArea.toLowerCase().contains('mesin')) {
      areaName = 'Gedung Teknik Mesin';
    }

    const displayVehicleType = 'MOBIL';
    final reservationStatus = _activeReservation?.status ?? 'pending';

    if (_activeReservation != null && reservationStatus == 'pending') {
      return _buildPendingReservationView(slotName, areaName, isDark);
    }

    return _buildActiveOrArrivedView(
        slotName, areaName, displayVehicleType, isDark);
  }

  Widget _buildPendingReservationView(
      String slotName, String areaName, bool isDark) {
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);
    final cardBg = AppColors.getCardBg(context);
    // Calculate remaining navigation time (15 minutes = 900 seconds)
    const int totalNavSeconds = 900;
    final int navSecondsLeft = totalNavSeconds - _elapsedSeconds;
    final bool isNavExpired = navSecondsLeft <= 0;

    String navTimerStr;
    if (isNavExpired) {
      navTimerStr = '00:00 (Waktu Habis)';
    } else {
      final m = navSecondsLeft ~/ 60;
      final s = navSecondsLeft % 60;
      navTimerStr = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Menunggu Kedatangan',
            style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // ── Timer Navigasi 15 Menit & Banner Warning Waktu Habis ────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isNavExpired
                    ? (isDark ? const Color(0xFF3F1D1D) : const Color(0xFFFEF2F2))
                    : cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isNavExpired
                      ? const Color(0xFFEF4444)
                      : (isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0)),
                  width: isNavExpired ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isNavExpired
                            ? Icons.warning_amber_rounded
                            : Icons.timer_outlined,
                        color: isNavExpired
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF2563EB),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isNavExpired
                              ? 'Waktu Navigasi 15 Menit Telah Habis!'
                              : 'Batas Waktu Menuju Slot: 15 Menit',
                          style: TextStyle(
                            color: isNavExpired
                                ? const Color(0xFFEF4444)
                                : textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isNavExpired
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          navTimerStr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isNavExpired
                        ? 'Waktu menuju tempat parkir sudah lebih dari 15 menit. Anda sangat direkomendasikan untuk melakukan Pindah Slot ke lokasi terdekat.'
                        : 'Harap tiba di tempat parkir sebelum batas waktu 15 menit berakhir.',
                    style: TextStyle(
                      color: isNavExpired
                          ? (isDark ? Colors.white70 : const Color(0xFF991B1B))
                          : textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  if (isNavExpired) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () => _showSwapSlotModal(context),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        label: const Text('Pindah Slot Terdekat Sekarang',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? AppColors.borderColorDark
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panduan Menuju Slot Parkir Anda',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ikuti petunjuk arah di bawah ini untuk mencapai slot.',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'lib/assets/parking/denah_parkir.png',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: const Color(0xFFF1F5F9),
                          child: const Center(
                            child: Icon(Icons.map_outlined,
                                color: Color(0xFF94A3B8), size: 48),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        'Lokasi Parkir',
                        areaName.isNotEmpty ? areaName : '—',
                        icon: Icons.location_on_outlined,
                        fontSize: 14,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInfoBox(
                        'Slot Parkir',
                        slotName.isNotEmpty ? slotName : '—',
                        icon: Icons.local_parking_rounded,
                        fontSize: 20,
                        isHighlighted: true,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_plateNumber.isNotEmpty)
                  _buildInfoBox(
                    'Kendaraan / Plat Nomor',
                    'MOBIL - $_plateNumber'.toUpperCase(),
                    icon: Icons.badge_outlined,
                    fontSize: 15,
                    fullWidth: true,
                    isDark: isDark,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isArriving ? null : _onArriveAtSlot,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isArriving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Saya Sudah Sampai',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _showSwapSlotModal(context),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                    label: const Text(
                      'Pindah / Swap Slot',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton.icon(
                    onPressed: _isCancelling ? null : _onKeluarParkir,
                    icon: const Icon(Icons.cancel_outlined,
                        size: 20, color: Colors.redAccent),
                    label: const Text(
                      'Batalkan Reservasi',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _showSwapSlotModal(BuildContext context) async {
    if (_activeReservation == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCardBg(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    final areaId = _activeReservation!.areaId.isNotEmpty
        ? _activeReservation!.areaId
        : 'teknik-elektro';

    final service = BookingService();
    List<ParkingSlot> availableSlots = [];
    try {
      final slots = await service.getSlots(areaId);
      availableSlots = slots
          .where((s) => s.status.toLowerCase() == 'available')
          .toList();
    } catch (_) {}

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B5CF6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pindah / Swap Slot Parkir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'Pilih slot baru yang masih tersedia di gedung ini',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (availableSlots.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Tidak ada slot kosong yang tersedia di area ini saat ini.',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ] else ...[
              Text(
                'Slot Kosong Tersedia:',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: availableSlots.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) {
                    final slot = availableSlots[idx];
                    return InkWell(
                      onTap: () async {
                        Navigator.pop(ctx);
                        _handleSwapSlot(slot.id, slot.slotNumber);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardBg2Dark : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_parking_rounded,
                                    color: Color(0xFF22C55E), size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Slot ${slot.slotNumber}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Pilih Slot',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.booking);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Lihat Semua Denah Parkir'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSwapSlot(String newSlotId, String newSlotName) async {
    if (_activeReservation == null) return;
    final bookingService = BookingService();

    final result = await bookingService.swapReservation(
        _activeReservation!.reservationId, newSlotId);

    if (!mounted) return;

    if (result.success) {
      final updated = ActiveReservation(
        reservationId: _activeReservation!.reservationId,
        status: _activeReservation!.status,
        slotId: newSlotId,
        slotName: newSlotName,
        areaId: _activeReservation!.areaId,
        ticketId: _activeReservation!.ticketId,
        startTime: _activeReservation!.startTime,
      );
      await ActiveReservationStorage().save(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil pindah ke Slot $newSlotName.'),
          backgroundColor: Colors.purple,
        ),
      );

      await _loadAllData();
    } else {
      _showErrorDialog(result.message);
    }
  }

  Future<void> _onArriveAtSlot() async {
    if (_activeReservation == null) return;
    setState(() => _isArriving = true);

    final service = BookingService();
    final result =
        await service.arriveReservation(_activeReservation!.reservationId);

    if (!mounted) return;
    setState(() => _isArriving = false);

    if (result.success) {
      final updatedRes = ActiveReservation(
        reservationId: _activeReservation!.reservationId,
        status: 'active',
        slotId: _activeReservation!.slotId,
        slotName: _activeReservation!.slotName,
        areaId: _activeReservation!.areaId,
        ticketId: _activeReservation!.ticketId,
        startTime: DateTime.now().toIso8601String(),
      );
      await ActiveReservationStorage().save(updatedRes);
      _showArriveSuccessDialog(_activeReservation!.slotName);
      await _loadAllData();
    } else {
      _showErrorDialog(result.message);
    }
  }

  void _showArriveSuccessDialog(String slotName) {
    final cardBg = AppColors.getCardBg(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF10B981),
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                'Aktivasi Berhasil!',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Selamat, Anda sudah berhasil mengaktifkan slot parkir $slotName.',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03192E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOrArrivedView(
      String slotName, String areaName, String displayVehicleType, bool isDark) {
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Kendaraan Berada di Tempat',
            style: TextStyle(color: textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Text(
            'MOBIL',
            style: TextStyle(
              color: textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_plateNumber.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardBgDark : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? AppColors.borderColorDark
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                _plateNumber,
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (context, _) {
              return Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.cardBgDark : Colors.white,
                  border: Border.all(
                    color: const Color(0xFF2563EB)
                        .withValues(alpha: _glowAnim.value),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB)
                          .withValues(alpha: _glowAnim.value * 0.3),
                      blurRadius: 36,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'lib/assets/home/mobil.png',
                    height: 110,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.directions_car_filled_rounded,
                      color: Color(0xFF2563EB),
                      size: 84,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        'Plat Nomor',
                        _plateNumber.isNotEmpty ? _plateNumber : '—',
                        icon: Icons.badge_outlined,
                        fontSize: 18,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInfoBox(
                        'Tipe Kendaraan',
                        'MOBIL',
                        icon: Icons.directions_car_outlined,
                        fontSize: 16,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        'Lokasi Parkir',
                        areaName.isNotEmpty ? areaName : '—',
                        icon: Icons.location_on_outlined,
                        fontSize: 14,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInfoBox(
                        'Slot Parkir',
                        slotName.isNotEmpty ? slotName : '—',
                        icon: Icons.local_parking_rounded,
                        fontSize: 22,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildInfoBox(
                  'Durasi Parkir',
                  _formatTime(_elapsedSeconds),
                  icon: Icons.timer_outlined,
                  fontSize: 28,
                  fullWidth: true,
                  isHighlighted: true,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isCancelling ? null : _onKeluarParkir,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
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
                        'Selesai Parkir',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    required bool isDark,
    IconData? icon,
    bool fullWidth = false,
    bool isHighlighted = false,
  }) {
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);
    final cardBg = AppColors.getCardBg(context);

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFFDBEAFE)
            : cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? const Color(0xFF2563EB)
              : (isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: textSecondary, size: 14),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: TextStyle(
                      color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                color: isHighlighted ? const Color(0xFF1E40AF) : textPrimary,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
}
