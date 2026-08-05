import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../models/parking_area.dart';
import '../models/parking_slot.dart';
import '../models/reservation_result.dart';
import 'package:mobile_front/features/notification/services/notification_service.dart';

/// BookingService — Service layer untuk operasi booking dan reservasi parkir.
///
/// Menangani:
/// - GET /areas → daftar area parkir
/// - GET /areas/{id}/slots → slot per area
/// - POST /reservations → buat reservasi
/// - PATCH /reservations/{id}/arrive → konfirmasi kedatangan
/// - PATCH /reservations/{id}/complete → selesai parkir
/// - PATCH /reservations/{id}/cancel → batalkan reservasi
/// - PATCH|POST /reservations/{id}/swap → ganti slot
/// - POST /access/cancelTicket → batalkan tiket
///
/// Flow: ParkingProvider → BookingService → REST API
class BookingService {
  final ApiService _api = ApiService();

  // ─── Area & Slot ──────────────────────────────────────────────────────────

  Future<List<ParkingArea>> getAreas() async {
    try {
      final response = await _api.get('/areas', requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list =
            data is List ? data : (data['data'] is List ? data['data'] : []);
        return (list as List)
            .map((e) => ParkingArea.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<ParkingSlot>> getSlots(String areaId) async {
    try {
      final response =
          await _api.get('/areas/$areaId/slots', requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list =
            data is List ? data : (data['data'] is List ? data['data'] : []);
        return (list as List)
            .map((e) => ParkingSlot.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ─── Reservasi ────────────────────────────────────────────────────────────

  Future<ReservationResult> createReservation({
    required String slotId,
    required String ticketId,
    required String name,
    required String plateNumber,
  }) async {
    try {
      final response = await _api.post(
        '/reservations',
        body: {
          'ticketId': ticketId,
          'slotId': slotId,
        },
        requireAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>?;
        final resId = data?['reservationId'] as String? ??
            data?['id'] as String? ??
            data?['_id'] as String? ??
            body['reservationId'] as String? ??
            body['id'] as String? ??
            body['_id'] as String? ??
            'res_${DateTime.now().millisecondsSinceEpoch}';
        final status = data?['status'] as String? ??
            body['status'] as String? ??
            'pending';

        NotificationService.addNotification(
          title: 'Reservasi Slot Berhasil',
          subtitle: 'Reservasi slot parkir berhasil dibuat.',
          icon: Icons.check_circle_outline_rounded,
          iconColor: const Color(0xFF10B981),
        );

        return ReservationResult(
          success: true,
          reservationId: resId,
          status: status,
          message: body['message'] as String? ?? 'Booking berhasil.',
        );
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ReservationResult.failure(
        body['message'] as String? ?? 'Booking gagal.',
      );
    } catch (e) {
      return ReservationResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ActionResult> arriveReservation(String reservationId) async {
    try {
      final response = await _api.patch(
        '/reservations/$reservationId/arrive',
        requireAuth: true,
      );
      final res = _parseActionResult(response, 'Kedatangan berhasil dikonfirmasi.',
          'Gagal mengonfirmasi kedatangan.');
      if (res.success) {
        NotificationService.addNotification(
          title: 'Sesi Parkir Berjalan',
          subtitle: 'Kedatangan Anda di slot parkir telah dikonfirmasi.',
          icon: Icons.local_parking_rounded,
          iconColor: const Color(0xFF2563EB),
        );
      }
      return res;
    } catch (e) {
      return ActionResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ActionResult> completeReservation(String reservationId) async {
    try {
      var response = await _api.patch(
        '/reservations/$reservationId/complete',
        requireAuth: true,
      );
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await _api.post(
          '/reservations/$reservationId/complete',
          requireAuth: true,
        );
      }
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await _api.put(
          '/reservations/$reservationId/complete',
          requireAuth: true,
        );
      }

      final res = _parseActionResult(response, 'Sesi parkir berhasil diselesaikan.',
          'Gagal menyelesaikan sesi parkir.');
      if (res.success) {
        NotificationService.addNotification(
          title: 'Sesi Parkir Selesai',
          subtitle: 'Sesi parkir Anda telah selesai.',
          icon: Icons.task_alt_rounded,
          iconColor: const Color(0xFF10B981),
        );
      }
      return res;
    } catch (e) {
      return ActionResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<CancelResult> cancelReservation(String reservationId) async {
    try {
      var response = await _api.patch(
        '/reservations/$reservationId/cancel',
        requireAuth: true,
      );
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await _api.post(
          '/reservations/$reservationId/cancel',
          requireAuth: true,
        );
      }
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await _api.put(
          '/reservations/$reservationId/cancel',
          requireAuth: true,
        );
      }

      final ar = _parseActionResult(response, 'Reservasi berhasil dibatalkan.',
          'Gagal membatalkan reservasi.');
      if (ar.success) {
        NotificationService.addNotification(
          title: 'Reservasi Dibatalkan',
          subtitle: 'Reservasi slot parkir telah dibatalkan.',
          icon: Icons.cancel_outlined,
          iconColor: const Color(0xFFEF4444),
        );
      }
      return CancelResult(success: ar.success, message: ar.message);
    } catch (e) {
      return CancelResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<CancelResult> cancelTicket(String ticketId) async {
    try {
      final response = await _api.post(
        '/access/cancelTicket',
        body: {'ticketId': ticketId},
        requireAuth: true,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        NotificationService.addNotification(
          title: 'Tiket Dibatalkan',
          subtitle: 'Tiket parkir $ticketId telah dibatalkan.',
          icon: Icons.cancel_outlined,
          iconColor: const Color(0xFFEF4444),
        );
        return CancelResult(
          success: json['success'] == true,
          message: json['message'] as String? ?? 'Tiket berhasil dibatalkan.',
        );
      }
      return const CancelResult.failure('Gagal terhubung ke server.');
    } catch (e) {
      return CancelResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ActionResult> swapReservation(
      String reservationId, String newSlotId) async {
    try {
      var response = await _api.patch(
        '/reservations/$reservationId/swap',
        body: {'newSlotId': newSlotId},
        requireAuth: true,
      );

      // Fallback ke POST jika PATCH tidak didukung
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await _api.post(
          '/reservations/$reservationId/swap',
          body: {'newSlotId': newSlotId},
          requireAuth: true,
        );
      }

      final res = _parseActionResult(response, 'Slot parkir berhasil diganti.',
          'Gagal mengganti slot parkir.');
      if (res.success) {
        NotificationService.addNotification(
          title: 'Slot Parkir Diganti',
          subtitle: 'Berhasil berpindah ke slot parkir baru.',
          icon: Icons.swap_horiz_rounded,
          iconColor: const Color(0xFF8B5CF6),
        );
      }
      return res;
    } catch (e) {
      return ActionResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // ─── Helper ───────────────────────────────────────────────────────────────

  ActionResult _parseActionResult(
    dynamic response,
    String successMsg,
    String failMsg,
  ) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ActionResult(
          success: json['success'] == true,
          message: json['message'] as String? ?? successMsg,
        );
      } catch (_) {
        return ActionResult.ok(successMsg);
      }
    }
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ActionResult.failure(json['message'] as String? ?? failMsg);
    } catch (_) {
      return ActionResult.failure('$failMsg (Status ${response.statusCode})');
    }
  }
}
