import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../profil/service/profile_service.dart';
import '../../booking/service/booking_service.dart';
import '../service/history_service.dart';
import '../model/reservation_history.dart';
import '../../public_widget/bottom_nav_bar.dart';
import '../../public_widget/user_header_widget.dart';
import 'history_card_widget.dart';

/// HistoryWidget: Composer untuk halaman riwayat parkir.
///
/// Tanggung jawab:
/// - Mengambil data profil untuk mendapatkan userId
/// - Mengambil data riwayat reservasi & daerah parkir (areas) secara real-time dari backend
/// - Mengelola state loading, empty, dan error
/// - Menyusun widget: Header, judul, daftar riwayat dengan HistoryCardWidget
/// - Menangani navigasi
class HistoryWidget extends StatefulWidget {
  const HistoryWidget({super.key});

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  // ── State ────────────────────────────────────────────────────────────────
  int _navIndex = 3;
  String _userName = 'User';
  String _greeting = 'Selamat Datang';
  String? _photoUrl;
  bool _isLoading = true;
  String? _errorMessage;
  List<ReservationHistory> _history = [];
  Map<String, String> _areaNames = {};

  @override
  void initState() {
    super.initState();
    _greeting = greetingFromHour(context);
    _loadData();
  }

  // ── Data Fetching ────────────────────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await ProfileService().getProfile();
      if (profile == null) {
        throw Exception('Gagal memuat profil pengguna.');
      }

      if (mounted) {
        setState(() {
          _userName = profile.name;
          _photoUrl = profile.photoUrl;
        });
      }

      // Fetch history and areas in parallel to resolve areaId -> areaName
      final results = await Future.wait([
        HistoryService().getHistory(profile.userId),
        BookingService().getAreas(),
      ]);

      final historyList = results[0] as List<ReservationHistory>;
      final areaList = results[1] as List<ParkingArea>;

      final areaMap = {for (var a in areaList) a.id: a.name};

      if (mounted) {
        setState(() {
          _history = historyList;
          _areaNames = areaMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
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
      case 4:
        Navigator.pushNamed(context, AppRoutes.profil);
        break;
    }
  }

  // ── Formatting Utilities ─────────────────────────────────────────────────
  DateTime? _parseIso(String? isoStr) {
    if (isoStr == null || isoStr.isEmpty) return null;
    return DateTime.tryParse(isoStr)?.toLocal();
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDateIndo(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final day = dateTime.day.toString().padLeft(2, '0');
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    return '$day $month $year';
  }

  // ── Build (Composer) ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ① Header pengguna
        UserHeaderWidget(
          name: _userName,
          greeting: _greeting,
          photoUrl: _photoUrl,
        ),
        const SizedBox(height: 12),

        // ② Judul halaman
        const Text(
          'History',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),

        // ③ Konten utama (Loading, Error, Empty, atau List)
        Expanded(
          child: _buildMainContent(),
        ),

        // ④ Bottom nav
        AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
      ],
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.borderAccent),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.borderColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.history_toggle_off,
                color: AppColors.textSecondary,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum ada riwayat parkir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan lakukan reservasi slot parkir terlebih dahulu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.booking);
                },
                icon: const Icon(Icons.local_parking),
                label: const Text('Cari Slot Parkir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.borderAccent,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _history.length,
      itemBuilder: (context, i) {
        final item = _history[i];
        final dtDari = _parseIso(item.timestamps.created);
        final dtHingga = _parseIso(item.timestamps.completed);

        final dariTime = _formatTime(dtDari);
        final dariDate = _formatDateIndo(dtDari);
        final hinggaTime = _formatTime(dtHingga);
        final hinggaDate = _formatDateIndo(dtHingga);

        final areaName = _areaNames[item.areaId] ?? 'Area Parkir';
        final slotLabel = '$areaName\n(Slot ${item.slotName})';

        return HistoryCardWidget(
          dari: dariTime,
          tglDari: dariDate,
          hingga: hinggaTime,
          tglHingga: hinggaDate,
          slotParkir: slotLabel,
          idTiket: item.ticketId,
          kendaraan: item.plateNumber,
          status: item.status,
        );
      },
    );
  }
}
