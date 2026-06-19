import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/storage/active_ticket_storage.dart';
import '../../../core/storage/active_reservation_storage.dart';
import '../../welcome_scan/service/scan_service.dart';
import '../../access/service/access_service.dart';
import '../../../core/pwa/pwa_install_service.dart';
import '../../../core/pwa/pwa_install_dialog.dart';
import '../../booking/service/booking_service.dart';
import '../../profil/service/profile_service.dart';
import '../../public_widget/bottom_nav_bar.dart';
import '../../public_widget/user_header_widget.dart';
import '../../public_widget/search_bar_widget.dart';
import '../../public_widget/section_title_widget.dart';
import '../../public_widget/parking_list_item_widget.dart';
import '../../public_widget/end_session_dialog_widget.dart';
import 'hero_banner_widget.dart';
import 'status_card_widget.dart';

/// HomeWidget: Composer untuk halaman utama (dashboard).
///
/// Tanggung jawab:
/// - Mengelola state [_navIndex] dan data [_parkingList]
/// - Menyusun widget: Header, Banner, StatusCards, SearchBar, ParkingList
/// - Menangani navigasi dan dialog akhiri sesi
class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  // ── State ────────────────────────────────────────────────────────────────
  int _navIndex = 0;
  bool _isLoading = true;
  String? _error;
  List<ParkingItemData> _parkingList = [];
  String _userName = 'User';
  String _greeting = 'Selamat Datang';
  String? _photoUrl;

  bool _isPwaStandalone = false;
  bool _canInstallPwa = false;
  StreamSubscription? _installSubscription;
  bool _hasActiveTicket = false;
  TicketData? _activeTicket;
  ActiveReservation? _activeReservation;

  @override
  void initState() {
    super.initState();
    _fetchAreas();
    _loadProfile();
    _initPwaInstall();
    _checkActiveTicket();
  }

  Future<void> _checkActiveTicket() async {
    final accessService = AccessService();
    final apiTicket = await accessService.getActiveTicket();
    if (apiTicket != null) {
      await ActiveTicketStorage().save(apiTicket);
    }
    final ticket = await ActiveTicketStorage().load();
    final reservation = await ActiveReservationStorage().load();
    if (mounted) {
      setState(() {
        _activeTicket = ticket;
        _hasActiveTicket = ticket != null && ticket.ticketCode.isNotEmpty && ticket.status == 'active';
        _activeReservation = reservation;
      });
    }
  }

  @override
  void dispose() {
    _installSubscription?.cancel();
    super.dispose();
  }

  void _initPwaInstall() {
    if (kIsWeb) {
      _isPwaStandalone = PwaInstallService.instance.isStandalone;
      PwaInstallService.instance.isInstallPromptAvailable().then((avail) {
        if (mounted) setState(() => _canInstallPwa = avail);
      });

      _installSubscription =
          PwaInstallService.instance.onInstallAvailable.listen((_) {
        if (mounted) {
          setState(() => _canInstallPwa = true);
        }
      });
    }
  }

  void _loadProfile() {
    _greeting = greetingFromHour(context);
    ProfileService().getProfile().then((profile) {
      if (mounted && profile != null) {
        setState(() {
          _userName = profile.name;
          _photoUrl = profile.photoUrl;
        });
      }
    });
  }

  Future<void> _fetchAreas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final service = BookingService();
    final areas = await service.getAreas();

    if (!mounted) return;

    if (areas.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat data parkir.';
      });
      return;
    }

    setState(() {
      _parkingList = areas.map((a) {
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

  // ── Handlers ───────────────────────────────────────────────────────────────
  void _onNavTap(int idx) async {
    setState(() => _navIndex = idx);
    switch (idx) {
      case 1:
        Navigator.pushNamed(context, AppRoutes.booking).then((_) => _checkActiveTicket());
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

  void _showEndSessionDialog() {
    showDialog(
      context: context,
      builder: (_) => EndSessionDialogWidget(
        vehiclePlate: 'D 12345 FE',
        parkingDuration: '3 Jam 10 Menit',
        onConfirm: () => Navigator.pop(context),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildInstallIndicator() {
    if (_isPwaStandalone) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 14),
            SizedBox(width: 6),
            Text(
              'Aplikasi Terinstal',
              style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (!_canInstallPwa && !isIOS) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () async {
        final available = await PwaInstallService.instance.isInstallPromptAvailable();
        if (available) {
          if (mounted) {
            showDialog(
              context: context,
              barrierColor: Colors.black.withOpacity(0.55),
              builder: (_) => PwaInstallDialog(onDismiss: () {}),
            ).then((_) {
              PwaInstallService.instance.isInstallPromptAvailable().then((avail) {
                if (mounted) setState(() => _canInstallPwa = avail);
              });
            });
          }
        } else {
          if (isIOS) {
            if (mounted) {
              showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.55),
                builder: (_) => PwaSafariInstallDialog(onDismiss: () {}),
              ).then((_) {
                PwaInstallService.instance.isInstallPromptAvailable().then((avail) {
                  if (mounted) setState(() => _canInstallPwa = avail);
                });
              });
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF00D2FF).withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.download_for_offline_rounded, color: Color(0xFF00D2FF), size: 14),
            SizedBox(width: 6),
            Text(
              'Install Aplikasi',
              style: TextStyle(color: Color(0xFF00D2FF), fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketStatusBanner() {
    String titleText = '⚠ Tiket Belum Aktif';
    String descText = 'Untuk melakukan booking slot parkir, silakan scan tiket masuk terlebih dahulu.';
    bool isSuccess = false;
    bool showScanButton = true;

    if (_activeTicket != null && _activeTicket!.ticketCode.isNotEmpty) {
      final st = _activeTicket!.status.toLowerCase();
      if (st == 'active') {
        titleText = '✓ Tiket Aktif';
        descText = 'Anda dapat melakukan booking slot parkir.';
        isSuccess = true;
        showScanButton = false;
      } else if (st == 'pending' || st == 'claimed' || st == '') {
        titleText = '⚠ Tiket Belum Aktif';
        descText = 'Tiket Anda sudah diverifikasi namun belum aktif. Silakan scan tiket parkir terlebih dahulu.';
        showScanButton = true;
        isSuccess = false;
      } else {
        titleText = '⚠ Tiket Tidak Aktif';
        descText = 'Tiket Anda sudah checkout, kedaluwarsa, atau tidak valid. Silakan scan tiket baru.';
        showScanButton = true;
        isSuccess = false;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSuccess 
              ? const Color(0xFF00D2FF).withOpacity(0.08) 
              : const Color(0xFFEF5350).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSuccess 
                ? const Color(0xFF00D2FF).withOpacity(0.25) 
                : const Color(0xFFEF5350).withOpacity(0.25),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSuccess 
                    ? const Color(0xFF00D2FF).withOpacity(0.15) 
                    : const Color(0xFFEF5350).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess 
                    ? Icons.check_circle_outline_rounded 
                    : Icons.warning_amber_rounded,
                color: isSuccess ? const Color(0xFF00D2FF) : const Color(0xFFEF5350),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: TextStyle(
                      color: isSuccess ? const Color(0xFF00D2FF) : const Color(0xFFEF5350),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descText,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (showScanButton) ...[
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.welcomeScan).then((_) => _checkActiveTicket());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF5350),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Scan Tiket',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Build (Composer) ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ① Header pengguna
                UserHeaderWidget(
                  name: _userName,
                  greeting: _greeting,
                  photoUrl: _photoUrl,
                ),
                const SizedBox(height: 16),

                // PWA Install Status Indicator
                if (kIsWeb) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildInstallIndicator(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Ticket Status Banner
                _buildTicketStatusBanner(),
                const SizedBox(height: 16),

                // ② Hero banner
                const HeroBannerWidget(),
                const SizedBox(height: 16),

                // ③ Status cards (horizontal scroll)
                _buildStatusCards(),
                const SizedBox(height: 20),

                // ④ Search bar (read-only, navigasi ke booking)
                SearchBarWidget(
                  readOnly: true,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.booking).then((_) => _checkActiveTicket());
                  },
                ),
                const SizedBox(height: 20),

                // ⑤ Section parkir tersedia
                const SectionTitleWidget(
                  title: 'Gedung Parkir yang Tersedia',
                ),
                const SizedBox(height: 12),

                // ⑥ Daftar parkir / loading / error / empty
                _buildParkingSection(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ⑦ Bottom nav bar
        AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
      ],
    );
  }

  // ── Private Builders ───────────────────────────────────────────────────────

  Widget _buildParkingSection() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            children: [
              const Icon(Icons.cloud_off_rounded,
                  color: AppColors.textSecondary, size: 40),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _fetchAreas,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                  child: const Text('Coba Lagi',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_parkingList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Belum ada gedung parkir tersedia.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _parkingList
            .map((item) => ParkingListItemWidget(
                  item: item,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.detailBooking,
                      arguments: item.id,
                    ).then((_) => _checkActiveTicket());
                  },
                ))
            .toList(),
      ),
    );
  }

  Widget _buildStatusCards() {
    List<Widget> cards = [];

    if (!_hasActiveTicket) {
      cards.add(
        const StatusCardWidget(
          title: 'Status Tiket\nBelum Aktif',
          cardImage: StatusCardImage.tiket,
          subtitle: 'Silakan scan tiket masuk Anda',
          width: 140,
        ),
      );
    } else {
      cards.add(
        const StatusCardWidget(
          title: 'Status Tiket\nAktif',
          cardImage: StatusCardImage.tiket,
          subtitle: 'Tiket berhasil diverifikasi',
          width: 140,
        ),
      );

      cards.add(const SizedBox(width: 10));

      if (_activeReservation == null) {
        cards.add(
          const StatusCardWidget(
            title: 'Status Booking\nBelum Booking',
            cardImage: StatusCardImage.waiting,
            subtitle: 'Pilih gedung parkir untuk booking',
            width: 150,
          ),
        );
      } else {
        cards.add(
          StatusCardWidget(
            title: 'Status Booking\nAktif',
            cardImage: StatusCardImage.waiting,
            subtitle: 'Slot ${_activeReservation!.slotName.isNotEmpty ? _activeReservation!.slotName : "-"}\nMenunggu kedatangan',
            width: 160,
          ),
        );
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cards,
      ),
    );
  }
}
