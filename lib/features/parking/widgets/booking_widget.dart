import 'package:flutter/material.dart';
import 'package:mobile_front/core/routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../core/config/app_config.dart';
import 'package:mobile_front/shared/widgets/shared_widgets.dart';
import '../services/booking_service.dart';

class BookingWidget extends StatefulWidget {
  const BookingWidget({super.key});

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  final _searchCtrl = TextEditingController();
  int _navIndex = 1;
  bool _isLoading = true;

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
          final occupancy =
              total > 0 ? ((total - available) / total * 100) : 0.0;
          return ParkingItemData(
            id: a.id,
            name: a.name,
            occupancyPercent: occupancy,
            availableSlotLabel: '$available Slot Tersedia',
          );
        }).toList();
        _isLoading = false;
      });
    }
  }

  List<ParkingItemData> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _allParking;
    return _allParking.where((e) => e.name.toLowerCase().contains(q)).toList();
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

  String _getBuildingCdnUrl(String name, int index) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('elektro')) {
      return '${AppConfig.storageUrl}/gedung/elektro.png';
    } else if (nameLower.contains('mastek') || nameLower.contains('dekanat')) {
      return '${AppConfig.storageUrl}/gedung/mastek.png';
    } else if (nameLower.contains('mbk') || nameLower.contains('mesin')) {
      return '${AppConfig.storageUrl}/gedung/mbk.png';
    }
    final photos = ['elektro.png', 'mastek.png', 'mbk.png'];
    return '${AppConfig.storageUrl}/gedung/${photos[index % photos.length]}';
  }

  String _getBuildingAssetPath(String name, int index) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('elektro')) {
      return 'lib/assets/parking/elektro.png';
    } else if (nameLower.contains('mastek') || nameLower.contains('dekanat')) {
      return 'lib/assets/parking/mastek.png';
    } else if (nameLower.contains('mbk') || nameLower.contains('mesin')) {
      return 'lib/assets/parking/mbk.png';
    }
    final photos = ['elektro.png', 'mastek.png', 'mbk.png'];
    return 'lib/assets/parking/${photos[index % photos.length]}';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = AppColors.getBackgroundColor(context);
    final cardBg = AppColors.getCardBg(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Bar (Cari Lokasi Parkir)
                        const UserHeaderWidget(
                          name: 'User',
                          greeting: '',
                          title: 'Cari Lokasi Parkir',
                        ),
                        const SizedBox(height: 16),

                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SearchBarWidget(
                            controller: _searchCtrl,
                            hintText: 'Cari gedung atau area...',
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // List Area Cards
                        _isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: _filtered.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.detailBooking,
                                            arguments: item.id,
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Header Image
                                            ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                              child: SizedBox(
                                                height: 160,
                                                width: double.infinity,
                                                child: Image.network(
                                                  _getBuildingCdnUrl(item.name, index),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => Image.asset(
                                                    _getBuildingAssetPath(item.name, index),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => Container(
                                                      color: const Color(0xFFF1F5F9),
                                                      child: const Icon(Icons.apartment_rounded, size: 60),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Body Details
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.name,
                                                    style: TextStyle(
                                                      fontSize: 16,
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
                                                        'Fakultas Teknik Unila, Gedung B',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Divider(
                                                    height: 1,
                                                    color: isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 8,
                                                        height: 8,
                                                        decoration: const BoxDecoration(
                                                          color: Color(0xFF10B981),
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        item.availableSlotLabel,
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFF10B981),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Bottom Navigation Bar
                AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
              ],
            ),
            const FloatingTutorialWidget(),
          ],
        ),
      ),
    );
  }
}
