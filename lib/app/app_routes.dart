import 'package:flutter/material.dart';

import '../features/booking/page/booking_page.dart';
import '../features/detail_booking/page/detail_booking_page.dart';
import '../features/history/page/history_page.dart';
import '../features/home/page/home_page.dart';
import '../features/home/page/status_kendaraan_page.dart';
import '../features/login/page/login_page.dart';
import '../features/profil/page/edit_profil_page.dart';
import '../features/profil/page/pengaturan_page.dart';
import '../features/profil/page/vehicle_management_page.dart';
import '../features/profil/page/profil_page.dart';
import '../features/register/page/register_page.dart';
import '../features/scan_berhasil/page/scan_berhasil_page.dart';
import '../features/welcome_scan/service/scan_service.dart';
import '../features/splash_screen/page/splash_screen_page.dart';
import '../features/welcome/page/welcome_page.dart';
import '../features/welcome/page/welcome_transition_page.dart';
import '../features/welcome_scan/page/welcome_scan_page.dart';

class AppRoutes {
  static const String splashScreen = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String welcomeScan = '/welcome-scan';
  static const String scanBerhasil = '/scan-berhasil';
  static const String home = '/home';
  static const String booking = '/booking';
  static const String detailBooking = '/detail-booking';
  static const String history = '/history';
  static const String profil = '/profil';
  static const String editProfil = '/edit-profil';
  static const String pengaturan = '/pengaturan';
  static const String statusKendaraan = '/status-kendaraan';
  static const String welcomeTransition = '/welcome-transition';
  static const String vehicleManagement = '/vehicle-management';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreenPage());
      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.welcomeTransition:
        return MaterialPageRoute(
            builder: (_) => const WelcomeTransitionPage());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case AppRoutes.welcomeScan:
        return MaterialPageRoute(builder: (_) => const WelcomeScanPage());
      case AppRoutes.scanBerhasil:
        final ticketData = settings.arguments as TicketData?;
        return MaterialPageRoute(
            builder: (_) => ScanBerhasilPage(ticketData: ticketData));
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case AppRoutes.booking:
        return MaterialPageRoute(builder: (_) => const BookingPage());
      case AppRoutes.detailBooking:
        final areaId = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => DetailBookingPage(areaId: areaId ?? ''));
      case AppRoutes.history:
        return MaterialPageRoute(builder: (_) => const HistoryPage());
      case AppRoutes.profil:
        return MaterialPageRoute(builder: (_) => const ProfilPage());
      case AppRoutes.editProfil:
        return MaterialPageRoute(builder: (_) => const EditProfilPage());
      case AppRoutes.pengaturan:
        return MaterialPageRoute(builder: (_) => const PengaturanPage());
      case AppRoutes.statusKendaraan:
        return MaterialPageRoute(
            builder: (_) => const StatusKendaraanPage());
      case AppRoutes.vehicleManagement:
        return MaterialPageRoute(builder: (_) => const VehicleManagementPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: const Color(0xFF0D1628),
            body: const Center(
              child: Text(
                'Halaman tidak ditemukan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
    }
  }
}
