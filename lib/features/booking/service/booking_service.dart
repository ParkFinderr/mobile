import 'dart:convert';
import '../../../core/network/api_service.dart';

class ParkingArea {
  final String id;
  final String name;
  final String address;
  final int totalSlot;
  final int availableSlots;

  ParkingArea({
    required this.id,
    required this.name,
    required this.address,
    required this.totalSlot,
    required this.availableSlots,
  });

  factory ParkingArea.fromJson(Map<String, dynamic> json) {
    return ParkingArea(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Area',
      address: json['address'] ?? json['location'] ?? 'Unknown Location',
      totalSlot: json['totalSlots'] ?? json['totalSlot'] ?? json['slot'] ?? 0,
      availableSlots: json['availableSlots'] ?? json['availableSlot'] ?? 0,
    );
  }
}

class ParkingSlot {
  final String id;
  final String slotNumber;
  final String status;
  final String vehicleType;

  ParkingSlot({required this.id, required this.slotNumber, required this.status, required this.vehicleType});

  factory ParkingSlot.fromJson(Map<String, dynamic> json) {
    return ParkingSlot(
      id: json['id'] ?? json['_id'] ?? '',
      slotNumber: json['slotName'] ?? json['slotNumber'] ?? '',
      status: json['appStatus'] ?? json['status'] ?? 'available',
      vehicleType: json['vehicleType'] ?? 'mobil',
    );
  }
}

class BookingService {
  final ApiService _apiService = ApiService();

  Future<List<ParkingArea>> getAreas() async {
    try {
      final response = await _apiService.get('/areas', requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) => ParkingArea.fromJson(e)).toList();
        } else if (data['data'] is List) {
          return (data['data'] as List).map((e) => ParkingArea.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Get areas error: $e');
      return [];
    }
  }

  Future<List<ParkingSlot>> getSlots(String areaId) async {
    try {
      final response = await _apiService.get('/areas/$areaId/slots', requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) => ParkingSlot.fromJson(e)).toList();
        } else if (data['data'] is List) {
          return (data['data'] as List).map((e) => ParkingSlot.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Get slots error: $e');
      return [];
    }
  }

  Future<ReservationResult> createReservation(String slotId, String ticketId, String name, String plateNumber) async {
    try {
      final response = await _apiService.post(
        '/reservations',
        body: {
          'slotId': slotId,
          'ticketId': ticketId,
          'name': name,
          'plateNumber': plateNumber,
        },
        requireAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final data = body['data'] as Map<String, dynamic>?;
        if (data != null) {
          return ReservationResult(
            success: true,
            reservationId: data['reservationId'] ?? '',
            status: data['status'] ?? 'pending',
            message: body['message'] ?? 'Booking berhasil.',
          );
        }
        return ReservationResult(
          success: true,
          reservationId: '',
          status: 'pending',
          message: 'Booking berhasil.',
        );
      }
      final body = jsonDecode(response.body);
      return ReservationResult(
        success: false,
        reservationId: '',
        status: '',
        message: body['message'] ?? 'Booking gagal.',
      );
    } catch (e) {
      return ReservationResult(
        success: false,
        reservationId: '',
        status: '',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}

class ReservationResult {
  final bool success;
  final String reservationId;
  final String status;
  final String message;

  ReservationResult({
    required this.success,
    required this.reservationId,
    required this.status,
    required this.message,
  });
}
