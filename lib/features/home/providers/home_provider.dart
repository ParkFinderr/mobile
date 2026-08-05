import 'package:flutter/foundation.dart';
import '../../../features/parking/models/parking_area.dart';
import '../../../features/parking/services/booking_service.dart';
import '../../../core/storage/active_reservation_storage.dart';
import '../../../core/storage/active_ticket_storage.dart';

/// Enum state untuk Home.
enum HomeStatus { idle, loading, success, failure }

/// HomeProvider — State management untuk halaman utama (Home).
///
/// Mengelola:
/// - Daftar area parkir (dari ParkingService)
/// - Data reservasi aktif dan tiket aktif (dari Storage)
///
/// Flow: HomeWidget → HomeProvider → BookingService / Storage
class HomeProvider extends ChangeNotifier {
  final BookingService _bookingService;
  final ActiveReservationStorage _reservationStorage;
  final ActiveTicketStorage _ticketStorage;

  HomeProvider({
    BookingService? bookingService,
    ActiveReservationStorage? reservationStorage,
    ActiveTicketStorage? ticketStorage,
  })  : _bookingService = bookingService ?? BookingService(),
        _reservationStorage = reservationStorage ?? ActiveReservationStorage(),
        _ticketStorage = ticketStorage ?? ActiveTicketStorage();

  // ─── State: Area Parkir ───────────────────────────────────────────────────
  List<ParkingArea> _areas = [];
  HomeStatus _areasStatus = HomeStatus.idle;
  String? _areasError;

  List<ParkingArea> get areas => _areas;
  HomeStatus get areasStatus => _areasStatus;
  String? get areasError => _areasError;
  bool get isAreasLoading => _areasStatus == HomeStatus.loading;

  // ─── State: Reservasi Aktif ───────────────────────────────────────────────
  ActiveReservation? _activeReservation;
  bool _isLoadingReservation = false;

  ActiveReservation? get activeReservation => _activeReservation;
  bool get isLoadingReservation => _isLoadingReservation;
  bool get hasActiveReservation => _activeReservation != null;

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> loadAreas() async {
    _areasStatus = HomeStatus.loading;
    _areasError = null;
    notifyListeners();

    final result = await _bookingService.getAreas();
    _areas = result;
    _areasStatus = result.isEmpty ? HomeStatus.failure : HomeStatus.success;
    if (result.isEmpty) {
      _areasError = 'Tidak ada area parkir yang tersedia.';
    }
    notifyListeners();
  }

  Future<void> loadActiveReservation() async {
    _isLoadingReservation = true;
    notifyListeners();

    _activeReservation = await _reservationStorage.load();
    _isLoadingReservation = false;
    notifyListeners();
  }

  Future<void> clearActiveReservation() async {
    await _reservationStorage.clear();
    await _ticketStorage.clear();
    _activeReservation = null;
    notifyListeners();
  }

  void setActiveReservation(ActiveReservation reservation) {
    _activeReservation = reservation;
    notifyListeners();
  }

  Future<void> init() async {
    await Future.wait([
      loadAreas(),
      loadActiveReservation(),
    ]);
  }
}
