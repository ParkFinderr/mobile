import 'dart:convert';
import '../../../core/network/api_service.dart';

class ParkingService {
  final ApiService _apiService = ApiService();

  Future<CancelResult> cancelTicket(String ticketId) async {
    try {
      final response = await _apiService.post(
        '/access/cancelTicket',
        body: {'ticketId': ticketId},
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return CancelResult(success: true, message: json['message'] ?? 'Tiket berhasil dibatalkan.');
        }
        return CancelResult(success: false, message: json['message'] ?? 'Gagal membatalkan tiket.');
      }
      return CancelResult(success: false, message: 'Gagal terhubung ke server.');
    } catch (e) {
      return CancelResult(success: false, message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<CancelResult> cancelReservation(String reservationId) async {
    try {
      final response = await _apiService.patch(
        '/reservations/$reservationId/cancel',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return CancelResult(success: true, message: json['message'] ?? 'Reservasi berhasil dibatalkan.');
        }
        return CancelResult(success: false, message: json['message'] ?? 'Gagal membatalkan reservasi.');
      }
      final json = jsonDecode(response.body);
      return CancelResult(success: false, message: json['message'] ?? 'Gagal terhubung ke server.');
    } catch (e) {
      return CancelResult(success: false, message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }
}

class CancelResult {
  final bool success;
  final String message;

  CancelResult({required this.success, required this.message});
}
