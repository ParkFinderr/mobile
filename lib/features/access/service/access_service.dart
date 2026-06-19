import 'dart:convert';
import '../../../core/network/api_service.dart';
import '../../welcome_scan/service/scan_service.dart';

class AccessService {
  final ApiService _apiService = ApiService();

  Future<TicketData?> getActiveTicket() async {
    try {
      final response = await _apiService.get(
        '/access/activeTicket',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['data'] != null) {
          return TicketData.fromJson(json['data']);
        }
        return TicketData.fromJson(json);
      }
      return null;
    } catch (e) {
      print('Get active ticket error: $e');
      return null;
    }
  }
}
