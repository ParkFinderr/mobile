import 'dart:convert';
import '../../../core/network/api_service.dart';
import '../model/vehicle.dart';

/// VehicleService — Service layer kendaraan pengguna.
///
/// Menangani:
/// - GET    /users/profile (data.vehicles)   → getVehicles()
/// - POST   /users/vehicles                   → addVehicle()
/// - DELETE /users/vehicles/{plateNumber}     → deleteVehicle()
///
/// Tidak ada mock/dummy data. Semua data berasal dari backend.
class VehicleService {
  final ApiService _apiService = ApiService();

  /// Ambil daftar kendaraan dari GET /users/profile → data.vehicles.
  ///
  /// GET /users/vehicles (standalone) hanya untuk Super Admin (403).
  /// Source of truth kendaraan ada di dalam profile response.
  Future<List<Vehicle>> getVehicles() async {
    final response = await _apiService.get('/users/profile', requireAuth: true);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final items = body['data']?['vehicles'] as List<dynamic>?;
      if (items != null) {
        return items.map((json) => Vehicle.fromJson(json as Map<String, dynamic>)).toList();
      }
    }

    return [];
  }

  /// Tambah kendaraan baru ke akun pengguna.
  ///
  /// [plateNumber] — Nomor plat kendaraan (wajib, tidak boleh kosong)
  /// [vehicleType] — Jenis kendaraan, contoh: 'motor', 'mobil' (wajib)
  ///
  /// Returns: Vehicle yang baru ditambahkan, atau null jika gagal.
  Future<Vehicle?> addVehicle({
    required String plateNumber,
    required String vehicleType,
  }) async {
    final response = await _apiService.post(
      '/users/vehicles',
      body: {
        'plateNumber': plateNumber,
        'vehicleType': vehicleType,
      },
      requireAuth: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);

      Map<String, dynamic>? vehicleJson;
      if (body is Map<String, dynamic> && body['data'] is Map) {
        vehicleJson = body['data'] as Map<String, dynamic>;
      }

      if (vehicleJson != null) {
        return Vehicle.fromJson(vehicleJson);
      }
    }

    return null;
  }

  /// Hapus kendaraan berdasarkan plat nomor.
  ///
  /// Backend menggunakan plat nomor sebagai identifier di URL path.
  /// Contoh: DELETE /users/vehicles/B%201234%20CD
  ///
  /// [plateNumber] — Plat nomor kendaraan (wajib, URL-encoded otomatis)
  ///
  /// Returns: true jika berhasil, false jika gagal.
  Future<bool> deleteVehicle(String plateNumber) async {
    final encodedPlate = Uri.encodeComponent(plateNumber);
    final response = await _apiService.delete(
      '/users/vehicles/$encodedPlate',
      requireAuth: true,
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Ambil error message dari response body.
  ///
  /// Helper untuk menampilkan pesan error dari backend ke user.
  static String extractErrorMessage(String responseBody, String fallback) {
    try {
      final body = jsonDecode(responseBody);
      if (body is Map && body['message'] != null) {
        return body['message'].toString();
      }
    } catch (_) {}
    return fallback;
  }
}
