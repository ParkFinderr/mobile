import 'package:flutter/foundation.dart';
import '../models/ticket_data.dart';
import '../services/scan_service.dart';
import '../../../core/storage/active_ticket_storage.dart';

/// Enum status state untuk Scan.
enum ScanStatus { idle, scanning, success, failure }

/// ScanProvider — State management untuk fitur scan tiket QR.
///
/// Mengelola state verifikasi tiket dan tiket aktif.
///
/// Flow: WelcomeScanWidget → ScanProvider → ScanService → REST API
class ScanProvider extends ChangeNotifier {
  final ScanService _service;

  ScanProvider({ScanService? service}) : _service = service ?? ScanService();

  // ─── State ────────────────────────────────────────────────────────────────
  ScanStatus _status = ScanStatus.idle;
  TicketData? _currentTicket;
  String? _errorMessage;
  bool _isLoadingActiveTicket = false;

  ScanStatus get status => _status;
  TicketData? get currentTicket => _currentTicket;
  String? get errorMessage => _errorMessage;
  bool get isScanning => _status == ScanStatus.scanning;
  bool get isSuccess => _status == ScanStatus.success;
  bool get isLoadingActiveTicket => _isLoadingActiveTicket;

  // ─── Actions ──────────────────────────────────────────────────────────────

  /// Verifikasi QR code hasil scan kamera.
  Future<TicketData?> verifyTicket(String qrCode) async {
    _status = ScanStatus.scanning;
    _errorMessage = null;
    notifyListeners();

    final ticket = await _service.verifyTicket(qrCode);

    if (ticket != null && ticket.isValid) {
      _currentTicket = ticket;
      _status = ScanStatus.success;
      // Simpan ke local storage
      await ActiveTicketStorage().save(ticket);
    } else {
      _status = ScanStatus.failure;
      _errorMessage = 'QR Code tidak valid atau tiket tidak ditemukan.';
    }

    notifyListeners();
    return ticket;
  }

  /// Muat tiket aktif dari server (dipakai saat app dibuka ulang).
  Future<void> loadActiveTicket() async {
    _isLoadingActiveTicket = true;
    notifyListeners();

    final ticket = await _service.getActiveTicket();
    if (ticket != null) {
      _currentTicket = ticket;
    }

    _isLoadingActiveTicket = false;
    notifyListeners();
  }

  /// Set tiket secara manual (dari navigasi / argumen route).
  void setTicket(TicketData ticket) {
    _currentTicket = ticket;
    _status = ScanStatus.success;
    notifyListeners();
  }

  void resetState() {
    _status = ScanStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void clearTicket() {
    _currentTicket = null;
    _status = ScanStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
