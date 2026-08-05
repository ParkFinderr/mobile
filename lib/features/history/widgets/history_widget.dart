import 'package:flutter/material.dart';
import 'package:mobile_front/core/routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import 'package:mobile_front/features/profile/services/profile_service.dart';
import 'package:mobile_front/features/parking/services/booking_service.dart';
import 'package:mobile_front/features/parking/models/parking_area.dart';
import '../services/history_service.dart';
import '../models/reservation_history.dart';
import 'package:mobile_front/shared/widgets/shared_widgets.dart';
import 'history_card_widget.dart';

class HistoryWidget extends StatefulWidget {
  const HistoryWidget({super.key});

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  int _navIndex = 3;
  String _userName = 'User';
  String? _photoUrl;
  bool _isLoading = true;
  String? _errorMessage;
  List<ReservationHistory> _history = [];
  Map<String, String> _areaNames = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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
        Navigator.pushReplacementNamed(context, AppRoutes.profil);
        break;
    }
  }

  DateTime? _parseIso(String? isoStr) {
    if (isoStr == null || isoStr.isEmpty) return null;
    return DateTime.tryParse(isoStr)?.toLocal();
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '14:30';
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDateIndo(DateTime? dateTime) {
    if (dateTime == null) return '24 Okt 2026';
    final day = dateTime.day.toString().padLeft(2, '0');
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    return '$day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = AppColors.getBackgroundColor(context);
    final textPrimary = AppColors.getTextPrimary(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // User Header
                UserHeaderWidget(
                  name: _userName,
                  greeting: '',
                  title: 'ParkFinder',
                  photoUrl: _photoUrl,
                ),
                const SizedBox(height: 16),

                // Riwayat Parkir Section Title Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Riwayat Parkir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.accentDark : AppColors.accentLight,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.filter_list_rounded,
                            size: 16,
                            color: isDark ? AppColors.accentDark : AppColors.accentLight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Konten Utama
                Expanded(
                  child: _buildMainContent(isDark, textPrimary),
                ),

                // Bottom Nav
                AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
              ],
            ),
            const FloatingTutorialWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isDark, Color textPrimary) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: textPrimary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
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
                color: Color(0xFF94A3B8),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada riwayat parkir',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan lakukan reservasi slot parkir terlebih dahulu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.booking);
                },
                icon: const Icon(Icons.local_parking_rounded),
                label: const Text('Cari Slot Parkir'),
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

        final areaName = _areaNames[item.areaId] ??
            (item.areaId.isNotEmpty ? item.areaId : 'Area Parkir FT Unila');
        final slotLabel = '$areaName\n(Slot ${item.slotName})';

        return HistoryCardWidget(
          dari: dariTime,
          tglDari: dariDate,
          hingga: hinggaTime,
          tglHingga: hinggaDate,
          slotParkir: slotLabel,
          idTiket: item.ticketId,
          kendaraan: item.plateNumber.isNotEmpty ? item.plateNumber : 'Mobil',
          status: item.status,
        );
      },
    );
  }
}
