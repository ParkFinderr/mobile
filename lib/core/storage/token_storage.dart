import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// TokenStorage — Penyimpanan terpusat JWT token.
///
/// Dipisahkan dari ApiService agar ApiService fokus pada HTTP requests.
/// Semua operasi token dilakukan melalui class ini, bukan langsung ke SharedPreferences.
class TokenStorage {
  static const String _key = AppConstants.keyJwtToken;

  /// Simpan token ke SharedPreferences.
  Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  /// Ambil token dari SharedPreferences. Null jika belum login.
  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// Hapus token (logout).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Cek apakah user sudah login (token ada).
  Future<bool> isLoggedIn() async {
    final token = await load();
    return token != null && token.isNotEmpty;
  }
}
