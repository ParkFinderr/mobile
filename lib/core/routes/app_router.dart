import 'package:flutter/material.dart';

import '../../features/parking/pages/booking_page.dart';
import '../../features/parking/pages/detail_booking_page.dart';
import '../../features/history/pages/history_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/home/pages/status_kendaraan_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/profile/pages/edit_profile_page.dart';
import '../../features/profile/pages/settings_page.dart';
import '../../features/profile/pages/vehicle_management_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/scan/pages/scan_berhasil_page.dart';
import '../../features/splash/pages/splash_page.dart';
import '../../features/welcome/pages/welcome_page.dart';
import '../../features/welcome/pages/welcome_transition_page.dart';
import '../../features/scan/pages/welcome_scan_page.dart';
import 'package:mobile_front/features/scan/models/ticket_data.dart';
import 'app_routes.dart';

/// AppRouter — Generator route terpusat untuk seluruh navigasi aplikasi.
///
/// Semua route harus didaftarkan di sini.
/// Tidak boleh ada `Navigator.push` dengan MaterialPageRoute yang tidak terdaftar.
///
/// Ditempatkan di core/routes/ sesuai Feature-Based Architecture.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splashScreen:
        return _buildRoute(const SplashScreenPage(), settings);

      case AppRoutes.welcome:
        return _buildRoute(const WelcomePage(), settings);

      case AppRoutes.welcomeTransition:
        return _buildRoute(const WelcomeTransitionPage(), settings);

      case AppRoutes.login:
        return _buildRoute(const LoginPage(), settings);

      case AppRoutes.register:
        return _buildRoute(const RegisterPage(), settings);

      case AppRoutes.welcomeScan:
        return _buildRoute(const WelcomeScanPage(), settings);

      case AppRoutes.scanBerhasil:
        final ticketData = settings.arguments as TicketData?;
        return _buildRoute(ScanBerhasilPage(ticketData: ticketData), settings);

      case AppRoutes.home:
        return _buildRoute(const HomePage(), settings);

      case AppRoutes.booking:
        return _buildRoute(const BookingPage(), settings);

      case AppRoutes.detailBooking:
        final areaId = settings.arguments as String? ?? '';
        return _buildRoute(DetailBookingPage(areaId: areaId), settings);

      case AppRoutes.history:
        return _buildRoute(const HistoryPage(), settings);

      case AppRoutes.profil:
        return _buildRoute(const ProfilPage(), settings);

      case AppRoutes.editProfil:
        return _buildRoute(const EditProfilPage(), settings);

      case AppRoutes.pengaturan:
        return _buildRoute(const PengaturanPage(), settings);

      case AppRoutes.statusKendaraan:
        return _buildRoute(const StatusKendaraanPage(), settings);

      case AppRoutes.vehicleManagement:
        return _buildRoute(const VehicleManagementPage(), settings);

      default:
        return _buildRoute(_NotFoundPage(routeName: settings.name), settings);
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}

/// Halaman 404 — Route tidak ditemukan.
class _NotFoundPage extends StatelessWidget {
  final String? routeName;

  const _NotFoundPage({this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1628),
      body: Center(
        child: Text(
          routeName != null
              ? 'Halaman "$routeName" tidak ditemukan'
              : 'Halaman tidak ditemukan',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
