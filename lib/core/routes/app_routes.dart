/// AppRoutes — Konstanta nama route seluruh aplikasi ParkFinder.
///
/// Semua navigasi harus menggunakan konstanta ini, bukan string literal.
/// Didefinisikan di core/routes/ agar dapat diakses dari seluruh feature.
class AppRoutes {
  AppRoutes._();

  static const String splashScreen = '/';
  static const String welcome = '/welcome';
  static const String welcomeTransition = '/welcome-transition';
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
  static const String vehicleManagement = '/vehicle-management';
}
