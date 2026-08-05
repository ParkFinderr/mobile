import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../models/profile_data.dart';
import '../models/vehicle.dart';
import 'package:mobile_front/features/notification/services/notification_service.dart';

/// ProfileService — Service layer profil pengguna.
///
/// Menangani GET /users/profile dan PUT /users/profile.
/// Model ProfileData & UpdateProfileResult ada di profile/models/.
///
/// Flow: ProfileProvider → ProfileService → REST API
class ProfileService {
  final ApiService _api = ApiService();

  Future<ProfileData?> getProfile() async {
    try {
      final response = await _api.get('/users/profile', requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ProfileData.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('[ProfileService] getProfile error: $e');
      return null;
    }
  }

  Future<UpdateProfileResult> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      final payload = {'name': name, 'phoneNumber': phoneNumber};
      debugPrint('[ProfileService] PUT /users/profile payload: $payload');

      final response = await _api.put(
        '/users/profile',
        body: payload,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final msg = body['message'] as String? ?? 'Profil berhasil diperbarui.';
        NotificationService.addNotification(
          title: 'Profil Diperbarui',
          subtitle: 'Data profil Anda ($name) telah berhasil diperbarui.',
          icon: Icons.person_outline_rounded,
          iconColor: const Color(0xFF2563EB),
        );
        return UpdateProfileResult.ok(msg);
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return UpdateProfileResult.failure(
        body['message'] as String? ?? 'Gagal menyimpan profil.',
      );
    } catch (e) {
      return UpdateProfileResult.failure(
        'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<UpdateProfileResult> uploadPhoto({
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      debugPrint(
        '[ProfileService] POST /users/profile/photo file: $fileName, size: ${bytes.length} bytes',
      );
      final response = await _api.multipartPost(
        '/users/profile/photo',
        fileBytes: bytes,
        fileName: fileName,
        fieldName: 'image',
        requireAuth: true,
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        final msg = body['message'] as String? ?? 'Foto profil berhasil diunggah.';
        NotificationService.addNotification(
          title: 'Foto Profil Diperbarui',
          subtitle: 'Foto profil baru Anda berhasil disimpan.',
          icon: Icons.account_circle_outlined,
          iconColor: const Color(0xFF10B981),
        );
        return UpdateProfileResult.ok(msg);
      }
      return UpdateProfileResult.failure(
        body['message'] as String? ?? 'Gagal mengunggah foto profil.',
      );
    } catch (e) {
      return UpdateProfileResult.failure(
        'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}

/// AddVehicleResult — Hasil dari operasi POST /users/vehicles.
class AddVehicleResult {
  final bool success;
  final String message;
  final Vehicle? vehicle;

  const AddVehicleResult({
    required this.success,
    required this.message,
    this.vehicle,
  });
}

/// VehicleService — Service layer kendaraan pengguna.
///
/// Menangani operasi CRUD kendaraan.
/// Flow: ProfileProvider → VehicleService → REST API
class VehicleService {
  final ApiService _api = ApiService();

  /// Ambil daftar kendaraan dari GET /users/profile → data.vehicles.
  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await _api.get('/users/profile', requireAuth: true);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final items = body['data']?['vehicles'] as List<dynamic>?;
        if (items != null) {
          return items
              .map((json) => Vehicle.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('[VehicleService] getVehicles error: $e');
      return [];
    }
  }

  /// Tambah kendaraan baru.
  Future<AddVehicleResult> addVehicle({
    required String plateNumber,
    required String vehicleType,
  }) async {
    try {
      final payload = {
        'plateNumber': plateNumber,
        'vehicleType': vehicleType,
      };
      debugPrint('[VehicleService] addVehicle payload: $payload');

      final response = await _api.post(
        '/users/vehicles',
        body: payload,
        requireAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        Map<String, dynamic>? vehicleJson;
        if (body is Map<String, dynamic> && body['data'] is Map) {
          vehicleJson = body['data'] as Map<String, dynamic>;
        } else if (body is Map<String, dynamic>) {
          vehicleJson = body;
        }

        return AddVehicleResult(
          success: true,
          message: 'Kendaraan berhasil ditambahkan.',
          vehicle: vehicleJson != null ? Vehicle.fromJson(vehicleJson) : null,
        );
      }

      final errorMsg =
          _extractErrorMessage(response.body, 'Gagal menambahkan kendaraan.');
      return AddVehicleResult(success: false, message: errorMsg);
    } catch (e) {
      return AddVehicleResult(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Hapus kendaraan berdasarkan plat nomor.
  Future<bool> deleteVehicle(String plateNumber) async {
    try {
      final encodedPlate = Uri.encodeComponent(plateNumber);
      final response = await _api.delete(
        '/users/vehicles/$encodedPlate',
        requireAuth: true,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  static String _extractErrorMessage(String body, String fallback) {
    try {
      final json = jsonDecode(body);
      if (json is Map && json['message'] != null) {
        final msg = json['message'].toString();
        if (msg.contains('already exists')) {
          return 'Nomor kendaraan sudah terdaftar.';
        }
        if (msg.contains('required')) return 'Jenis kendaraan wajib dipilih.';
        return msg;
      }
    } catch (_) {}
    return fallback;
  }
}
