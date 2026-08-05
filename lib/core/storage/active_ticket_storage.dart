import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../features/scan/models/ticket_data.dart';

/// ActiveTicketStorage — Penyimpanan tiket parkir aktif secara lokal.
///
/// Menyimpan [TicketData] ke SharedPreferences agar tersedia
/// saat app di-restart tanpa harus fetch ulang dari server.
class ActiveTicketStorage {
  static const String _key = AppConstants.keyActiveTicket;

  Future<void> save(TicketData ticket) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(ticket.toJson()));
  }

  Future<TicketData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return TicketData.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
