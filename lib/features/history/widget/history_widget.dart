import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../public_widget/bottom_nav_bar.dart';
import '../../public_widget/user_header_widget.dart';
import 'history_card_widget.dart';

// ── Data model sementara (akan digantikan dari repository) ────────────────────

class _HistoryItem {
  final String dari;
  final String tglDari;
  final String hingga;
  final String tglHingga;
  final String slotParkir;
  final String idTiket;
  final String kendaraan;

  const _HistoryItem({
    required this.dari,
    required this.tglDari,
    required this.hingga,
    required this.tglHingga,
    required this.slotParkir,
    required this.idTiket,
    required this.kendaraan,
  });
}

// ─── Composer ─────────────────────────────────────────────────────────────────

/// HistoryWidget: Composer untuk halaman riwayat parkir.
///
/// Tanggung jawab:
/// - Mengelola state [_navIndex] dan data [_history]
/// - Menyusun widget: Header, judul, ListView dengan HistoryCardWidget
/// - Menangani navigasi
class HistoryWidget extends StatefulWidget {
  const HistoryWidget({super.key});

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  // ── State ────────────────────────────────────────────────────────────────
  int _navIndex = 3;

  // ── Data ─────────────────────────────────────────────────────────────────
  final List<_HistoryItem> _history = List.generate(
    8,
    (_) => const _HistoryItem(
      dari: '19:33',
      tglDari: '02 Maret 2026',
      hingga: '23:01',
      tglHingga: '02 Maret 2026',
      slotParkir: 'Mall Bumi Kedaton\n(Lantai 1, A4)',
      idTiket: 'TXT-20260302-0054',
      kendaraan: 'D 12345 FE',
    ),
  );

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
        // ① Header pengguna
        UserHeaderWidget(
          name: 'Imam Ariadi',
          greeting: 'Selamat Pagi',
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

        // ③ Daftar histori
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _history.length,
            itemBuilder: (context, i) {
              final item = _history[i];
              return HistoryCardWidget(
                dari: item.dari,
                tglDari: item.tglDari,
                hingga: item.hingga,
                tglHingga: item.tglHingga,
                slotParkir: item.slotParkir,
                idTiket: item.idTiket,
                kendaraan: item.kendaraan,
              );
            },
          ),
        ),

        // ④ Bottom nav
        AppBottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
      ],
    );
  }
}
