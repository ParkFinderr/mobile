import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveReservation {
  final String reservationId;
  final String status;
  final String slotId;
  final String slotName;
  final String areaId;
  final String ticketId;
  final String startTime;

  ActiveReservation({
    required this.reservationId,
    required this.status,
    this.slotId = '',
    this.slotName = '',
    this.areaId = '',
    this.ticketId = '',
    this.startTime = '',
  });

  factory ActiveReservation.fromJson(Map<String, dynamic> json) {
    return ActiveReservation(
      reservationId: json['reservationId'] ?? '',
      status: json['status'] ?? 'pending',
      slotId: json['slotId'] ?? '',
      slotName: json['slotName'] ?? '',
      areaId: json['areaId'] ?? '',
      ticketId: json['ticketId'] ?? '',
      startTime: json['startTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservationId': reservationId,
      'status': status,
      'slotId': slotId,
      'slotName': slotName,
      'areaId': areaId,
      'ticketId': ticketId,
      'startTime': startTime,
    };
  }
}

class ActiveReservationStorage {
  static const String _key = 'active_reservation';

  Future<void> save(ActiveReservation reservation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(reservation.toJson()));
  }

  Future<ActiveReservation?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ActiveReservation.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
