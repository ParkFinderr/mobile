import 'dart:convert';
import '../../../core/network/api_service.dart';
import '../../../core/storage/active_ticket_storage.dart';
import '../../../core/storage/active_reservation_storage.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<String?> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final token = body['data']?['token'];
        if (token != null) {
          await _apiService.setToken(token);
          return null;
        }
      }

      final body = jsonDecode(response.body);
      return body['message'] ?? 'Login gagal. Periksa email dan password.';
    } catch (e) {
      print('Login error: $e');
      return 'Terjadi kesalahan. Periksa koneksi Anda.';
    }
  }

  Future<String?> register(String name, String email, String phone, String password, String plateNumber) async {
    try {
      final response = await _apiService.post(
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
        return null;
      }

      final body = jsonDecode(response.body);
      return body['message'] ?? 'Pendaftaran gagal. Silakan coba lagi.';
    } catch (e) {
      print('Register error: $e');
      return 'Terjadi kesalahan jaringan. Periksa koneksi Anda.';
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout', requireAuth: true);
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _apiService.clearToken();
      await ActiveTicketStorage().clear();
      await ActiveReservationStorage().clear();
    }
  }
}
