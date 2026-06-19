import 'dart:convert';
import '../../../core/network/api_service.dart';
import '../model/reservation_history.dart';

class HistoryService {
  final ApiService _apiService = ApiService();

  Future<List<ReservationHistory>> getHistory(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/reservations', requireAuth: true);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          final list = body['data'] as List;
          return list.map((json) => ReservationHistory.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Get history error: $e');
      return [];
    }
  }
}
