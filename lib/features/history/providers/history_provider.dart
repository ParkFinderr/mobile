import 'package:flutter/foundation.dart';
import '../models/reservation_history.dart';
import '../services/history_service.dart';

/// Enum state untuk History.
enum HistoryStatus { idle, loading, success, failure }

/// HistoryProvider — State management untuk halaman riwayat parkir.
///
/// Mengelola:
/// - Daftar riwayat reservasi dari API
/// - Filter status (semua, aktif, selesai, dll.)
///
/// Flow: HistoryWidget → HistoryProvider → HistoryService → REST API
class HistoryProvider extends ChangeNotifier {
  final HistoryService _service;

  HistoryProvider({HistoryService? service})
      : _service = service ?? HistoryService();

  // ─── State ────────────────────────────────────────────────────────────────
  List<ReservationHistory> _history = [];
  HistoryStatus _status = HistoryStatus.idle;
  String? _error;
  String _filterStatus = 'all';

  List<ReservationHistory> get history => _history;
  HistoryStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == HistoryStatus.loading;
  String get filterStatus => _filterStatus;

  /// Riwayat yang sudah difilter berdasarkan status.
  List<ReservationHistory> get filteredHistory {
    if (_filterStatus == 'all') return _history;
    return _history.where((h) => h.status == _filterStatus).toList();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> loadHistory(String userId) async {
    _status = HistoryStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getHistory(userId);
      _history = result;
      _status = result.isEmpty ? HistoryStatus.failure : HistoryStatus.success;
      if (result.isEmpty) {
        _error = 'Belum ada riwayat parkir.';
      }
    } catch (e) {
      _status = HistoryStatus.failure;
      _error = 'Gagal memuat riwayat. Periksa koneksi Anda.';
    }

    notifyListeners();
  }

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void clearFilter() {
    _filterStatus = 'all';
    notifyListeners();
  }
}
