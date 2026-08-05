import 'dart:convert';
import '../../../core/network/api_service.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/storage/active_ticket_storage.dart';
import '../../../core/storage/active_reservation_storage.dart';
import '../../../core/storage/role_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../models/auth_result.dart';

/// AuthService — Service layer autentikasi pengguna.
///
/// Menangani login, register, dan logout via REST API.
/// Token disimpan via [TokenStorage], bukan di service ini.
///
/// Flow: AuthProvider → AuthService → REST API
class AuthService {
  final ApiService _api = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();
  final RoleStorage _roleStorage = RoleStorage();

  /// Login dengan email dan password.
  ///
  /// Mengembalikan [AuthResult.success()] jika berhasil,
  /// atau [AuthResult.failure(message)] jika gagal.
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _api.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final token = body['data']?['token'] as String?;
        final role = body['data']?['user']?['role'] as String?;

        if (token != null) {
          // Validasi role: hanya user biasa yang boleh masuk
          if (role == null || role != AppConstants.roleUser) {
            return const AuthResult.failure(
              'Aplikasi ini khusus untuk pengguna parkir. '
              'Admin/Super Admin silakan gunakan Web Admin Panel.',
            );
          }

          await _tokenStorage.save(token);
          await _roleStorage.save(role);
          await ActiveTicketStorage().clear();
          await ActiveReservationStorage().clear();
          return const AuthResult.success();
        }
      }

      final body = jsonDecode(response.body);
      return AuthResult.failure(
        body['message'] as String? ??
            'Login gagal. Periksa email dan password.',
      );
    } catch (e) {
      return const AuthResult.failure(
        'Terjadi kesalahan jaringan. Periksa koneksi Anda.',
      );
    }
  }

  /// Register akun baru.
  ///
  /// Mengembalikan [AuthResult.success()] jika berhasil,
  /// atau [AuthResult.failure(message)] jika gagal.
  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String plateNumber,
  }) async {
    try {
      final response = await _api.post(
        '/auth/register',
        body: {
          'name': name,
          'email': email,
          'phoneNumber': phone,
          'password': password,
          'defaultLicensePlate': plateNumber,
          'vehicleType': 'mobil',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Register berhasil — jangan simpan token (user harus login manual)
        return const AuthResult.success();
      }

      final body = jsonDecode(response.body);
      return AuthResult.failure(
        body['message'] as String? ?? 'Pendaftaran gagal. Silakan coba lagi.',
      );
    } catch (e) {
      return const AuthResult.failure(
        'Terjadi kesalahan jaringan. Periksa koneksi Anda.',
      );
    }
  }

  /// Logout — hapus semua data lokal dan panggil endpoint logout.
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', requireAuth: true);
    } catch (_) {
      // Tetap lanjutkan logout meskipun API error
    } finally {
      await _tokenStorage.clear();
      await ActiveTicketStorage().clear();
      await ActiveReservationStorage().clear();
      await _roleStorage.clear();
    }
  }

  /// Cek apakah user sudah login (token ada di storage).
  Future<bool> isLoggedIn() => _tokenStorage.isLoggedIn();
}
