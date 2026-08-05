import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_service.dart';
import '../models/reservation_history.dart';

class HistoryService {
  final ApiService _apiService = ApiService();

  Future<List<ReservationHistory>> getHistory(String userId) async {
    try {
      final endpoint = userId.isNotEmpty ? '/users/$userId/reservations' : '/reservations';
      final response = await _apiService.get(endpoint, requireAuth: true);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final dynamic rawList = (body is Map && body['data'] is List)
            ? body['data']
            : ((body is Map && body['reservations'] is List)
                ? body['reservations']
                : (body is List ? body : []));

        if (rawList is List) {
          return rawList
              .whereType<Map<String, dynamic>>()
              .map((json) => ReservationHistory.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Get history error: $e');
      return [];
    }
  }
}
