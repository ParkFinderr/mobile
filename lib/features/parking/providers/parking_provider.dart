import 'package:flutter/foundation.dart';
import '../models/parking_area.dart';
import '../models/parking_slot.dart';
import '../models/reservation_result.dart';
import '../services/booking_service.dart';

/// Enum state untuk operasi parking.
enum ParkingStatus { idle, loading, success, failure }

/// ParkingProvider — State management untuk fitur booking dan detail booking.
///
/// Mengelola:
/// - Daftar area parkir
/// - Daftar slot per area
/// - Proses booking / reservasi
/// - Aksi arrive, complete, cancel, swap
///
/// Flow: UI → ParkingProvider → BookingService → REST API
class ParkingProvider extends ChangeNotifier {
  final BookingService _service;

  ParkingProvider({BookingService? service})
      : _service = service ?? BookingService();

  // ─── State: Area ──────────────────────────────────────────────────────────
  List<ParkingArea> _areas = [];
  ParkingStatus _areasStatus = ParkingStatus.idle;
  String? _areasError;

  List<ParkingArea> get areas => _areas;
  ParkingStatus get areasStatus => _areasStatus;
  String? get areasError => _areasError;
  bool get isAreasLoading => _areasStatus == ParkingStatus.loading;

  // ─── State: Slot ──────────────────────────────────────────────────────────
  List<ParkingSlot> _slots = [];
  ParkingStatus _slotsStatus = ParkingStatus.idle;
  // ignore: unused_field
  String? _slotsError;

  List<ParkingSlot> get slots => _slots;
  ParkingStatus get slotsStatus => _slotsStatus;
  bool get isSlotsLoading => _slotsStatus == ParkingStatus.loading;

  // ─── State: Booking ───────────────────────────────────────────────────────
  ParkingStatus _bookingStatus = ParkingStatus.idle;
  String? _bookingMessage;
  String? _lastReservationId;

  ParkingStatus get bookingStatus => _bookingStatus;
  String? get bookingMessage => _bookingMessage;
  String? get lastReservationId => _lastReservationId;
  bool get isBookingLoading => _bookingStatus == ParkingStatus.loading;

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> loadAreas() async {
    _areasStatus = ParkingStatus.loading;
    _areasError = null;
    notifyListeners();

    final result = await _service.getAreas();
    _areas = result;
    _areasStatus =
        result.isEmpty ? ParkingStatus.failure : ParkingStatus.success;
    notifyListeners();
  }

  Future<void> loadSlots(String areaId) async {
    _slotsStatus = ParkingStatus.loading;
    _slotsError = null;
    _slots = [];
    notifyListeners();

    final result = await _service.getSlots(areaId);
    _slots = result;
    _slotsStatus =
        result.isEmpty ? ParkingStatus.failure : ParkingStatus.success;
    notifyListeners();
  }

  Future<ReservationResult> createReservation({
    required String slotId,
    required String ticketId,
    required String name,
    required String plateNumber,
  }) async {
    _bookingStatus = ParkingStatus.loading;
    notifyListeners();

    final result = await _service.createReservation(
      slotId: slotId,
      ticketId: ticketId,
      name: name,
      plateNumber: plateNumber,
    );

    _bookingStatus =
        result.isSuccess ? ParkingStatus.success : ParkingStatus.failure;
    _bookingMessage = result.message;
    _lastReservationId = result.isSuccess ? result.reservationId : null;
    notifyListeners();
    return result;
  }

  Future<ActionResult> arriveReservation(String reservationId) async {
    return _service.arriveReservation(reservationId);
  }

  Future<ActionResult> completeReservation(String reservationId) async {
    return _service.completeReservation(reservationId);
  }

  Future<CancelResult> cancelReservation(String reservationId) async {
    return _service.cancelReservation(reservationId);
  }

  Future<CancelResult> cancelTicket(String ticketId) async {
    return _service.cancelTicket(ticketId);
  }

  Future<ActionResult> swapReservation(
          String reservationId, String newSlotId) async =>
      _service.swapReservation(reservationId, newSlotId);

  void resetBookingState() {
    _bookingStatus = ParkingStatus.idle;
    _bookingMessage = null;
    _lastReservationId = null;
    notifyListeners();
  }

  void clearSlots() {
    _slots = [];
    _slotsStatus = ParkingStatus.idle;
    notifyListeners();
  }
}
