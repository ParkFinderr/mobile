import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_service.dart';

/// ProfileData — Model data profil pengguna.
class ProfileData {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String? photoUrl;

  ProfileData({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.photoUrl,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    // Response dari GET /users/profile bisa langsung atau dibungkus {success, data: {...}}
    final Map<String, dynamic> src = (json['data'] is Map)
        ? json['data'] as Map<String, dynamic>
        : json;
    return ProfileData(
      userId: src['userId'] ?? '',
      name: src['name'] ?? 'User',
      email: src['email'] ?? 'No Email',
      phoneNumber: src['phoneNumber'] ?? 'No Phone Number',
      photoUrl: src['photoUrl'],
    );
  }
}

/// ProfileService — Service layer profil pengguna.
///
/// Menangani GET /users/profile dan PUT /users/profile.
/// Untuk kendaraan, gunakan VehicleService.
class UpdateProfileResult {
  final bool success;
  final String message;

  UpdateProfileResult({required this.success, required this.message});
}

class ProfileService {
  final ApiService _apiService = ApiService();

  Future<UpdateProfileResult> updateProfile(String name, String phoneNumber) async {
    try {
      final payload = {'name': name, 'phoneNumber': phoneNumber};
      debugPrint('[ProfileService] PUT /users/profile payload: $payload');
      final response = await _apiService.put(
        '/users/profile',
        body: payload,
        requireAuth: true,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return UpdateProfileResult(
          success: true,
          message: body['message'] ?? 'Profil berhasil diperbarui.',
        );
      }
      final body = jsonDecode(response.body);
      return UpdateProfileResult(
        success: false,
        message: body['message'] ?? 'Gagal menyimpan profil.',
      );
    } catch (e) {
      return UpdateProfileResult(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<ProfileData?> getProfile() async {
    try {
      final response = await _apiService.get('/users/profile', requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProfileData.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  Future<UpdateProfileResult> uploadPhoto(List<int> bytes, String fileName) async {
    try {
      debugPrint('[ProfileService] POST /users/profile/photo file: $fileName, size: ${bytes.length} bytes');
      final response = await _apiService.multipartPost(
        '/users/profile/photo',
        fileBytes: bytes,
        fileName: fileName,
        fieldName: 'image',
        requireAuth: true,
      );
      
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return UpdateProfileResult(
          success: true,
          message: body['message'] ?? 'Foto profil berhasil diunggah.',
        );
      }
      return UpdateProfileResult(
        success: false,
        message: body['message'] ?? 'Gagal mengunggah foto profil.',
      );
    } catch (e) {
      return UpdateProfileResult(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
