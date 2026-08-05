import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// RoleStorage — Penyimpanan role pengguna (user/admin).
///
/// Digunakan untuk menentukan akses setelah login.
class RoleStorage {
  static const String _key = AppConstants.keyUserRole;

  Future<void> save(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, role);
  }

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<bool> isUser() async {
    final role = await load();
    return role == AppConstants.roleUser;
  }
}
