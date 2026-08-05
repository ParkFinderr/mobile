/// AppConstants — Konstanta-konstanta global aplikasi ParkFinder.
///
/// Berisi key SharedPreferences, nama route, dan konstanta UI.
class AppConstants {
  AppConstants._();

  // ─── SharedPreferences Keys ───────────────────────────────────────────────
  static const String keyJwtToken = 'jwt_token';
  static const String keyUserRole = 'user_role';
  static const String keyActiveReservation = 'active_reservation';
  static const String keyActiveTicket = 'active_ticket';

  // ─── Role ─────────────────────────────────────────────────────────────────
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';

  // ─── UI ───────────────────────────────────────────────────────────────────
  static const double borderRadiusDefault = 12.0;
  static const double borderRadiusCard = 16.0;
  static const double borderRadiusLarge = 24.0;

  // ─── Animation Duration ───────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
}
