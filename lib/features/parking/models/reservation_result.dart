/// ReservationResult — Hasil dari operasi POST /reservations.
class ReservationResult {
  final bool success;
  final String reservationId;
  final String status;
  final String message;

  const ReservationResult({
    required this.success,
    required this.reservationId,
    required this.status,
    required this.message,
  });

  const ReservationResult.failure(this.message)
      : success = false,
        reservationId = '',
        status = '';

  bool get isSuccess => success;
}

/// ActionResult — Hasil dari operasi PATCH (arrive, complete, swap).
class ActionResult {
  final bool success;
  final String message;

  const ActionResult({required this.success, required this.message});

  const ActionResult.failure(this.message) : success = false;
  const ActionResult.ok(this.message) : success = true;

  bool get isSuccess => success;
}

/// CancelResult — Hasil dari operasi pembatalan reservasi.
class CancelResult {
  final bool success;
  final String message;

  const CancelResult({required this.success, required this.message});

  const CancelResult.failure(this.message) : success = false;
  const CancelResult.ok(this.message) : success = true;
}
